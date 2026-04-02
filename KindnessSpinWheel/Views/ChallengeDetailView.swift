import SwiftUI

// MARK: - ChallengeDetailView
// Full page (navigation push) showing a single challenge with:
//  - Description + tips
//  - Mark complete (with bonus flag if opened via share link)
//  - Share button that generates a real deep link + message

struct ChallengeDetailView: View {

    @EnvironmentObject var controller: SpinWheelController
    @Environment(\.dismiss) private var dismiss

    let challenge: KindnessChallenge

    @State private var showCelebration = false
    @State private var celebrationScale: CGFloat = 0.3

    private var isCompleted: Bool {
        controller.streakRecord.completedIDs.contains(challenge.id)
    }

    private var openedViaShare: Bool {
        controller.deepLinkedChallenge?.id == challenge.id && controller.openedViaShare
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeader
                bodyContent
                    .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            actionBar
                .padding()
                .background(.ultraThinMaterial)
        }
        .overlay(celebrationOverlay)
    }

    // MARK: - Hero

    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [challenge.category.color.opacity(0.85), challenge.category.color.opacity(0.4)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(height: 200)

            VStack(spacing: 10) {
                Text(challenge.category.emoji).font(.system(size: 50))

                // "Shared with you" banner — appears when opened via deep link
                if openedViaShare {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.caption)
                        Text("Shared with you — bonus points if you complete this!")
                            .font(.caption).fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
                }

                Text(challenge.title)
                    .font(.title3).fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Body content

    private var bodyContent: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Description
            VStack(alignment: .leading, spacing: 10) {
                Label("The challenge", systemImage: "sparkles")
                    .font(.caption).fontWeight(.semibold).foregroundStyle(.secondary)
                Text(challenge.description)
                    .font(.body).lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            // Tips
            VStack(alignment: .leading, spacing: 12) {
                Label("Tips to succeed", systemImage: "lightbulb.fill")
                    .font(.caption).fontWeight(.semibold).foregroundStyle(.secondary)
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(challenge.category.color)
                            .font(.system(size: 15)).padding(.top, 1)
                        Text(tip).font(.subheadline).foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            Divider()

            // Meta row
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Difficulty").font(.caption).foregroundStyle(.secondary)
                    DifficultyBadge(difficulty: challenge.difficulty)
                }
                Divider().frame(height: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category").font(.caption).foregroundStyle(.secondary)
                    HStack(spacing: 5) {
                        Text(challenge.category.emoji)
                        Text(challenge.category.rawValue)
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(challenge.category.color)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(challenge.category.color.opacity(0.1))
                    .clipShape(Capsule())
                }

                // Bonus points preview when opened via share
                if openedViaShare {
                    Divider().frame(height: 36)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bonus").font(.caption).foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundStyle(.pink).font(.caption)
                            Text("+3 pts").font(.caption).fontWeight(.bold).foregroundStyle(.pink)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.pink.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Action bar (pinned to bottom)

    private var actionBar: some View {
        VStack(spacing: 10) {
            if isCompleted {
                // Already done state
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    Text("You've completed this challenge!")
                        .font(.subheadline).fontWeight(.medium).foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(Color.green.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            } else {
                // Complete button
                Button {
                    complete()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark").fontWeight(.bold)
                        Text(openedViaShare ? "I did it! (+3 bonus points)" : "I did it! Mark complete")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(challenge.category.color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: challenge.category.color.opacity(0.35), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)
            }

            // Share button — always visible
            ShareLink(
                item: controller.shareMessage(for: challenge),
                subject: Text("Kindness challenge for you")
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share with a friend (+3 pts for them)")
                }
                .font(.subheadline).fontWeight(.medium)
                .frame(maxWidth: .infinity).padding(.vertical, 13)
                .background(Color(.secondarySystemBackground))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(challenge.category.color.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Celebration overlay

    private var celebrationOverlay: some View {
        Group {
            if showCelebration {
                ZStack {
                    Color.black.opacity(0.55).ignoresSafeArea()

                    VStack(spacing: 16) {
                        Text("🎉")
                            .font(.system(size: 80))
                            .scaleEffect(celebrationScale)

                        Text("Challenge complete!")
                            .font(.title2).fontWeight(.bold).foregroundStyle(.white)

                        if openedViaShare {
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill").foregroundStyle(.yellow)
                                Text("+3 bonus points earned!")
                                    .font(.headline).foregroundStyle(.yellow)
                            }
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(.white.opacity(0.12))
                            .clipShape(Capsule())
                        }

                        Text("Streak updated 🔥")
                            .font(.subheadline).foregroundStyle(.white.opacity(0.8))
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showCelebration)
    }

    // MARK: - Helpers

    private func complete() {
        controller.markComplete(challenge, viaShare: openedViaShare)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
            showCelebration = true
            celebrationScale = 1.0
        }

        // Clear deep link state after completion
        if openedViaShare {
            controller.deepLinkedChallenge = nil
            controller.openedViaShare = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { showCelebration = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                dismiss()
            }
        }
    }

    private var tips: [String] {
        switch challenge.category {
        case .strangers:
            return [
                "Make eye contact first — it signals your intention before you speak.",
                "Keep it brief and genuine. One kind sentence is enough.",
                "If it feels awkward, that's normal. Do it anyway."
            ]
        case .friends:
            return [
                "Be specific — vague compliments feel less real.",
                "Send it now before you talk yourself out of it.",
                "A voice note feels more personal than a text."
            ]
        case .family:
            return [
                "Put your phone in your pocket for the whole conversation.",
                "Ask a question you don't already know the answer to.",
                "Family don't always need big gestures — just presence."
            ]
        case .colleagues:
            return [
                "Name the specific thing they did, not just that they did well.",
                "Public recognition means more than a private note.",
                "Offer help at the start of the day, not when they're swamped."
            ]
        case .yourself:
            return [
                "Treat yourself with the patience you'd give a close friend.",
                "Don't check the result immediately — just do the thing.",
                "Even 10 minutes counts. Perfectionism is the enemy here."
            ]
        case .community:
            return [
                "Start hyper-local — your street or building is a great place to begin.",
                "Bring gloves or a bag if you're picking up litter.",
                "Tell one person what you did — it inspires them to act too."
            ]
        }
    }
}
