import Flutter
import UIKit

#if canImport(ActivityKit)
import ActivityKit
#endif

/// Native side of the lock-screen tracking (Live Activity). It only displays
/// what Flutter sends and reports what the system did (removed by the user,
/// already running). It never reads or writes the app's records, and taps on
/// it come back as links that the app confirms before registering anything.
///
/// Live Activities need iOS 16.2+; on older systems every call answers
/// "unsupported" and the app keeps working (ActivityKit is weak-linked).
final class TrackingChannel {
    static let shared = TrackingChannel()

    private var channel: FlutterMethodChannel?
    private var pendingLink: [String: String]?
    private let defaults = UserDefaults.standard
    private let dismissedKey = "tracking.dismissed_outings"

    /// Calls run one after the other, so an "end" can never be overtaken by a
    /// slower "start" of the same outing.
    private var tail: Task<Void, Never> = Task {}

    func register(messenger: FlutterBinaryMessenger) {
        let ch = FlutterMethodChannel(name: "bebometro/tracking", binaryMessenger: messenger)
        channel = ch
        // A one-tap command queued by the Live Activity button (iOS 17+): tell
        // Flutter, which reads the durable queue itself (it also reads it at
        // startup and on resume, in case Dart was not running).
        NotificationCenter.default.addObserver(
            forName: TrackingCommandQueue.queued, object: nil, queue: .main
        ) { [weak self] _ in
            self?.channel?.invokeMethod("commandsAvailable", arguments: nil)
        }
        ch.setMethodCallHandler { [weak self] call, result in
            self?.enqueue { await self?.handle(call, result) }
        }
        enqueue { await self.adoptExisting() }
    }

    private func enqueue(_ work: @escaping () async -> Void) {
        let previous = tail
        tail = Task {
            await previous.value
            await work()
        }
    }

    // MARK: - Links (taps on the Live Activity)

    func handle(url: URL) {
        guard url.scheme == "bebometro", url.host == "outing" else { return }
        let id = url.pathComponents.filter { $0 != "/" }.first ?? ""
        guard !id.isEmpty else { return }
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let action = comps?.queryItems?.first(where: { $0.name == "action" })?.value ?? "open"
        pendingLink = ["outingId": id, "action": action]
        DispatchQueue.main.async { self.channel?.invokeMethod("linkReceived", arguments: nil) }
    }

    // MARK: - Channel

    private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) async {
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "capabilities":
            result(await capabilities())
        case "requestPermission":
            // Live Activities have no runtime prompt: the user controls them
            // in Settings. Nothing to request.
            result("notRequired")
        case "sync":
            result(await sync(args ?? [:]))
        case "end":
            await end(outingId: args?["outingId"] as? String)
            result(nil)
        case "status":
            result(await status())
        case "clearDismissed":
            if let id = args?["outingId"] as? String { setDismissed(id, false) }
            result(nil)
        case "peekCommands":
            result(TrackingCommandQueue.peek())
        case "ackCommands":
            TrackingCommandQueue.ack((args?["ids"] as? [String]) ?? [])
            result(nil)
        case "consumeLink":
            let link = pendingLink
            pendingLink = nil
            result(link)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func capabilities() async -> [String: Any] {
        #if canImport(ActivityKit)
        if #available(iOS 16.2, *) {
            let enabled = ActivityAuthorizationInfo().areActivitiesEnabled
            return [
                "supported": true,
                "systemEnabled": enabled,
                "permission": "notRequired",
                "detail": "ios",
            ]
        }
        #endif
        return ["supported": false]
    }

    // MARK: - Dismissed by the user

    private func dismissedIds() -> Set<String> {
        Set(defaults.stringArray(forKey: dismissedKey) ?? [])
    }

    private func setDismissed(_ id: String, _ on: Bool) {
        var set = dismissedIds()
        if on { set.insert(id) } else { set.remove(id) }
        defaults.set(Array(set), forKey: dismissedKey)
    }

    // MARK: - Live Activity

    #if canImport(ActivityKit)
    /// Outings whose activity we ended ourselves: a later ".dismissed" state is
    /// then ours, not a removal by the user.
    private var endedByUs = Set<String>()
    private var observed = Set<String>()

    @available(iOS 16.2, *)
    private func activities(for id: String? = nil) -> [Activity<OutingActivityAttributes>] {
        Activity<OutingActivityAttributes>.activities.filter { id == nil || $0.attributes.outingId == id }
    }

    /// Re-attaches observers to activities that survived an app restart, so a
    /// removal by the user is still noticed.
    private func adoptExisting() async {
        if #available(iOS 16.2, *) {
            for a in activities() { observe(a) }
        }
    }

    @available(iOS 16.2, *)
    private func observe(_ activity: Activity<OutingActivityAttributes>) {
        let id = activity.attributes.outingId
        guard observed.insert(activity.id).inserted else { return }
        Task { [weak self] in
            for await state in activity.activityStateUpdates {
                guard let self = self else { return }
                switch state {
                case .dismissed:
                    // Removed from the lock screen / Dynamic Island. The
                    // system also removes an activity that is over its time
                    // limit, which is not a choice of the user.
                    let started = activity.content.state.startedAt
                    let overLimit = Date().timeIntervalSince(started) > 7.5 * 3600
                    if !self.endedByUs.contains(id) && !overLimit {
                        self.setDismissed(id, true)
                    }
                    self.observed.remove(activity.id)
                    return
                case .ended:
                    self.observed.remove(activity.id)
                    return
                default:
                    continue
                }
            }
        }
    }

    private func sync(_ a: [String: Any]) async -> String {
        guard #available(iOS 16.2, *) else { return "unavailable" }
        guard let id = a["outingId"] as? String else { return "error" }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return "systemOff" }
        if dismissedIds().contains(id) { return "dismissed" }

        let started = Date(timeIntervalSince1970: ((a["startedAtMs"] as? NSNumber)?.doubleValue ?? 0) / 1000)
        let state = OutingActivityAttributes.ContentState(
            startedAt: started,
            alcoholicCount: (a["alcoholicCount"] as? NSNumber)?.intValue ?? 0,
            spendCents: (a["spendCents"] as? NSNumber)?.intValue,
            unpricedCount: (a["unpricedCount"] as? NSNumber)?.intValue ?? 0,
            place: (a["place"] as? String).flatMap { $0.isEmpty ? nil : $0 },
            nextLabel: (a["nextLabel"] as? String).flatMap { $0.isEmpty ? nil : $0 },
            quickLogged: ((a["pendingCommands"] as? NSNumber)?.intValue).flatMap { $0 > 0 ? $0 : nil },
            texts: Self.texts(from: a["texts"]),
            repeatEntryId: (a["repeatEntryId"] as? String).flatMap { $0.isEmpty ? nil : $0 },
            accountId: (a["accountId"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        )
        let content = ActivityContent(state: state, staleDate: nil)

        // One activity per outing: update it instead of starting another.
        let existing = activities(for: id)
        if let first = existing.first {
            await first.update(content)
            for extra in existing.dropFirst() {
                endedByUs.insert(id)
                await extra.end(nil, dismissalPolicy: .immediate)
            }
            observe(first)
            return "updated"
        }
        do {
            endedByUs.remove(id)
            let activity = try Activity.request(
                attributes: OutingActivityAttributes(outingId: id),
                content: content,
                pushType: nil
            )
            observe(activity)
            return "started"
        } catch {
            // Typically: the app is not in the foreground, or the system
            // refused (limit of activities, user setting).
            return "error"
        }
    }

    /// The texts Flutter sent, in the app's language. Empty strings count as
    /// missing, so the widget falls back to its own wording.
    @available(iOS 16.2, *)
    private static func texts(from raw: Any?) -> OutingActivityAttributes.ContentState.Texts? {
        guard let map = raw as? [String: Any] else { return nil }
        func s(_ key: String) -> String? {
            guard let v = map[key] as? String, !v.isEmpty else { return nil }
            return v
        }
        return OutingActivityAttributes.ContentState.Texts(
            title: s("title"),
            count: s("count"),
            spend: s("spend"),
            open: s("open"),
            another: s("another"),
            anotherWith: s("anotherWith"),
            anotherA11y: s("anotherA11y"),
            water: s("water"),
            pending: s("pending")
        )
    }

    private func end(outingId: String?) async {
        guard #available(iOS 16.2, *) else { return }
        for a in activities(for: outingId) {
            endedByUs.insert(a.attributes.outingId)
            await a.end(nil, dismissalPolicy: .immediate)
        }
    }

    private func status() async -> [String: Any] {
        guard #available(iOS 16.2, *) else { return ["shown": [String](), "dismissed": [String]()] }
        let shown = activities()
            .filter { $0.activityState == .active || $0.activityState == .stale }
            .map { $0.attributes.outingId }
        return ["shown": shown, "dismissed": Array(dismissedIds())]
    }
    #else
    private func adoptExisting() async {}
    private func sync(_ a: [String: Any]) async -> String { "unavailable" }
    private func end(outingId: String?) async {}
    private func status() async -> [String: Any] { ["shown": [String](), "dismissed": [String]()] }
    #endif
}
