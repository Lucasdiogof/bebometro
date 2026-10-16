import Foundation

#if canImport(ActivityKit)
import ActivityKit

/// Shared by the app (which starts and updates the activity) and the widget
/// extension (which draws it). It carries only what the lock screen shows,
/// already filtered by the user's choices in Flutter: no address, notes,
/// photos, ABV or any record id except the outing id used to open the app.
@available(iOS 16.2, *)
struct OutingActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Start of the outing; the system draws the running time from it.
        var startedAt: Date
        /// Alcoholic drink RECORDS (water excluded, a shared bottle is one).
        var alcoholicCount: Int
        /// Informed spending on drinks in cents; nil = hidden by the user.
        var spendCents: Int?
        /// Records with no price, for "2 sem preço".
        var unpricedCount: Int
        /// Nickname of the place; nil = shows "Rolê em andamento".
        var place: String?
        /// "Chopp 400 ml" when "Mais uma" exists, otherwise nil.
        var nextLabel: String?
        /// "+N aguardando registro": one-tap "Mais uma" commands queued on the
        /// lock screen and NOT yet saved by the app. Set only by the button
        /// itself; every real update from Flutter replaces the state without it.
        var quickLogged: Int? = nil
        /// Ready-made texts in the language chosen in the app (not the
        /// system's). Optional: an activity started by an older build has
        /// none, and the widget then uses its Portuguese wording.
        var texts: Texts?

        struct Texts: Codable, Hashable {
            var title: String?
            var count: String?
            var spend: String?
            var open: String?
            var another: String?
            var anotherWith: String?
            var anotherA11y: String?
            var water: String?
            /// "aguardando registro" in the app's language.
            var pending: String?
        }

        /// Record that "Mais uma" repeats right now (the one [nextLabel]
        /// names). A tap stores it in the command, so the drink is the one
        /// the person saw, not whatever is last when the app processes it.
        var repeatEntryId: String? = nil
        /// Account that owns the outing; a tap stores it in the command.
        var accountId: String? = nil
    }

    /// Identifies the outing this activity belongs to.
    var outingId: String
}
#endif
