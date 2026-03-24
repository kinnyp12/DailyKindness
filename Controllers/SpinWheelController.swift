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
    @Published var filterCategory: ChallengeCategory? = nil   // nil = all categories

    private let challengeKey = "kindness.currentChallenge"
    private let streakKey    = "kindness.streak"
    private var spinTimer: Timer?

    // Spin physics
    private var spinVelocity: Double = 0
    private var displayLink: CADisplayLink?

    init() {
        loadFromDisk()
    }

    // MARK: - Spin

    func spin() {
        guard !isSpinning else { return }

        isSpinning = true
        currentChallenge = nil

        // Pick a challenge first (so we know where to land)
        let pool = filteredChallenges
        guard let picked = pool.randomElement() else {
            isSpinning = false
            return
        }

        // Calculate how much to rotate — enough full turns plus the landing angle
        let fullRotations = Double(Int.random(in: 5...9)) * 360
        let additionalAngle = Double.random(in: 0..<360)
        let totalSpin = fullRotations + additionalAngle

        withAnimation(.timingCurve(0.15, 0.85, 0.38, 1.0, duration: 3.2)) {
            spinDegrees += totalSpin
        }

        // Reveal the challenge once the animation settles
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) { [weak self] in
            self?.currentChallenge = picked
            self?.isSpinning = false

            let haptic = UIImpactFeedbackGenerator(style: .heavy)
            haptic.impactOccurred()
        }
    }

    // MARK: - Mark complete

    func markComplete(_ challenge: KindnessChallenge) {
        recentlyCompleted = challenge
        updateStreak(for: challenge)
        showCompletionSheet = true
        saveChallenge()

        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(.success)
    }

    func skipChallenge() {
        currentChallenge = nil
        // No streak impact for skipping — life happens
    }

    // MARK: - Category Filter

    var filteredChallenges: [KindnessChallenge] {
        guard let filter = filterCategory else { return KindnessChallenge.allChallenges }
        return KindnessChallenge.allChallenges.filter { $0.category == filter }
    }

    var wheelSegments: [WheelSegment] {
        // Build segments for the visual wheel — one per category
        ChallengeCategory.allCases.enumerated().map { index, cat in
            WheelSegment(
                index: index,
                total: ChallengeCategory.allCases.count,
                category: cat
            )
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

    private func updateStreak(for challenge: KindnessChallenge) {
        // Avoid double-counting the same challenge on the same day
        if streakRecord.completedIDs.contains(challenge.id) { return }

        streakRecord.completedIDs.append(challenge.id)
        streakRecord.totalCompleted += 1

        if streakRecord.isCompletedToday {
            // Already counted today — just add to completed list
        } else if streakRecord.streakIsAlive {
            streakRecord.currentStreak += 1
        } else {
            // Streak broken — restart from 1
            streakRecord.currentStreak = 1
        }

        streakRecord.longestStreak = max(streakRecord.longestStreak, streakRecord.currentStreak)
        streakRecord.lastCompletedDate = Date()

        saveStreak()
    }

    private func saveChallenge() {
        if let encoded = try? JSONEncoder().encode(currentChallenge) {
            UserDefaults.standard.set(encoded, forKey: challengeKey)
        }
    }

    private func saveStreak() {
        if let encoded = try? JSONEncoder().encode(streakRecord) {
            UserDefaults.standard.set(encoded, forKey: streakKey)
        }
    }

    private func loadFromDisk() {
        if let data = UserDefaults.standard.data(forKey: challengeKey),
           let challenge = try? JSONDecoder().decode(KindnessChallenge.self, from: data) {
            // Only restore today's challenge — fresh wheel each day
            currentChallenge = nil  // always start fresh; challenge is ephemeral
            _ = challenge           // loaded but intentionally not displayed
        }
        if let data = UserDefaults.standard.data(forKey: streakKey),
           let streak = try? JSONDecoder().decode(StreakRecord.self, from: data) {
            streakRecord = streak
            // Reset streak if more than 2 days have passed without completing
            if let last = streak.lastCompletedDate {
                let daysSince = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
                if daysSince > 1 {
                    streakRecord.currentStreak = 0
                    saveStreak()
                }
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

    var startAngle: Angle { Angle(degrees: Double(index) / Double(total) * 360) }
    var endAngle: Angle   { Angle(degrees: Double(index + 1) / Double(total) * 360) }
    var midAngle: Angle   { Angle(degrees: (startAngle.degrees + endAngle.degrees) / 2) }
}
