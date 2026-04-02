import SwiftUI

// MARK: - CategoryDetailView
// Lazy-loaded by navigationDestination(for: ChallengeCategory.self) in StreakView.
// Opens instantly because it is not initialised until actually navigated to.

struct CategoryDetailView: View {

    @EnvironmentObject var controller: SpinWheelController
    let category: ChallengeCategory

    @State private var selectedDifficulty: Difficulty? = nil
    @State private var selectedChallenge: KindnessChallenge? = nil

    private var allChallenges: [KindnessChallenge] {
        KindnessChallenge.allChallenges.filter { $0.category == category }
    }

    private var visible: [KindnessChallenge] {
        guard let d = selectedDifficulty else { return allChallenges }
        return allChallenges.filter { $0.difficulty == d }
    }

    private var completedCount: Int {
        allChallenges.filter { controller.streakRecord.completedIDs.contains($0.id) }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                categoryHero
                    .padding(.bottom, 20)

                difficultyTabs
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                LazyVStack(spacing: 12) {
                    ForEach(visible) { challenge in
                        ChallengeListCard(
                            challenge: challenge,
                            isCompleted: controller.streakRecord.completedIDs.contains(challenge.id)
                        ) {
                            selectedChallenge = challenge
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        // ✅ navigationDestination inside this view handles the challenge detail push
        .navigationDestination(for: KindnessChallenge.self) { challenge in
            ChallengeDetailView(challenge: challenge)
        }
        // We use a programmatic push via selectedChallenge state
        .background(
            NavigationLink(
                destination: selectedChallenge.map { ChallengeDetailView(challenge: $0) },
                isActive: Binding(
                    get: { selectedChallenge != nil },
                    set: { if !$0 { selectedChallenge = nil } }
                )
            ) { EmptyView() }
        )
    }

    // MARK: - Hero header

    private var categoryHero: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [category.color.opacity(0.85), category.color.opacity(0.45)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 190)

            VStack(spacing: 12) {
                Text(category.emoji).font(.system(size: 52))

                VStack(spacing: 6) {
                    HStack {
                        Text("\(completedCount) of \(allChallenges.count) completed")
                            .font(.caption).fontWeight(.medium).foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        Text("\(Int(Double(completedCount) / Double(max(allChallenges.count,1)) * 100))%")
                            .font(.caption).fontWeight(.bold).foregroundStyle(.white)
                    }
                    .padding(.horizontal, 24)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.25)).frame(height: 6)
                            Capsule().fill(.white)
                                .frame(
                                    width: geo.size.width * CGFloat(completedCount) / CGFloat(max(allChallenges.count,1)),
                                    height: 6
                                )
                                .animation(.spring(response: 0.5), value: completedCount)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Difficulty tabs

    private var difficultyTabs: some View {
        HStack(spacing: 8) {
            DifficultyTab(label: "All", color: .primary, isSelected: selectedDifficulty == nil) {
                withAnimation(.spring(response: 0.3)) { selectedDifficulty = nil }
            }
            ForEach(Difficulty.allCases, id: \.self) { diff in
                DifficultyTab(label: diff.rawValue, color: diff.color,
                              isSelected: selectedDifficulty == diff) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDifficulty = selectedDifficulty == diff ? nil : diff
                    }
                }
            }
        }
    }
}

// MARK: - DifficultyTab

struct DifficultyTab: View {
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption).fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? color : .secondary)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(isSelected ? color.opacity(0.12) : Color(.secondarySystemBackground))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? color : Color.clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ChallengeListCard

struct ChallengeListCard: View {
    let challenge: KindnessChallenge
    let isCompleted: Bool
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isCompleted
                              ? challenge.category.color.opacity(0.15)
                              : Color(.tertiarySystemBackground))
                        .frame(width: 40, height: 40)
                    Image(systemName: isCompleted ? "checkmark" : "circle")
                        .font(.system(size: isCompleted ? 15 : 20, weight: .bold))
                        .foregroundStyle(isCompleted ? challenge.category.color : Color(.tertiaryLabel))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(challenge.title)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted)
                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                    DifficultyBadge(difficulty: challenge.difficulty)
                }

                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isCompleted ? challenge.category.color.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .scaleEffect(pressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { pressed = true  } }
                .onEnded   { _ in withAnimation(.easeInOut(duration: 0.12)) { pressed = false } }
        )
    }
}
