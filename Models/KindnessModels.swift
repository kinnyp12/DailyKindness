import Foundation
import SwiftUI

// MARK: - KindnessChallenge

struct KindnessChallenge: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let category: ChallengeCategory
    let difficulty: Difficulty

    init(id: UUID = UUID(), title: String, description: String, category: ChallengeCategory, difficulty: Difficulty) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
    }
}

// MARK: - Category

enum ChallengeCategory: String, Codable, CaseIterable, Identifiable {
    case strangers    = "Strangers"
    case friends      = "Friends"
    case family       = "Family"
    case colleagues   = "Colleagues"
    case yourself     = "Self-care"
    case community    = "Community"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .strangers:  return Color(red: 0.98, green: 0.48, blue: 0.38)   // warm coral
        case .friends:    return Color(red: 0.56, green: 0.42, blue: 0.86)   // soft purple
        case .family:     return Color(red: 0.38, green: 0.76, blue: 0.55)   // sage green
        case .colleagues: return Color(red: 0.27, green: 0.63, blue: 0.90)   // sky blue
        case .yourself:   return Color(red: 0.98, green: 0.75, blue: 0.28)   // golden
        case .community:  return Color(red: 0.96, green: 0.45, blue: 0.65)   // pink
        }
    }

    var emoji: String {
        switch self {
        case .strangers:  return "🤝"
        case .friends:    return "💜"
        case .family:     return "🏡"
        case .colleagues: return "💼"
        case .yourself:   return "🌟"
        case .community:  return "🌍"
        }
    }
}

// MARK: - Difficulty

enum Difficulty: String, Codable, CaseIterable {
    case easy   = "Easy"
    case medium = "Medium"
    case bold   = "Bold"

    var label: String {
        switch self {
        case .easy:   return "Quick win"
        case .medium: return "Takes effort"
        case .bold:   return "Step it up"
        }
    }

    var color: Color {
        switch self {
        case .easy:   return .green
        case .medium: return .orange
        case .bold:   return .red
        }
    }
}

// MARK: - Streak Record

struct StreakRecord: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var totalCompleted: Int
    var lastCompletedDate: Date?
    var completedIDs: [UUID]   // so we don't count the same challenge twice in one day

    static var empty: StreakRecord {
        StreakRecord(currentStreak: 0, longestStreak: 0, totalCompleted: 0, lastCompletedDate: nil, completedIDs: [])
    }

    var isCompletedToday: Bool {
        guard let last = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    var streakIsAlive: Bool {
        // Streak stays alive if they completed something today or yesterday
        guard let last = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(last) || Calendar.current.isDateInYesterday(last)
    }
}

// MARK: - Challenge Bank
// All the built-in challenges. Deliberately varied in category and difficulty.

extension KindnessChallenge {

    static let allChallenges: [KindnessChallenge] = [

        // Strangers
        KindnessChallenge(title: "Smile at a stranger",
                          description: "Make genuine eye contact and smile at someone you pass today. No words needed — a smile says everything.",
                          category: .strangers, difficulty: .easy),
        KindnessChallenge(title: "Pay it forward at a café",
                          description: "Buy a coffee for the person behind you in line. You might make their entire day.",
                          category: .strangers, difficulty: .medium),
        KindnessChallenge(title: "Help someone who looks lost",
                          description: "If you see someone checking their phone map or looking confused, ask if they need directions.",
                          category: .strangers, difficulty: .medium),
        KindnessChallenge(title: "Leave a generous tip",
                          description: "Tip your server or barista more generously than usual and leave a kind note on the receipt.",
                          category: .strangers, difficulty: .bold),
        KindnessChallenge(title: "Compliment someone's style",
                          description: "Find something genuine to compliment on a stranger — their bag, their jacket, their energy.",
                          category: .strangers, difficulty: .easy),

        // Friends
        KindnessChallenge(title: "Text an old friend",
                          description: "Reach out to someone you haven't spoken to in a while. A simple 'thinking of you' goes a long way.",
                          category: .friends, difficulty: .easy),
        KindnessChallenge(title: "Write a heartfelt note",
                          description: "Write a physical note to a close friend telling them exactly why you value them. Post it or hand it to them.",
                          category: .friends, difficulty: .medium),
        KindnessChallenge(title: "Plan a surprise for a friend",
                          description: "Organise something small but unexpected — their favourite snack, a playlist, a movie night. Surprise them today.",
                          category: .friends, difficulty: .bold),
        KindnessChallenge(title: "Really listen",
                          description: "In your next conversation with a friend, put your phone away and give them your complete, undivided attention.",
                          category: .friends, difficulty: .easy),

        // Family
        KindnessChallenge(title: "Call a parent or grandparent",
                          description: "Pick up the phone and have a real conversation. Ask how they're doing — and actually listen.",
                          category: .family, difficulty: .easy),
        KindnessChallenge(title: "Cook a meal for the family",
                          description: "Make a meal for your household without being asked. Clean up afterwards too.",
                          category: .family, difficulty: .medium),
        KindnessChallenge(title: "Write a letter to a sibling",
                          description: "Tell your sibling something you've always appreciated about them. Send it — even as a text.",
                          category: .family, difficulty: .medium),
        KindnessChallenge(title: "Apologise for something old",
                          description: "Is there something you've been meaning to apologise for? Today is the day. Be genuine.",
                          category: .family, difficulty: .bold),

        // Colleagues
        KindnessChallenge(title: "Publicly recognise a teammate",
                          description: "Give a shoutout in a team meeting or Slack channel for a colleague's work. Be specific.",
                          category: .colleagues, difficulty: .easy),
        KindnessChallenge(title: "Offer to help with a task",
                          description: "Find a colleague who looks overloaded and offer to take something off their plate.",
                          category: .colleagues, difficulty: .medium),
        KindnessChallenge(title: "Bring something for the office",
                          description: "Bring snacks, fruit, or coffee for your team without any occasion. Just because.",
                          category: .colleagues, difficulty: .easy),
        KindnessChallenge(title: "Mentor someone junior",
                          description: "Spend 15 minutes sharing knowledge or career advice with someone more junior than you.",
                          category: .colleagues, difficulty: .bold),

        // Self-care
        KindnessChallenge(title: "Take a no-phone morning",
                          description: "Keep your phone in another room for the first hour after waking up. See how it changes your mood.",
                          category: .yourself, difficulty: .medium),
        KindnessChallenge(title: "Write three things you're proud of",
                          description: "Grab a pen and write down three things about yourself that you're genuinely proud of.",
                          category: .yourself, difficulty: .easy),
        KindnessChallenge(title: "Do something you've been putting off",
                          description: "Pick one thing from your mental 'I should do that' list and do it today. You'll feel lighter.",
                          category: .yourself, difficulty: .bold),
        KindnessChallenge(title: "Take a mindful walk",
                          description: "Go for a 15-minute walk with no destination and no podcasts. Just notice what's around you.",
                          category: .yourself, difficulty: .easy),

        // Community
        KindnessChallenge(title: "Pick up litter on your street",
                          description: "Spend 5 minutes picking up litter on your block or in a nearby park. Small actions add up.",
                          category: .community, difficulty: .easy),
        KindnessChallenge(title: "Donate to a local cause",
                          description: "Find a local charity, food bank, or shelter and make a small donation — or donate items you no longer need.",
                          category: .community, difficulty: .medium),
        KindnessChallenge(title: "Leave a kind review",
                          description: "Write a genuine 5-star review for a small local business that has served you well.",
                          category: .community, difficulty: .easy),
        KindnessChallenge(title: "Volunteer for an hour",
                          description: "Find a local volunteering opportunity and show up. Even one hour makes a difference.",
                          category: .community, difficulty: .bold)
    ]
}
