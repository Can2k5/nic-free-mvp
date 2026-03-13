import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackgroundTop, Color.appBackgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: 320, height: 320)
                .blur(radius: 18)
                .offset(x: 130, y: -250)

            Circle()
                .fill(Color.mist.opacity(0.75))
                .frame(width: 260, height: 260)
                .blur(radius: 30)
                .offset(x: -140, y: 260)
        }
        .ignoresSafeArea()
    }
}

struct ScreenHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow)
                .font(.caption.weight(.semibold))
                .tracking(1.1)
                .textCase(.uppercase)
                .foregroundStyle(Color.secondaryText)

            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HeroCard: View {
    let days: Int

    var body: some View {
        CardSection(fill: AnyShapeStyle(
            LinearGradient(
                colors: [Color.heroTop, Color.heroBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nicotine-free")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.heroSecondaryText)
                            .textCase(.uppercase)
                            .tracking(1.2)

                        Text("Your recovery is already in motion.")
                            .font(.subheadline)
                            .foregroundStyle(Color.heroSecondaryText.opacity(0.92))
                    }

                    Spacer()

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.heroAccent)
                        .padding(12)
                        .background(Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(days)")
                        .font(.system(size: 76, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)

                    Text("days strong")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.heroSecondaryText)
                }

                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption.weight(.bold))
                    Text("Every calm day is building a new normal.")
                        .font(.footnote.weight(.medium))
                }
                .foregroundStyle(Color.ink.opacity(0.76))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.52))
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var symbol: String

    var body: some View {
        CardSection {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.accentInk)
                    .frame(width: 38, height: 38)
                    .background(Color.accentWash)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .minimumScaleFactor(0.8)

                Text(title)
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct CardSection<Content: View>: View {
    private let fill: AnyShapeStyle
    @ViewBuilder let content: Content

    init(fill: AnyShapeStyle = AnyShapeStyle(Color.cardBackground), @ViewBuilder content: () -> Content) {
        self.fill = fill
        self.content = content()
    }

    var body: some View {
        content
            .padding(22)
            .background(fill)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.shadowColor.opacity(0.08), radius: 22, x: 0, y: 12)
            .shadow(color: Color.shadowColor.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? Color.white : Color.disabledText)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isEnabled
                                ? [Color.buttonTop.opacity(configuration.isPressed ? 0.92 : 1), Color.buttonBottom]
                                : [Color.disabledButton, Color.disabledButton],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(isEnabled ? 0.18 : 0), lineWidth: 1)
            )
            .shadow(color: isEnabled ? Color.buttonBottom.opacity(configuration.isPressed ? 0.18 : 0.24) : .clear, radius: 18, x: 0, y: 10)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

extension Color {
    static let appBackgroundTop = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let appBackgroundBottom = Color(red: 0.93, green: 0.95, blue: 0.97)
    static let cardBackground = Color.white
    static let ink = Color(red: 0.12, green: 0.16, blue: 0.23)
    static let secondaryText = Color(red: 0.39, green: 0.44, blue: 0.50)
    static let accentInk = Color(red: 0.30, green: 0.43, blue: 0.45)
    static let accentWash = Color(red: 0.91, green: 0.95, blue: 0.94)
    static let mist = Color(red: 0.88, green: 0.93, blue: 0.91)
    static let heroTop = Color(red: 0.96, green: 0.93, blue: 0.89)
    static let heroBottom = Color(red: 0.88, green: 0.93, blue: 0.92)
    static let heroSecondaryText = Color(red: 0.35, green: 0.41, blue: 0.45)
    static let heroAccent = Color(red: 0.42, green: 0.58, blue: 0.51)
    static let buttonTop = Color(red: 0.27, green: 0.38, blue: 0.41)
    static let buttonBottom = Color(red: 0.18, green: 0.27, blue: 0.30)
    static let disabledButton = Color(red: 0.77, green: 0.80, blue: 0.82)
    static let disabledText = Color(red: 0.95, green: 0.96, blue: 0.97)
    static let greenBadge = Color(red: 0.89, green: 0.96, blue: 0.92)
    static let greenBadgeText = Color(red: 0.18, green: 0.42, blue: 0.28)
    static let pendingBadge = Color(red: 0.93, green: 0.94, blue: 0.96)
    static let pendingBadgeText = Color(red: 0.42, green: 0.46, blue: 0.53)
    static let shadowColor = Color(red: 0.17, green: 0.20, blue: 0.24)
}

#Preview {
    VStack(spacing: 16) {
        HeroCard(days: 12)
        HStack {
            StatCard(title: "Money saved", value: "$102", symbol: "dollarsign")
            StatCard(title: "Cravings defeated", value: "14", symbol: "bolt.heart")
        }
    }
    .padding()
    .background(AppBackground())
}
