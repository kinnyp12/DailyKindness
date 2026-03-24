import SwiftUI

// MARK: - StreakView (MVC: View)

struct StreakView: View {

    @EnvironmentObject var controller: SpinWheelController

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    streakHeader
                    statsGrid
                    categoryBreakdown
                    motivationCard
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Your Progress")
        }
    }

    // MARK: - Streak Header

    private var streakHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.orange.opacity(0.15), Color.pink.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 130, height: 130)

                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .font(.title)
                        Text("\(controller.streakRecord.currentStreak)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                    }
                    Text("day streak")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)

            Text(controller.streakMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                value: "\(controller.streakRecord.totalCompleted)",
                label: "Total done",
                icon: "checkmark.circle.fill",
                color: .green
            )
            StatCard(
                value: "\(controller.streakRecord.longestStreak)",
                label: "Best streak",
                icon: "trophy.fill",
                color: .yellow
            )
        }
    }

    // MARK: - Category Breakdown

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Explore all categories")
                .font(.headline)

            ForEach(ChallengeCategory.allCases) { category in
                let count = KindnessChallenge.allChallenges.filter { $0.category == category }.count
                HStack(spacing: 12) {
                    Text(category.emoji)
                        .font(.title3)
                        .frame(width: 36, height: 36)
                        .background(category.color.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(count) challenges")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Motivation

    private var motivationCard: some View {
        VStack(spacing: 10) {
            Text("💌")
                .font(.title)

            Text("Small acts of kindness ripple out in ways you'll never fully see. Every challenge matters.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
