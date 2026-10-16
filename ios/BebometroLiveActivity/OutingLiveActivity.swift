import ActivityKit
import SwiftUI
import WidgetKit

private enum Palette {
    static let background = Color(red: 0.082, green: 0.075, blue: 0.067)
    static let surface = Color(red: 0.165, green: 0.149, blue: 0.133)
    static let amber = Color(red: 0.949, green: 0.659, blue: 0.114)
    static let text = Color(red: 0.973, green: 0.945, blue: 0.902)
    static let muted = Color(red: 0.725, green: 0.678, blue: 0.616)
}

private func money(_ cents: Int) -> String {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.locale = Locale(identifier: "pt_BR")
    return (f.string(from: NSNumber(value: Double(cents) / 100.0)) ?? "R$ 0,00")
        .replacingOccurrences(of: "\u{00a0}", with: " ")
}

/// The texts come ready-made from the app (in the language chosen there). The
/// Portuguese wording below only covers an activity started by an older build.
@available(iOS 16.2, *)
private func countText(_ s: OutingActivityAttributes.ContentState) -> String {
    if let t = s.texts?.count { return t }
    switch s.alcoholicCount {
    case 0: return "Nenhum registro de bebida alcoólica"
    case 1: return "1 registro de bebida alcoólica"
    default: return "\(s.alcoholicCount) registros de bebida alcoólica"
    }
}

@available(iOS 16.2, *)
private func spendText(_ s: OutingActivityAttributes.ContentState) -> String? {
    guard let cents = s.spendCents else { return nil }
    if let t = s.texts?.spend { return t }
    return s.unpricedCount > 0
        ? "\(money(cents)) informados · \(s.unpricedCount) sem preço"
        : "\(money(cents)) informados"
}

@available(iOS 16.2, *)
private func titleText(_ s: OutingActivityAttributes.ContentState) -> String {
    s.place ?? s.texts?.title ?? "Rolê em andamento"
}

@available(iOS 16.2, *)
private func link(_ id: String, _ action: String) -> URL {
    URL(string: "bebometro://outing/\(id)?action=\(action)")!
}

/// Elapsed time drawn by the system (counts up, no timer in the app).
@available(iOS 16.2, *)
private struct Elapsed: View {
    let since: Date
    var body: some View {
        Text(since, style: .timer)
            .monospacedDigit()
            .multilineTextAlignment(.trailing)
    }
}

@available(iOS 16.2, *)
private struct ChipLabel: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(Palette.surface))
            .foregroundColor(Palette.amber)
    }
}

@available(iOS 16.2, *)
private struct Chip: View {
    let title: String
    let url: URL
    var body: some View {
        Link(destination: url) { ChipLabel(title: title) }
    }
}

/// "Mais uma": a real button on iOS 17+ (one tap registers, the app does not
/// open); a link that opens the app on iOS 16.2-16.x.
@available(iOS 16.2, *)
private struct AnotherChip: View {
    let title: String
    let outingId: String
    var body: some View {
        if #available(iOS 17.0, *) {
            Button(intent: AnotherDrinkIntent(outingId: outingId)) {
                ChipLabel(title: title)
            }
            .buttonStyle(.plain)
        } else {
            Chip(title: title, url: link(outingId, "another"))
        }
    }
}

/// Discreet confirmation of a one-tap command still being applied by the app.
@available(iOS 16.2, *)
private struct QuickLoggedBadge: View {
    let count: Int?
    var body: some View {
        if let n = count, n > 0 {
            Text("✓ +\(n)")
                .font(.caption.weight(.bold))
                .foregroundColor(Palette.amber)
        }
    }
}

@available(iOS 16.2, *)
private struct LockScreenView: View {
    let context: ActivityViewContext<OutingActivityAttributes>

    var body: some View {
        let s = context.state
        let id = context.attributes.outingId
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                Image("LogoCap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text(titleText(s))
                        .font(.headline)
                        .foregroundColor(Palette.text)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(countText(s))
                            .font(.subheadline)
                            .foregroundColor(Palette.muted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        QuickLoggedBadge(count: s.quickLogged)
                    }
                }
                Spacer(minLength: 8)
                Elapsed(since: s.startedAt)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(Palette.amber)
                    .frame(maxWidth: 96, alignment: .trailing)
            }
            if let spend = spendText(s) {
                Text(spend)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(Palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            HStack(spacing: 8) {
                Chip(title: s.texts?.open ?? "Abrir", url: link(id, "open"))
                if let next = s.nextLabel {
                    AnotherChip(title: s.texts?.anotherWith ?? "Mais uma · \(next)", outingId: id)
                }
                Chip(title: s.texts?.water ?? "Água", url: link(id, "water"))
            }
        }
        .padding(16)
        .activityBackgroundTint(Palette.background)
        .activitySystemActionForegroundColor(Palette.amber)
        .widgetURL(link(id, "open"))
    }
}

@available(iOS 16.2, *)
struct OutingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OutingActivityAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            let s = context.state
            let id = context.attributes.outingId
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image("LogoCap")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Elapsed(since: s.startedAt)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Palette.amber)
                        .frame(maxWidth: 90, alignment: .trailing)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(titleText(s))
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text(countText(s))
                                .font(.subheadline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            QuickLoggedBadge(count: s.quickLogged)
                        }
                        if let spend = spendText(s) {
                            Text(spend)
                                .font(.subheadline.weight(.medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        HStack(spacing: 8) {
                            Chip(title: s.texts?.open ?? "Abrir", url: link(id, "open"))
                            if let next = s.nextLabel {
                                AnotherChip(title: s.texts?.another ?? "Mais uma", outingId: id)
                                    .accessibilityLabel(s.texts?.anotherA11y ?? "Mais uma, \(next)")
                            }
                            Chip(title: s.texts?.water ?? "Água", url: link(id, "water"))
                        }
                    }
                }
            } compactLeading: {
                Image("LogoCap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            } compactTrailing: {
                // Only the essential: the running time.
                Elapsed(since: s.startedAt)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Palette.amber)
                    .frame(maxWidth: 56)
            } minimal: {
                Image("LogoCap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .widgetURL(link(id, "open"))
            .keylineTint(Palette.amber)
        }
    }
}
