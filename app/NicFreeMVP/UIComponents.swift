import SwiftUI

struct HeroCard: View {
    let days: Int

    var body: some View {
        CardSection {
            VStack(spacing: 8) {
                Text("Nicotine-free")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1)

                Text("\(days)")
                    .font(.system(size: 68, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)

                Text("days strong")
                    .font(.title3)
                    .foregroundStyle(Color.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        CardSection {
            VStack(alignment: .leading, spacing: 10) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ink)
                    .minimumScaleFactor(0.8)

                Text(title)
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct CardSection<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(22)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.ink.opacity(configuration.isPressed ? 0.86 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
    }
}

extension Color {
    static let appBackground = Color(red: 0.94, green: 0.96, blue: 0.99)
    static let cardBackground = Color.white
    static let ink = Color(red: 0.08, green: 0.13, blue: 0.20)
    static let secondaryText = Color(red: 0.39, green: 0.45, blue: 0.52)
    static let greenBadge = Color(red: 0.87, green: 0.96, blue: 0.91)
    static let greenBadgeText = Color(red: 0.13, green: 0.40, blue: 0.27)
    static let pendingBadge = Color(red: 0.91, green: 0.94, blue: 0.97)
    static let pendingBadgeText = Color(red: 0.39, green: 0.45, blue: 0.52)
}

#Preview {
    VStack(spacing: 16) {
        HeroCard(days: 12)
        HStack {
            StatCard(title: "Money saved", value: "$102")
            StatCard(title: "Cravings defeated", value: "14")
        }
    }
    .padding()
    .background(Color.appBackground)
}
