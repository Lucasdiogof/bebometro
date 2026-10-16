import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

/// Durable queue of commands given on the lock screen / Dynamic Island with one
/// tap (iOS 17+). Compiled into BOTH the app and the widget extension: the
/// system runs `AnotherDrinkIntent.perform()` in the APP process (that is what
/// LiveActivityIntent means), possibly launched in the background without any
/// screen. It never touches the app's records: it only queues a command, and
/// Flutter registers the drink from its own stored records, with the same rules
/// as the in-app "Mais uma", and then acknowledges the command.
///
/// Not validated on a device in this environment (no Xcode/iPhone): see
/// docs/lock-screen-one-tap.md for the validation script.
enum TrackingCommandQueue {
    static let key = "tracking.commands"
    static let queued = Notification.Name("bebometro.tracking.commandQueued")
    private static let lock = NSLock()

    /// Appends a command with its own unique id (one per tap: a replay of the
    /// same command is recognised by Flutter, two taps are two commands).
    @discardableResult
    static func enqueue(outingId: String, kind: String) -> String {
        lock.lock(); defer { lock.unlock() }
        let id = UUID().uuidString
        var list = UserDefaults.standard.array(forKey: key) as? [[String: Any]] ?? []
        list.append(["id": id, "outingId": outingId, "kind": kind,
                     "at": Date().timeIntervalSince1970])
        if list.count > 100 { list.removeFirst(list.count - 100) }
        UserDefaults.standard.set(list, forKey: key)
        return id
    }

    static func peek() -> [[String: Any]] {
        lock.lock(); defer { lock.unlock() }
        return UserDefaults.standard.array(forKey: key) as? [[String: Any]] ?? []
    }

    /// Removes only what Flutter confirmed it handled.
    static func ack(_ ids: [String]) {
        lock.lock(); defer { lock.unlock() }
        let drop = Set(ids)
        let list = (UserDefaults.standard.array(forKey: key) as? [[String: Any]] ?? [])
            .filter { !drop.contains(($0["id"] as? String) ?? "") }
        UserDefaults.standard.set(list, forKey: key)
    }
}

#if canImport(ActivityKit) && canImport(AppIntents)
import AppIntents

/// "Mais uma" as a real button on the Live Activity (iOS 17+). One tap queues a
/// command; nothing opens and nothing is asked.
@available(iOS 17.0, *)
struct AnotherDrinkIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Mais uma"
    static let description = IntentDescription("Registra outra unidade da última bebida do rolê em andamento.")
    static var isDiscoverable: Bool { false }

    @Parameter(title: "Rolê")
    var outingId: String

    init() {
        self.outingId = ""
    }

    init(outingId: String) {
        self.outingId = outingId
    }

    func perform() async throws -> some IntentResult {
        guard !outingId.isEmpty else { return .result() }
        TrackingCommandQueue.enqueue(outingId: outingId, kind: "another")
        // Immediate, language-neutral feedback on the activity itself ("✓ +1"):
        // Flutter replaces the whole state with the real totals as soon as it
        // runs (it also fixes it if the command is dropped).
        if #available(iOS 16.2, *) {
            for activity in Activity<OutingActivityAttributes>.activities
            where activity.attributes.outingId == outingId {
                var state = activity.content.state
                state.quickLogged = (state.quickLogged ?? 0) + 1
                await activity.update(ActivityContent(state: state, staleDate: nil))
            }
        }
        NotificationCenter.default.post(name: TrackingCommandQueue.queued, object: nil)
        return .result()
    }
}
#endif
