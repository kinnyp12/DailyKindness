import SwiftUI

// MARK: - ChallengeCardView (MVC: View)

struct ChallengeCardView: View {

    @EnvironmentObject var controller: SpinWheelController
    let challenge: KindnessChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header row
            HStack {
                HStack(spacing: 6) {
                    Text(challenge.category.emoji)
                    Text(challenge.category.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(challenge.category.color)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(challenge.category.color.opacity(0.12))
                .clipShape(Capsule())

                Spacer()

                DifficultyBadge(difficulty: challenge.difficulty)
            }

            // Challenge content
            Text(challenge.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Text(challenge.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)

            Divider()

            // Actions
            HStack(spacing: 12) {
                Button {
                    controller.skipChallenge()
                } label: {
                    Text("Skip")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    controller.markComplete(challenge)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                        Text("I did it!")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(challenge.category.color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: challenge.category.color.opacity(0.2), radius: 16, x: 0, y: 8)
    }
}

// MARK: - DifficultyBadge

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.label)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(difficulty.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(difficulty.color.opacity(0.12))
            .clipShape(Capsule())
    }
}

// MARK: - CompletionSheet

struct CompletionSheet: View {

    @EnvironmentObject var controller: SpinWheelController
    @Environment(\.dismiss) private var dismiss
    let challenge: KindnessChallenge

    @State private var emojiScale: CGFloat = 0.2
    @State private var showDetails = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Celebration emoji
            Text("🌟")
                .font(.system(size: 80))
                .scaleEffect(emojiScale)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: emojiScale)

            VStack(spacing: 8) {
                Text("Challenge complete!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("You completed:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(""\(challenge.title)"")
                    .font(.headline)
                    .foregroundStyle(challenge.category.color)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(showDetails ? 1 : 0)
            .offset(y: showDetails ? 0 : 12)
            .animation(.easeOut(duration: 0.4).delay(0.3), value: showDetails)

            // Streak info
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill").foregroundStyle(.orange)
                    Text("\(controller.streakRecord.currentStreak) day streak")
                        .fontWeight(.semibold)
                }
                .font(.title3)

                Text(controller.streakMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 32)
            .opacity(showDetails ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.5), value: showDetails)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Keep spreading kindness ✨")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.96, green: 0.45, blue: 0.65), Color(red: 0.56, green: 0.42, blue: 0.86)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(showDetails ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.7), value: showDetails)
        }
        .onAppear {
            emojiScale = 1.0
            showDetails = true
        }
    }
}
