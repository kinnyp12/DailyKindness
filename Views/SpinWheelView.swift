import SwiftUI

// MARK: - SpinWheelView (MVC: View)

struct SpinWheelView: View {

    @EnvironmentObject var controller: SpinWheelController

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer()

                // Wheel + pointer
                ZStack(alignment: .top) {
                    WheelView()
                        .rotationEffect(.degrees(controller.spinDegrees))
                        .frame(width: 300, height: 300)

                    // Pointer triangle
                    Triangle()
                        .fill(Color.white)
                        .frame(width: 22, height: 28)
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 3)
                        .offset(y: -6)
                }
                .padding(.vertical, 16)

                // Challenge card or spin prompt
                Group {
                    if let challenge = controller.currentChallenge {
                        ChallengeCardView(challenge: challenge)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.85).combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else {
                        spinPrompt
                            .transition(.opacity)
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: controller.currentChallenge?.id)
                .padding(.horizontal)

                Spacer()

                spinButton
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
            .navigationTitle("Kindness Wheel")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Subviews

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryFilterChip(label: "All", emoji: "✨", isSelected: controller.filterCategory == nil) {
                    withAnimation { controller.filterCategory = nil }
                }
                ForEach(ChallengeCategory.allCases) { category in
                    CategoryFilterChip(
                        label: category.rawValue,
                        emoji: category.emoji,
                        isSelected: controller.filterCategory == category
                    ) {
                        withAnimation {
                            controller.filterCategory = controller.filterCategory == category ? nil : category
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var spinPrompt: some View {
        VStack(spacing: 8) {
            Text("Spin the wheel")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Get a random act of kindness challenge.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minHeight: 140)
    }

    private var spinButton: some View {
        Button {
            controller.spin()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: controller.isSpinning ? "hourglass" : "sparkles")
                    .font(.title3)
                Text(controller.isSpinning ? "Spinning…" : "Spin!")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                controller.isSpinning
                    ? AnyShapeStyle(Color.gray)
                    : AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.96, green: 0.45, blue: 0.65),
                                Color(red: 0.56, green: 0.42, blue: 0.86)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: controller.isSpinning ? .clear : Color(red: 0.96, green: 0.45, blue: 0.65).opacity(0.4),
                    radius: 12, x: 0, y: 6)
        }
        .disabled(controller.isSpinning)
        .scaleEffect(controller.isSpinning ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: controller.isSpinning)
    }
}

// MARK: - WheelView

struct WheelView: View {

    let segments = ChallengeCategory.allCases
    let segmentCount: Int

    init() {
        segmentCount = ChallengeCategory.allCases.count
    }

    var body: some View {
        ZStack {
            ForEach(Array(segments.enumerated()), id: \.element) { index, category in
                WheelSlice(
                    index: index,
                    total: segmentCount,
                    color: category.color,
                    emoji: category.emoji,
                    label: category.rawValue
                )
            }
            // Center cap
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: 44, height: 44)
                .shadow(color: Color.black.opacity(0.12), radius: 4)

            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(
                    LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
    }
}

// MARK: - WheelSlice

struct WheelSlice: View {
    let index: Int
    let total: Int
    let color: Color
    let emoji: String
    let label: String

    private var startAngle: Angle { .degrees(Double(index) / Double(total) * 360 - 90) }
    private var endAngle:   Angle { .degrees(Double(index + 1) / Double(total) * 360 - 90) }
    private var midAngle:   Double { (startAngle.degrees + endAngle.degrees) / 2 }

    var body: some View {
        ZStack {
            Path { path in
                let center = CGPoint(x: 150, y: 150)
                let radius: CGFloat = 148
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(index % 2 == 0 ? color : color.opacity(0.75))

            // Stroke between slices
            Path { path in
                let center = CGPoint(x: 150, y: 150)
                let radius: CGFloat = 148
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .stroke(Color.white, lineWidth: 1.5)

            // Emoji label positioned in the middle of the slice
            Text(emoji)
                .font(.system(size: 22))
                .offset(
                    x: cos(midAngle * .pi / 180) * 88,
                    y: sin(midAngle * .pi / 180) * 88
                )
        }
    }
}

// MARK: - Triangle pointer

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

// MARK: - CategoryFilterChip

struct CategoryFilterChip: View {
    let label: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji).font(.caption)
                Text(label).font(.caption).fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.pink.opacity(0.15) : Color(.secondarySystemBackground))
            .overlay(
                Capsule().stroke(isSelected ? Color.pink : Color.clear, lineWidth: 1.5)
            )
            .clipShape(Capsule())
            .foregroundStyle(isSelected ? Color.pink : Color.secondary)
        }
        .buttonStyle(.plain)
    }
}
