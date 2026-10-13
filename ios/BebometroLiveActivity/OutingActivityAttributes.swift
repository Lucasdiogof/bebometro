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
        }
    }

    /// Identifies the outing this activity belongs to.
    var outingId: String
}
#endif
