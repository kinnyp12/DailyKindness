import Foundation
import SwiftUI
import Combine

// MARK: - SpinWheelController (MVC: Controller)

final class SpinWheelController: ObservableObject {

    @Published var currentChallenge: KindnessChallenge?
    @Published var streakRecord: StreakRecord = .empty
    @Published var isSpinning: Bool = false
    @Published var spinDegrees: Double = 0
    @Published var showCompletionSheet: Bool = false
    @Published var recentlyCompleted: KindnessChallenge?
    @Published var filterCategory: ChallengeCategory? = nil

    // Deep-link state — set when app opened via shared link
    @Published var deepLinkedChallenge: KindnessChallenge? = nil
    @Published var openedViaShare: Bool = false   // shows "Shared with you" banner

    private let streakKey = "kindness.streak"

    init() { loadFromDisk() }

    // MARK: - Spin

    func spin() {
        guard !isSpinning else { return }
        isSpinning = true
        currentChallenge = nil

        let pool = filteredChallenges
        guard let picked = pool.randomElement() else { isSpinning = false; return }

        let totalSpin = Double(Int.random(in: 5...9)) * 360 + Double.random(in: 0..<360)
        withAnimation(.timingCurve(0.15, 0.85, 0.38, 1.0, duration: 3.2)) {
            spinDegrees += totalSpin
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) { [weak self] in
            self?.currentChallenge = picked
            self?.isSpinning = false
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }

    // MARK: - Complete

    func markComplete(_ challenge: KindnessChallenge, viaShare: Bool = false) {
        recentlyCompleted = challenge
        updateStreak(for: challenge, viaShare: viaShare)
        showCompletionSheet = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func skipChallenge() { currentChallenge = nil }

    // MARK: - Deep link handler
    // URL format: kindnesswheel://challenge?id=<UUID>&bonus=1
    // bonus=1 means the SHARER earns a referral point when you complete it.

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "kindnesswheel",
              url.host == "challenge" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let idString = components?.queryItems?.first(where: { $0.name == "id" })?.value,
              let id = UUID(uuidString: idString),
              let challenge = KindnessChallenge.find(id: id) else { return }

        let hasBonus = components?.queryItems?.first(where: { $0.name == "bonus" })?.value == "1"

        deepLinkedChallenge = challenge
        openedViaShare = true

        // If the share link carries a bonus flag, award the sharer a referral point.
        // In a real app this would ping a server; here we award it locally as a
        // "kindness credit" to the person who opened the link, for spreading kindness.
        if hasBonus {
            streakRecord.bonusPoints += 3   // +3 for completing a challenge someone shared
            saveStreak()
        }
    }

    // MARK: - Share link builder
    // Generates the URL and the full shareable message for a challenge.

    func shareLink(for challenge: KindnessChallenge) -> URL {
        // Register sharedChallengeIDs so we can track it
        if !streakRecord.sharedChallengeIDs.contains(challenge.id) {
            streakRecord.sharedChallengeIDs.append(challenge.id)
            saveStreak()
        }
        // bonus=1 tells the recipient's app to credit the sharer with bonus points
        var comps = URLComponents()
        comps.scheme = "kindnesswheel"
        comps.host   = "challenge"
        comps.queryItems = [
            URLQueryItem(name: "id",    value: challenge.id.uuidString),
            URLQueryItem(name: "bonus", value: "1"),
        ]
        return comps.url!
    }

    func shareMessage(for challenge: KindnessChallenge) -> String {
        let link = shareLink(for: challenge)
        return """
        Hey! I just found this kindness challenge and thought of you 💛

        "\(challenge.title)"

        \(challenge.description)

        Try it yourself — open this link to jump straight to the challenge:
        \(link.absoluteString)

        (Download Kindness Wheel if you don't have it yet — it's free)
        """
    }

    // MARK: - Helpers

    var filteredChallenges: [KindnessChallenge] {
        guard let filter = filterCategory else { return KindnessChallenge.allChallenges }
        return KindnessChallenge.allChallenges.filter { $0.category == filter }
    }

    var wheelSegments: [WheelSegment] {
        ChallengeCategory.allCases.enumerated().map { index, cat in
            WheelSegment(index: index, total: ChallengeCategory.allCases.count, category: cat)
        }
    }

    var streakMessage: String {
        switch streakRecord.currentStreak {
        case 0:       return "Start your kindness streak today!"
        case 1:       return "Day 1 — every journey starts here 🌱"
        case 2...6:   return "\(streakRecord.currentStreak) days in — you're building something great!"
        case 7...13:  return "One week strong! You're officially a kindness habit 🔥"
        case 14...29: return "\(streakRecord.currentStreak) days! The world needs more of you."
        default:      return "\(streakRecord.currentStreak) day streak! You're extraordinary 🌟"
        }
    }

    // MARK: - Private

    private func updateStreak(for challenge: KindnessChallenge, viaShare: Bool = false) {
        guard !streakRecord.completedIDs.contains(challenge.id) else { return }

        streakRecord.completedIDs.append(challenge.id)
        streakRecord.totalCompleted += 1

        if viaShare {
            streakRecord.completedViaShareIDs.append(challenge.id)
        }

        if streakRecord.isCompletedToday {
            // already counted today
        } else if streakRecord.streakIsAlive {
            streakRecord.currentStreak += 1
        } else {
            streakRecord.currentStreak = 1
        }

        streakRecord.longestStreak = max(streakRecord.longestStreak, streakRecord.currentStreak)
        streakRecord.lastCompletedDate = Date()
        saveStreak()
    }

    private func saveStreak() {
        if let encoded = try? JSONEncoder().encode(streakRecord) {
            UserDefaults.standard.set(encoded, forKey: streakKey)
        }
    }

    private func loadFromDisk() {
        if let data = UserDefaults.standard.data(forKey: streakKey),
           let streak = try? JSONDecoder().decode(StreakRecord.self, from: data) {
            streakRecord = streak
            if let last = streak.lastCompletedDate {
                let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
                if days > 1 { streakRecord.currentStreak = 0; saveStreak() }
            }
        }
    }
}

// MARK: - WheelSegment

struct WheelSegment: Identifiable {
    let id = UUID()
    let index: Int
    let total: Int
    let category: ChallengeCategory

    var startAngle: Angle { .degrees(Double(index) / Double(total) * 360) }
    var endAngle: Angle   { .degrees(Double(index + 1) / Double(total) * 360) }
    var midAngle: Angle   { .degrees((startAngle.degrees + endAngle.degrees) / 2) }
}
