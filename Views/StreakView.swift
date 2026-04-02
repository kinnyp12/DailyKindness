import SwiftUI

// MARK: - StreakView

struct StreakView: View {

    @EnvironmentObject var controller: SpinWheelController

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    streakHeader
                    statsGrid
                    categorySection
                    motivationCard
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Your Progress")
            // ✅ FIX: Use navigationDestination(for:) so views are created ONLY
            // when actually navigated to, not when the list is first rendered.
            .navigationDestination(for: ChallengeCategory.self) { category in
                CategoryDetailView(category: category)
            }
        }
    }

    // MARK: - Streak ring

    private var streakHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.orange.opacity(0.15), .pink.opacity(0.15)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 130, height: 130)

                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange).font(.title)
                        Text("\(controller.streakRecord.currentStreak)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                    }
                    Text("day streak")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)

            Text(controller.streakMessage)
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).padding(.horizontal, 32)
        }
    }

    // MARK: - Stats — now includes bonus points and shares

    private var statsGrid: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    value: "\(controller.streakRecord.totalCompleted)",
                    label: "Completed",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                StatCard(
                    value: "\(controller.streakRecord.longestStreak)",
                    label: "Best streak",
                    icon: "trophy.fill",
                    color: .yellow
                )
                StatCard(
                    value: "\(controller.streakRecord.sharedChallengeIDs.count)",
                    label: "Challenges shared",
                    icon: "square.and.arrow.up.fill",
                    color: .blue
                )
                StatCard(
                    value: "+\(controller.streakRecord.bonusPoints)",
                    label: "Referral bonus pts",
                    icon: "star.fill",
                    color: .pink
                )
            }

            // Total score banner
            HStack {
                Image(systemName: "rosette")
                    .foregroundStyle(.purple)
                Text("Total score")
                    .font(.subheadline).fontWeight(.medium)
                Spacer()
                Text("\(controller.streakRecord.totalScore) pts")
                    .font(.title3).fontWeight(.bold)
                    .foregroundStyle(.purple)
            }
            .padding(14)
            .background(Color.purple.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.purple.opacity(0.2), lineWidth: 1))
        }
    }

    // MARK: - Category rows — using NavigationLink(value:) for instant navigation

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Explore categories")
                .font(.headline)

            ForEach(ChallengeCategory.allCases) { category in
                let challenges = KindnessChallenge.allChallenges.filter { $0.category == category }
                let completedCount = challenges.filter {
                    controller.streakRecord.completedIDs.contains($0.id)
                }.count

                // ✅ FIX: NavigationLink(value:) — does NOT initialise the destination
                // view until the user actually taps. This is why the page was slow.
                NavigationLink(value: category) {
                    CategoryRow(
                        category: category,
                        total: challenges.count,
                        completed: completedCount
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Motivation footer

    private var motivationCard: some View {
        VStack(spacing: 10) {
            Text("💌").font(.title)
            Text("Small acts of kindness ripple out in ways you'll never fully see. Every challenge matters.")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).lineSpacing(4)
        }
        .padding(20).frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - CategoryRow

struct CategoryRow: View {
    let category: ChallengeCategory
    let total: Int
    let completed: Int

    private var fraction: Double { total > 0 ? Double(completed) / Double(total) : 0 }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(category.color.opacity(0.15), lineWidth: 3)
                    .frame(width: 46, height: 46)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(category.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 46, height: 46)
                    .rotationEffect(.degrees(-90))
                Text(category.emoji).font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(category.rawValue)
                    .font(.subheadline).fontWeight(.semibold).foregroundStyle(.primary)
                Text("\(completed)/\(total) completed")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            if completed == total && total > 0 {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(category.color).font(.system(size: 18))
            }

            Image(systemName: "chevron.right")
                .font(.caption).foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - StatCard

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(value).font(.system(size: 28, weight: .bold, design: .rounded))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
