import SwiftUI

struct RescueOptionsView: View {
    @Binding var selectedTab: RootTabView.Tab

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        ScreenHeader(
                            eyebrow: "Rescue",
                            title: "What would help right now?",
                            subtitle: "Choose the kind of support you need in this moment. Start with the strongest path if you just need to get through the wave."
                        )

                        NavigationLink {
                            CravingRescueView(selectedTab: $selectedTab)
                        } label: {
                            RescueOptionEntryCard(
                                title: "Wait it out",
                                subtitle: "Do not act yet. Give the urge 90 seconds to crest and pass.",
                                symbol: "hourglass",
                                isPrimary: true
                            )
                        }
                        .buttonStyle(RescueCardButtonStyle())

                        VStack(spacing: 14) {
                            NavigationLink {
                                CalmDownView(selectedTab: $selectedTab)
                            } label: {
                                RescueOptionEntryCard(
                                    title: "Calm down",
                                    subtitle: "Lower the intensity and steady your body.",
                                    symbol: "wind",
                                    isPrimary: false
                                )
                            }
                            .buttonStyle(RescueCardButtonStyle())

                            NavigationLink {
                                RememberWhyView()
                            } label: {
                                RescueOptionEntryCard(
                                    title: "Remember why",
                                    subtitle: "Reconnect with what matters more than this urge.",
                                    symbol: "heart",
                                    isPrimary: false
                                )
                            }
                            .buttonStyle(RescueCardButtonStyle())

                            NavigationLink {
                                ChangeMomentView()
                            } label: {
                                RescueOptionEntryCard(
                                    title: "Change the moment",
                                    subtitle: "Break the pattern with one small concrete action.",
                                    symbol: "bolt",
                                    isPrimary: false
                                )
                            }
                            .buttonStyle(RescueCardButtonStyle())
                        }

                        Text("Use the support that fits the moment. You do not need the same kind of help every time.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct RescueCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

private struct RescueOptionEntryCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let isPrimary: Bool

    var body: some View {
        CardSection(fill: AnyShapeStyle(
            LinearGradient(
                colors: isPrimary
                    ? [Color.white.opacity(0.98), Color.heroTop.opacity(0.8)]
                    : [Color.white.opacity(0.92), Color.white.opacity(0.76)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )) {
            VStack(alignment: .leading, spacing: isPrimary ? 18 : 14) {
                HStack(alignment: .center, spacing: 14) {
                    Image(systemName: symbol)
                        .font(.system(size: isPrimary ? 20 : 18, weight: .semibold))
                        .foregroundStyle(Color.heroAccent)
                        .frame(width: isPrimary ? 52 : 44, height: isPrimary ? 52 : 44)
                        .background(Color.white.opacity(isPrimary ? 0.62 : 0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.secondaryText)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: isPrimary ? 30 : 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(isPrimary ? .body : .subheadline)
                        .foregroundStyle(Color.secondaryText)
                        .lineSpacing(3)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isPrimary {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.caption.weight(.bold))
                        Text("Best when the urge feels strongest and you need a clear next step.")
                            .font(.footnote.weight(.medium))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(Color.ink.opacity(0.72))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.52))
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, minHeight: isPrimary ? 210 : 138, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    RescueOptionsView(selectedTab: .constant(.rescue))
}
