import SwiftUI
import UIKit
import RevenueCat

enum MicroAnimation {
    static let press = Animation.spring(duration: 0.32, bounce: 0.18)
    static let release = Animation.spring(duration: 0.42, bounce: 0.22)
    static let selection = Animation.spring(duration: 0.46, bounce: 0.18)
    static let emphasis = Animation.easeInOut(duration: 0.3)
    static let entrance = Animation.easeOut(duration: 0.68)
    static let supportiveReveal = Animation.easeOut(duration: 0.56)
    static let success = Animation.spring(duration: 0.62, bounce: 0.18)
    static let flow = Animation.spring(duration: 0.58, bounce: 0.14)
}

enum AppSpacing {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 24
    static let section: CGFloat = 24
}

private struct SoftEntranceModifier: ViewModifier {
    let delay: Double
    let distance: CGFloat
    let animation: Animation
    let initialScale: CGFloat

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : distance)
            .scaleEffect(isVisible ? 1 : initialScale)
            .onAppear {
                guard !isVisible else { return }
                withAnimation(animation.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension AnyTransition {
    static var calmSuccess: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.955)).combined(with: .offset(y: 20)),
            removal: .opacity.combined(with: .scale(scale: 0.992))
        )
    }

    static var calmFlow: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 22)).combined(with: .scale(scale: 0.975)),
            removal: .opacity.combined(with: .offset(y: -14)).combined(with: .scale(scale: 0.994))
        )
    }

    static var onboardingForward: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .offset(x: 52)).combined(with: .scale(scale: 0.972)),
            removal: .opacity.combined(with: .offset(x: -34)).combined(with: .scale(scale: 0.988))
        )
    }
}

extension View {
    func softEntrance(
        delay: Double = 0,
        distance: CGFloat = 28,
        animation: Animation = MicroAnimation.entrance,
        initialScale: CGFloat = 0.968
    ) -> some View {
        modifier(
            SoftEntranceModifier(
                delay: delay,
                distance: distance,
                animation: animation,
                initialScale: initialScale
            )
        )
    }

    func rewardToast(_ toast: RewardToastContent?) -> some View {
        overlay(alignment: .bottom) {
            if let toast {
                RewardToast(content: toast)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1000)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: toast)
    }
}

struct RewardToast: View {
    let content: RewardToastContent

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "checkmark")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.white.opacity(0.95))

            VStack(alignment: .leading, spacing: 3) {
                Text(content.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.white)

                Text(content.message)
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.92))
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.buttonTop.opacity(0.95), Color.buttonBottom.opacity(0.98)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.border.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: Color.buttonBottom.opacity(0.18), radius: 18, x: 0, y: 10)
        .allowsHitTesting(false)
    }
}

struct ConversationalRevealText: View {
    enum ChunkingStrategy: Equatable {
        case phrases
        case sentences
        case wordGroups(Int)
    }

    struct Style {
        var font: Font
        var finalColor: Color
        var mutedColor: Color
        var lineSpacing: CGFloat
        var initialOpacity: Double
        var animation: Animation

        static let body = Style(
            font: .body,
            finalColor: Color.ink,
            mutedColor: Color.secondaryText,
            lineSpacing: 4,
            initialOpacity: 0.12,
            animation: .easeOut(duration: 0.48)
        )

        static let headline = Style(
            font: .system(size: 34, weight: .bold, design: .rounded),
            finalColor: Color.ink,
            mutedColor: Color.secondaryText.opacity(0.9),
            lineSpacing: 4,
            initialOpacity: 0.1,
            animation: .easeOut(duration: 0.52)
        )

        static let hero = Style(
            font: .system(size: 40, weight: .bold, design: .rounded),
            finalColor: Color.ink,
            mutedColor: Color.secondaryText.opacity(0.85),
            lineSpacing: 5,
            initialOpacity: 0.08,
            animation: .easeOut(duration: 0.56)
        )
    }

    let text: String
    var startDelay: Double = 0
    var chunkDelay: Double = 0.7
    var chunking: ChunkingStrategy = .phrases
    var style: Style = .body
    var onComplete: (() -> Void)? = nil

    @State private var chunks: [String] = []
    @State private var chunkProgress: [Double] = []
    @State private var revealTask: Task<Void, Never>?

    var body: some View {
        composedText
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
            .task(id: animationKey) {
                startReveal()
            }
            .onDisappear {
                revealTask?.cancel()
                revealTask = nil
            }
    }

    private var animationKey: String {
        "\(text)|\(startDelay)|\(chunkDelay)|\(chunking.key)"
    }

    private var composedText: Text {
        guard !chunks.isEmpty else {
            return Text(text).foregroundStyle(style.finalColor)
        }

        return chunks.enumerated().reduce(Text("")) { partial, item in
            let (index, chunk) = item
            let progress = chunkProgress[safe: index] ?? -1
            let renderedChunk: Text

            if progress < 0 {
                renderedChunk = Text(chunk).foregroundStyle(.clear)
            } else {
                let opacity = style.initialOpacity + ((1 - style.initialOpacity) * progress)
                let color = progress >= 0.999 ? style.finalColor : style.mutedColor.opacity(opacity)
                renderedChunk = Text(chunk).foregroundStyle(color)
            }

            return partial + renderedChunk
        }
    }

    private func startReveal() {
        revealTask?.cancel()

        let resolvedChunks = chunking.makeChunks(from: text)
        chunks = resolvedChunks
        chunkProgress = Array(repeating: -1, count: resolvedChunks.count)

        guard !resolvedChunks.isEmpty else {
            onComplete?()
            return
        }

        revealTask = Task {
            if startDelay > 0 {
                try? await Task.sleep(for: .seconds(startDelay))
            }

            for index in resolvedChunks.indices {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    chunkProgress[index] = 0
                    withAnimation(style.animation) {
                        chunkProgress[index] = 1
                    }
                }

                if index < resolvedChunks.count - 1 {
                    try? await Task.sleep(for: .seconds(chunkDelay))
                }
            }

            guard !Task.isCancelled else { return }
            await MainActor.run {
                onComplete?()
            }
        }
    }
}

private extension ConversationalRevealText.ChunkingStrategy {
    var key: String {
        switch self {
        case .phrases:
            return "phrases"
        case .sentences:
            return "sentences"
        case let .wordGroups(size):
            return "wordGroups-\(size)"
        }
    }

    func makeChunks(from text: String) -> [String] {
        switch self {
        case .phrases:
            return split(text, separators: [",", ".", "!", "?", ";", ":"])
        case .sentences:
            return split(text, separators: [".", "!", "?"])
        case let .wordGroups(size):
            return groupedWords(from: text, size: max(1, size))
        }
    }

    private func split(_ text: String, separators: Set<Character>) -> [String] {
        var chunks: [String] = []
        var current = ""
        let characters = Array(text)

        for index in characters.indices {
            let character = characters[index]
            current.append(character)

            if separators.contains(character) {
                let nextIndex = characters.index(after: index)
                if nextIndex < characters.endIndex, !characters[nextIndex].isWhitespace {
                    current.append(" ")
                }
                chunks.append(current)
                current = ""
            }
        }

        if !current.isEmpty {
            chunks.append(current)
        }

        return normalized(chunks)
    }

    private func groupedWords(from text: String, size: Int) -> [String] {
        let words = text.split(whereSeparator: \.isWhitespace)
        guard !words.isEmpty else { return [] }

        var chunks: [String] = []
        var index = 0

        while index < words.count {
            let end = min(index + size, words.count)
            let group = words[index..<end].joined(separator: " ")
            chunks.append(group + (end < words.count ? " " : ""))
            index = end
        }

        return normalized(chunks)
    }

    private func normalized(_ chunks: [String]) -> [String] {
        chunks.enumerated().compactMap { index, chunk in
            let cleaned = index == chunks.count - 1
                ? chunk.trimmingCharacters(in: .whitespacesAndNewlines)
                : chunk

            return cleaned.isEmpty ? nil : cleaned
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct GlassPanel: ViewModifier {
    var cornerRadius: CGFloat = 22
    var tint: Color = .cardBackground
    var tintOpacity: Double = 0.18
    var shadowOpacity: Double = 0.09

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        tint.opacity(tintOpacity),
                                        Color.surface.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.border.opacity(0.7),
                                Color.border.opacity(0.24)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.shadowColor.opacity(shadowOpacity), radius: 18, x: 0, y: 10)
            .shadow(color: Color.cardBackground.opacity(0.22), radius: 1, x: 0, y: 1)
    }
}

extension View {
    func glassPanel(
        cornerRadius: CGFloat = 22,
        tint: Color = .cardBackground,
        tintOpacity: Double = 0.18,
        shadowOpacity: Double = 0.09
    ) -> some View {
        modifier(
            GlassPanel(
                cornerRadius: cornerRadius,
                tint: tint,
                tintOpacity: tintOpacity,
                shadowOpacity: shadowOpacity
            )
        )
    }

    @ViewBuilder
    func `if`<Transformed: View>(_ condition: Bool, transform: (Self) -> Transformed) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackgroundTop, Color.appBackgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.cardBackground.opacity(0.18))
                .frame(width: 360, height: 360)
                .blur(radius: 42)
                .offset(x: 150, y: -280)

            Circle()
                .fill(Color.mist.opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 64)
                .offset(x: -120, y: 300)
        }
        .ignoresSafeArea()
    }
}

struct OnboardingBackgroundView: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack {
                LinearGradient(
                    colors: [
                        Color.appBackgroundTop,
                        Color(red: 0.98, green: 0.96, blue: 1.0),
                        Color(red: 0.95, green: 0.91, blue: 1.0).opacity(0.95),
                        Color.appBackgroundBottom.opacity(0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(Color.white.opacity(0.52))
                    .frame(width: width * 0.92, height: width * 0.92)
                    .blur(radius: 44)
                    .offset(x: width * 0.24, y: -90)

                Circle()
                    .fill(Color.buttonHighlight.opacity(0.2))
                    .frame(width: width * 0.88, height: width * 0.88)
                    .blur(radius: 56)
                    .offset(x: -width * 0.24, y: width * 0.5)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.screen)
            }
            .ignoresSafeArea()
        }
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
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OnboardingHeaderView: View {
    let currentStep: Int
    let totalSteps: Int
    let title: String
    let subtitle: String

    private let purple = Color.buttonBottom

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text("Step \(currentStep)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(purple)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    Text("of \(totalSteps)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.helperText)
                }

                GeometryReader { barProxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.48))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.buttonTop,
                                        Color.buttonBottom
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(barProxy.size.width * (CGFloat(currentStep) / CGFloat(max(totalSteps, 1))), 54))
                            .shadow(color: Color.onboardingShadow.opacity(0.24), radius: 10, x: 0, y: 4)
                    }
                }
                .frame(height: 7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: subtitle.isEmpty ? 0 : 8) {
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .tracking(-1.3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondaryText)
                        .lineSpacing(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum OnboardingHeaderMetrics {
    static let topSafeAreaOffset: CGFloat = -18
    static let progressToTitleSpacing: CGFloat = 14
    static let titleToSubtitleSpacing: CGFloat = 4
    static let headerToContentSpacing: CGFloat = 14
}

struct PaywallBenefit: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let title: String
}

struct PaywallGlowOrb: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.buttonBottom.opacity(0.16))
                .frame(width: 150, height: 150)
                .blur(radius: 26)
                .scaleEffect(pulse ? 1.06 : 0.94)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.buttonTop.opacity(0.96),
                            Color.buttonBottom.opacity(0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 102, height: 102)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
                )
                .shadow(color: Color.buttonBottom.opacity(0.24), radius: 22, x: 0, y: 12)

            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 42, height: 42)
                .blur(radius: 8)
                .offset(x: -20, y: -18)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            guard !pulse else { return }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

struct PaywallBenefitsList: View {
    let benefits: [PaywallBenefit]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(benefits) { benefit in
                HStack(spacing: 12) {
                    Image(systemName: benefit.icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.buttonBottom)
                        .frame(width: 30, height: 30)
                        .background(Color.buttonBottom.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Text(benefit.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.ink)

                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PaywallPriceCard: View {
    let priceText: String
    var supportingText: String = "7-day free trial"

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(supportingText)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.buttonBottom)
                .textCase(.uppercase)
                .tracking(1.1)

            Text(priceText)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.center)

            Text("Billed monthly after trial.")
                .font(.footnote)
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.onboardingSurfaceElevated,
                            Color.white.opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.borderStrong.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color.onboardingShadow.opacity(0.12), radius: 16, x: 0, y: 8)
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var analytics: AnalyticsService

    var onPurchaseSuccess: (() -> Void)? = nil
    var onClose: (() -> Void)? = nil

    @State private var isVisible = false
    @State private var dragOffset: CGFloat = 0
    @State private var selectedPackageID: String?
    @State private var hasLoadedInitially = false

    private let benefits = [
        PaywallBenefit(icon: "chart.line.uptrend.xyaxis", title: "Track your real progress"),
        PaywallBenefit(icon: "rosette", title: "Unlock all achievements"),
        PaywallBenefit(icon: "checkmark.shield", title: "Stay accountable every day"),
        PaywallBenefit(icon: "sparkles", title: "Build a habit that lasts")
    ]

    private var selectedPackage: Package? {
        if let selectedPackageID {
            return subscriptionManager.availablePackages.first(where: { $0.storeProduct.productIdentifier == selectedPackageID })
        }
        return subscriptionManager.highlightedPackage
    }

    private var isBusy: Bool {
        subscriptionManager.isLoadingOfferings || subscriptionManager.isRestoringPurchases || subscriptionManager.purchasingPackageID != nil
    }

    var body: some View {
        ZStack {
            Color.overlayScrim
                .opacity(isVisible ? 1 : 0)
                .ignoresSafeArea()

            AppBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button {
                        dismissAnimated()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.ink)
                            .frame(width: 40, height: 40)
                            .background(Color.surfaceElevated)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(CardPressButtonStyle())
                }
                .padding(.bottom, 18)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {
                        PaywallGlowOrb()
                            .padding(.top, 8)

                        VStack(spacing: 10) {
                            Text("Take control back.")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.ink)
                                .multilineTextAlignment(.center)

                            Text("Build discipline. Stay consistent.")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.secondaryText.opacity(0.78))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)

                        CardSection(fill: AnyShapeStyle(Color.cardBackground)) {
                            VStack(alignment: .leading, spacing: 18) {
                                PaywallBenefitsList(benefits: benefits)

                                paywallPackagesSection
                            }
                        }

                        if let selectedPackage {
                            PaywallPriceCard(
                                priceText: priceText(for: selectedPackage),
                                supportingText: supportingText(for: selectedPackage)
                            )
                        } else if subscriptionManager.isLoadingOfferings {
                            PaywallPriceCard(priceText: "Loading...", supportingText: "Checking plans")
                                .redacted(reason: .placeholder)
                        }

                        OnboardingPrimaryButton(
                            title: subscriptionManager.purchasingPackageID == selectedPackage?.storeProduct.productIdentifier
                                ? "Starting..."
                                : "Start Free Trial",
                            isEnabled: selectedPackage != nil && !isBusy,
                            action: startPurchase
                        )

                        Button {
                            restorePurchases()
                        } label: {
                            Text(subscriptionManager.isRestoringPurchases ? "Restoring..." : "Restore purchases")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.secondaryText)
                        }
                        .disabled(isBusy)
                        .buttonStyle(SecondaryButtonStyle(isEnabled: !isBusy))

                        if let errorMessage = subscriptionManager.errorMessage {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(3)

                                Button("Try again") {
                                    Task {
                                        await subscriptionManager.loadOfferings()
                                    }
                                }
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.buttonBottom)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.border, lineWidth: 1)
                            )
                        }

                        VStack(spacing: 6) {
                            Text("Cancel anytime")
                            Text("No commitment")
                        }
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 12)
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 28)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 8)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.appBackgroundTop.opacity(0.92))
                    .ignoresSafeArea()
            )
            .offset(y: max(dragOffset, 0) + (isVisible ? 0 : 42))
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.985)
            .gesture(dismissDragGesture)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
            .animation(.interactiveSpring(response: 0.32, dampingFraction: 0.86), value: dragOffset)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                isVisible = true
            }
            syncSelectedPackageID()
            if !hasLoadedInitially {
                hasLoadedInitially = true
                Task {
                    await subscriptionManager.loadOfferings()
                    syncSelectedPackageID()
                }
            }
        }
        .onChange(of: subscriptionManager.availablePackages.count) { _, _ in
            syncSelectedPackageID()
        }
        .trackAnalyticsEvent(.paywallViewed, properties: ["placement": "general", "source": "modal"])
    }

    private var paywallPackagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !subscriptionManager.availablePackages.isEmpty {
                Text("Choose your plan")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.1)

                VStack(spacing: 10) {
                    ForEach(subscriptionManager.availablePackages, id: \.storeProduct.productIdentifier) { package in
                        paywallPackageRow(package)
                    }
                }
            }
        }
    }

    private func paywallPackageRow(_ package: Package) -> some View {
        let isSelected = selectedPackage?.storeProduct.productIdentifier == package.storeProduct.productIdentifier

        return Button {
            selectedPackageID = package.storeProduct.productIdentifier
            subscriptionManager.clearError()
            debugPrint("[Paywall] Selected package id: \(package.storeProduct.productIdentifier)")
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title(for: package))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Text(package.storeProduct.localizedPriceString)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                if package.packageType == .annual {
                    Text("Best value")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.buttonBottom)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.buttonBottom.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.buttonBottom.opacity(0.08) : Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.buttonBottom.opacity(0.34) : Color.border, lineWidth: isSelected ? 1.3 : 1)
            )
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var dismissDragGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .onChanged { value in
                guard value.translation.height > 0 else { return }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                let shouldDismiss = value.translation.height > 110 || value.predictedEndTranslation.height > 180
                if shouldDismiss {
                    dismissAnimated()
                } else {
                    withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.82)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func dismissAnimated() {
        withAnimation(.easeInOut(duration: 0.24)) {
            isVisible = false
            dragOffset = 0
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(220))
            onClose?()
            dismiss()
        }
    }

    private func startPurchase() {
        guard let selectedPackage else { return }

        Task {
            switch await subscriptionManager.purchase(selectedPackage) {
            case .success:
                appState.showRewardToast(
                    title: "You are all set.",
                    message: "Your subscription is active now."
                )
                onPurchaseSuccess?()
                dismissAnimated()
            case .cancelled:
                break
            case .failed:
                break
            }
        }
    }

    private func restorePurchases() {
        Task {
            switch await subscriptionManager.restorePurchases() {
            case .restored:
                appState.showRewardToast(
                    title: "You are all set.",
                    message: "Your subscription is active on this device."
                )
                dismissAnimated()
            case .noActiveSubscription, .failed:
                break
            }
        }
    }

    private func syncSelectedPackageID() {
        let preferredPackage = selectedPackage
            ?? subscriptionManager.monthlyPackage
            ?? subscriptionManager.annualPackage
            ?? subscriptionManager.availablePackages.first
        selectedPackageID = preferredPackage?.storeProduct.productIdentifier
        if let selectedPackageID {
            debugPrint("[Paywall] Active package id: \(selectedPackageID)")
        }
    }

    private func title(for package: Package) -> String {
        switch package.packageType {
        case .monthly:
            return "Monthly"
        case .annual:
            return "Annual"
        default:
            return package.storeProduct.localizedTitle
        }
    }

    private func priceText(for package: Package) -> String {
        switch package.packageType {
        case .annual:
            return "\(package.storeProduct.localizedPriceString) / year"
        case .monthly:
            return "\(package.storeProduct.localizedPriceString) / month"
        default:
            return package.storeProduct.localizedPriceString
        }
    }

    private func supportingText(for package: Package) -> String {
        package.storeProduct.introductoryDiscount == nil ? "Current plan" : "Free trial available"
    }
}

private enum DesignCardRole {
    case hero
    case insight
    case action
    case neutral

    var fill: AnyShapeStyle {
        switch self {
        case .hero:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.heroTop.opacity(0.98), Color.heroBottom.opacity(0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .insight:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.cardBackground.opacity(0.92), Color.surface.opacity(0.94)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .action:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.surfaceElevated.opacity(0.98), Color.cardBackground.opacity(0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .neutral:
            return AnyShapeStyle(Color.cardBackground)
        }
    }

    var stroke: Color {
        switch self {
        case .hero:
            return Color.borderStrong.opacity(0.42)
        case .insight:
            return Color.border.opacity(0.85)
        case .action:
            return Color.borderStrong.opacity(0.3)
        case .neutral:
            return Color.borderStrong.opacity(0.72)
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .hero:
            return 0.14
        case .insight:
            return 0.06
        case .action:
            return 0.09
        case .neutral:
            return 0.1
        }
    }
}

private struct DesignSystemCard<Content: View>: View {
    let role: DesignCardRole
    var padding: CGFloat = AppSpacing.lg
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(role.fill)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(role.stroke, lineWidth: 1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.16), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: Color.shadowColor.opacity(role.shadowOpacity), radius: 18, x: 0, y: 10)
    }
}

struct HeroCard<Content: View>: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil
    var badge: String? = nil
    var icon: String? = nil
    var alignment: HorizontalAlignment = .leading
    @ViewBuilder let content: Content

    init(
        eyebrow: String,
        title: String,
        subtitle: String? = nil,
        badge: String? = nil,
        icon: String? = nil,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.icon = icon
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        DesignSystemCard(role: .hero, padding: AppSpacing.lg) {
            VStack(alignment: alignment, spacing: AppSpacing.md) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    VStack(alignment: alignment, spacing: AppSpacing.xs) {
                        Text(eyebrow)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.heroSecondaryText)
                            .textCase(.uppercase)
                            .tracking(1.1)

                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(Color.heroSecondaryText)
                        }
                    }

                    Spacer(minLength: 0)

                    if let badge {
                        Text(badge)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.heroAccent)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(Color.cardBackground.opacity(0.62))
                            .clipShape(Capsule())
                    } else if let icon {
                        Image(systemName: icon)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.heroAccent)
                            .frame(width: 44, height: 44)
                            .background(Color.cardBackground.opacity(0.62))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }

                Text(title)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .multilineTextAlignment(alignment == .center ? .center : .leading)
                    .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)

                content
            }
            .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
        }
    }
}

struct KPIGrid<Content: View>: View {
    let columns: [GridItem]
    var spacing: CGFloat = AppSpacing.md
    @ViewBuilder let content: Content

    init(columns: [GridItem] = [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible(), spacing: AppSpacing.md)], @ViewBuilder content: () -> Content) {
        self.columns = columns
        self.content = content()
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            content
        }
    }
}

struct KPIBlock: View {
    let value: String
    let label: String
    var detail: String? = nil
    var icon: String? = nil

    var body: some View {
        DesignSystemCard(role: .neutral, padding: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.heroAccent)
                        .frame(width: 30, height: 30)
                        .background(Color.accentWash.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .minimumScaleFactor(0.8)

                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                    .textCase(.uppercase)
                    .tracking(0.8)

                if let detail, !detail.isEmpty {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(Color.textMuted)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        }
    }
}

struct InsightCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    @ViewBuilder let content: Content

    init(title: String, subtitle: String? = nil, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        DesignSystemCard(role: .insight, padding: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(Color.secondaryText)
                                .lineSpacing(3)
                        }
                    }

                    Spacer(minLength: 0)

                    if let icon {
                        Image(systemName: icon)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.buttonBottom)
                            .frame(width: 40, height: 40)
                            .background(Color.accentWash.opacity(0.88))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }

                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ActionCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var icon: String
    var emphasizesAction: Bool = false
    var showsChevron: Bool = true
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        emphasizesAction: Bool = false,
        showsChevron: Bool = true,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.emphasizesAction = emphasizesAction
        self.showsChevron = showsChevron
        self.content = content()
    }

    var body: some View {
        DesignSystemCard(role: .action, padding: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    Image(systemName: icon)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(emphasizesAction ? Color.buttonBottom : Color.heroAccent)
                        .frame(width: emphasizesAction ? 44 : 40, height: emphasizesAction ? 44 : 40)
                        .background(
                            emphasizesAction
                                ? Color.cardBackground.opacity(0.72)
                                : Color.accentWash.opacity(0.9)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.ink)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(Color.secondaryText)
                                .lineSpacing(3)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)

                    Spacer(minLength: 0)

                    if showsChevron {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.secondaryText)
                            .padding(.top, 2)
                    }
                }

                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var symbol: String

    var body: some View {
        KPIBlock(value: value, label: title, icon: symbol)
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
            .padding(24)
            .background(fill)
            .shadow(color: Color.onboardingShadow.opacity(0.1), radius: 20, x: 0, y: 12)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.borderStrong.opacity(0.72), lineWidth: 0.9)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.24),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

struct SecondaryButtonStyle: SwiftUI.ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .opacity(isEnabled ? (configuration.isPressed ? 0.68 : 1) : 0.45)
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(MicroAnimation.press, value: configuration.isPressed)
    }
}

struct CardPressButtonStyle: SwiftUI.ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.954 : 1)
            .opacity(isEnabled ? (configuration.isPressed ? 0.84 : 1) : 0.5)
            .brightness(configuration.isPressed ? -0.036 : 0)
            .animation(MicroAnimation.press, value: configuration.isPressed)
    }
}

struct SelectableButtonStyle: SwiftUI.ButtonStyle {
    var isSelected: Bool
    var isEnabled: Bool = true

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : (isSelected ? 1.06 : 1))
            .opacity(isEnabled ? 1 : 0.45)
            .brightness(configuration.isPressed ? -0.04 : (isSelected ? 0.024 : 0))
            .shadow(
                color: isSelected ? Color.buttonBottom.opacity(0.3) : Color.clear,
                radius: isSelected ? 22 : 0,
                x: 0,
                y: isSelected ? 12 : 0
            )
            .animation(MicroAnimation.press, value: configuration.isPressed)
            .animation(MicroAnimation.selection, value: isSelected)
    }
}

struct PrimaryButtonStyle: SwiftUI.ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? Color.white : Color.disabledText)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: isEnabled
                                        ? [
                                            Color.buttonTop.opacity(configuration.isPressed ? 0.95 : 0.98),
                                            Color.buttonBottom,
                                            Color.buttonBottom.opacity(0.96)
                                        ]
                                        : [Color.disabledButton, Color.disabledButton],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.cardBackground.opacity(isEnabled ? 0.42 : 0),
                                Color.cardBackground.opacity(isEnabled ? 0.1 : 0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cardBackground.opacity(isEnabled ? 0.22 : 0),
                                Color.white.opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 22)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                    )
            }
            .shadow(color: isEnabled ? Color.buttonBottom.opacity(configuration.isPressed ? 0.1 : 0.3) : .clear, radius: configuration.isPressed ? 10 : 20, x: 0, y: configuration.isPressed ? 4 : 12)
            .shadow(color: isEnabled ? Color.cardBackground.opacity(0.14) : .clear, radius: 1, x: 0, y: 1)
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1) : 1)
            .scaleEffect(configuration.isPressed ? 0.942 : 1)
            .brightness(configuration.isPressed ? -0.03 : 0)
            .animation(MicroAnimation.press, value: configuration.isPressed)
    }
}

enum OnboardingPageTransition {
    static func transition(forward: Bool) -> AnyTransition {
        if forward {
            return .asymmetric(
                insertion: .offset(x: 42).combined(with: .opacity),
                removal: .offset(x: -32).combined(with: .opacity)
            )
        } else {
            return .asymmetric(
                insertion: .offset(x: -42).combined(with: .opacity),
                removal: .offset(x: 32).combined(with: .opacity)
            )
        }
    }

    static let animation = Animation.spring(duration: 0.34, bounce: 0.1)
}

enum OnboardingHaptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

struct OnboardingProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    var stepLabel: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.1)

                Spacer()

                if let stepLabel {
                    Text(stepLabel)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.buttonBottom)
                }
            }

            GeometryReader { proxy in
                let progress = CGFloat(currentStep) / CGFloat(max(totalSteps, 1))

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.surfaceMuted)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.buttonTop,
                                    Color.buttonBottom
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(proxy.size.width * progress, 28))
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .frame(height: 10)
        }
    }
}

typealias ProgressIndicator = OnboardingProgressIndicator

struct OnboardingInputField: View {
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool = false
    var keyboardType: UIKeyboardType = .default
    var axis: Axis = .horizontal
    var textAlignment: TextAlignment = .center

    var body: some View {
        Group {
            if axis == .vertical {
                ZStack(alignment: .topLeading) {
                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !placeholder.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.secondaryText.opacity(0.72))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                    }

                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(minHeight: 148)
                }
            } else {
                TextField(placeholder, text: $text, axis: axis)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(textAlignment)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 19)
            }
        }
        .font(.system(size: 22, weight: .semibold, design: .rounded))
        .foregroundStyle(Color.ink)
        .frame(maxWidth: .infinity, alignment: textAlignment == .leading ? .leading : .center)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.inputBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    isFocused
                        ? Color.buttonBottom.opacity(0.92)
                        : Color.borderStrong.opacity(0.6),
                    lineWidth: isFocused ? 2.2 : 1
                )
        )
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isFocused ? 0.22 : 0.14),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .shadow(
            color: isFocused
                ? Color.onboardingShadow.opacity(0.22)
                : Color.onboardingShadow.opacity(0.08),
            radius: isFocused ? 22 : 14,
            x: 0,
            y: isFocused ? 10 : 7
        )
        .animation(OnboardingPageTransition.animation, value: isFocused)
    }
}

typealias InputField = OnboardingInputField

struct OnboardingPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            guard isEnabled else { return }
            OnboardingHaptics.soft()
            action()
        } label: {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(isEnabled ? Color.white : Color.white.opacity(0.72))
                .frame(maxWidth: .infinity)
                .frame(height: OnboardingActionBarMetrics.buttonHeight)
        }
        .disabled(!isEnabled)
        .buttonStyle(OnboardingPrimaryButtonStyle(isEnabled: isEnabled))
    }
}

typealias PrimaryButton = OnboardingPrimaryButton

struct OnboardingSecondaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            guard isEnabled else { return }
            OnboardingHaptics.soft()
            action()
        } label: {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(isEnabled ? Color(red: 0.36, green: 0.12, blue: 0.64) : Color.secondaryText.opacity(0.72))
                .frame(maxWidth: .infinity)
                .frame(height: OnboardingActionBarMetrics.buttonHeight)
        }
        .disabled(!isEnabled)
        .buttonStyle(OnboardingSecondaryButtonStyle(isEnabled: isEnabled))
    }
}

enum OnboardingActionBarMetrics {
    static let horizontalPadding: CGFloat = 24
    static let spacing: CGFloat = 14
    static let buttonHeight: CGFloat = 64
    static let cornerRadius: CGFloat = 26
    static let chromeVerticalPadding: CGFloat = 10
    static let chromeHorizontalPadding: CGFloat = 10
    static let chromeHeight: CGFloat = buttonHeight + (chromeVerticalPadding * 2)
    static let bottomInset: CGFloat = 6
    static let topInset: CGFloat = 8
    static let reservedHeight: CGFloat = chromeHeight + topInset + bottomInset
}

struct OnboardingActionRow: View {
    var showsBackButton: Bool = true
    var showsPrimaryButton: Bool = true
    var backTitle: String = "back"
    var continueTitle: String = "continue"
    var primaryButtonEnabled: Bool = true
    var width: CGFloat? = nil
    var horizontalPadding: CGFloat = 0
    var bottomPadding: CGFloat = 0
    var spacing: CGFloat = OnboardingActionBarMetrics.spacing
    var onBack: (() -> Void)? = nil
    var onContinue: (() -> Void)? = nil

    var body: some View {
        Group {
            if let width {
                row
                    .frame(width: width, height: OnboardingActionBarMetrics.chromeHeight, alignment: .bottom)
            } else {
                row
                    .frame(maxWidth: .infinity)
                    .frame(height: OnboardingActionBarMetrics.chromeHeight, alignment: .bottom)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, bottomPadding)
    }

    private var row: some View {
        HStack(spacing: spacing) {
            if showsBackButton, let onBack {
                OnboardingSecondaryButton(
                    title: backTitle,
                    action: onBack
                )
            }

            if showsPrimaryButton, let onContinue {
                OnboardingPrimaryButton(
                    title: continueTitle,
                    isEnabled: primaryButtonEnabled,
                    action: onContinue
                )
            }
        }
        .padding(.horizontal, OnboardingActionBarMetrics.chromeHorizontalPadding)
        .padding(.vertical, OnboardingActionBarMetrics.chromeVerticalPadding)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.onboardingSurface.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.borderStrong.opacity(0.8), lineWidth: 1)
        )
        .shadow(color: Color.onboardingShadow.opacity(0.12), radius: 18, x: 0, y: 10)
    }
}

private struct OnboardingPrimaryButtonStyle: SwiftUI.ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: OnboardingActionBarMetrics.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isEnabled
                                ? [
                                    Color.buttonTop,
                                    Color.buttonBottom
                                ]
                                : [
                                    Color(red: 0.75, green: 0.66, blue: 0.95),
                                    Color(red: 0.69, green: 0.58, blue: 0.92)
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: OnboardingActionBarMetrics.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(isEnabled ? 0.16 : 0), lineWidth: 1)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: OnboardingActionBarMetrics.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isEnabled ? 0.22 : 0.08),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: OnboardingActionBarMetrics.cornerRadius, style: .continuous))
            }
            .shadow(
                color: isEnabled
                    ? Color.onboardingShadow.opacity(configuration.isPressed ? 0.14 : 0.24)
                    : .clear,
                radius: configuration.isPressed ? 10 : 18,
                x: 0,
                y: configuration.isPressed ? 5 : 10
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(Animation.spring(duration: 0.12, bounce: 0.2), value: configuration.isPressed)
    }
}

private struct OnboardingSecondaryButtonStyle: SwiftUI.ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: OnboardingActionBarMetrics.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isEnabled
                                ? [
                                    Color.onboardingSurfaceElevated,
                                    Color.white.opacity(0.92)
                                ]
                                : [
                                    Color.white.opacity(0.68),
                                    Color.white.opacity(0.58)
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: OnboardingActionBarMetrics.cornerRadius, style: .continuous)
                    .stroke(
                        isEnabled
                            ? Color.borderStrong.opacity(0.72)
                            : Color.border.opacity(0.5),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isEnabled
                    ? Color.onboardingShadow.opacity(configuration.isPressed ? 0.08 : 0.12)
                    : .clear,
                radius: configuration.isPressed ? 8 : 14,
                x: 0,
                y: configuration.isPressed ? 4 : 8
            )
            .brightness(configuration.isPressed ? -0.01 : 0)
            .opacity(isEnabled ? (configuration.isPressed ? 0.98 : 1) : 0.66)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(Animation.spring(duration: 0.12, bounce: 0.2), value: configuration.isPressed)
    }
}

struct SelectionCard: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            OnboardingHaptics.light()
            action()
        } label: {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(isSelected ? Color.white : Color.buttonBottom)
                        .frame(width: 38, height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? Color.white.opacity(0.16) : Color.buttonBottom.opacity(0.12))
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(isSelected ? Color.white : Color.ink)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                        .font(.footnote)
                            .foregroundStyle(isSelected ? Color.white.opacity(0.82) : Color.secondaryText)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.headline)
                    .foregroundStyle(isSelected ? Color.white : Color.helperText.opacity(0.8))
                    .opacity(isSelected ? 1 : 0.85)
                    .scaleEffect(isSelected ? 1 : 0.9)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        isSelected
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        Color.buttonTop,
                                        Color.buttonBottom
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(Color.onboardingSurfaceElevated)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        isSelected
                            ? Color.buttonHighlight.opacity(0.52)
                            : Color.borderStrong.opacity(0.62),
                        lineWidth: isSelected ? 1.4 : 1
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isSelected
                                ? [Color.white.opacity(0.18), Color.clear]
                                : [Color.white.opacity(0.1), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .scaleEffect(isSelected ? 1.008 : 1)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 3)
        .buttonStyle(OnboardingSelectionCardPressStyle())
    }
}

struct FloatingIllustrationOptionCard<Illustration: View>: View {
    let title: String
    var isSelected: Bool
    var height: CGFloat = 96
    var cornerRadius: CGFloat = 30
    var titleFont: Font = .system(size: 22, weight: .medium, design: .rounded)
    var selectedTitleFont: Font = .system(size: 22, weight: .bold, design: .rounded)
    var selectedTitleColor: Color = .black
    var unselectedTitleColor: Color = Color.black.opacity(0.62)
    var titleAlignment: Alignment = .leading
    var titleLeadingPadding: CGFloat = 28
    var titleTrailingPadding: CGFloat = 28
    var illustrationAlignment: Alignment = .bottomTrailing
    var illustrationOffset: CGSize = .zero
    let action: () -> Void
    @ViewBuilder let illustration: Illustration

    var body: some View {
        let purple = Color(red: 0.36, green: 0.12, blue: 0.64)

        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isSelected ? Color.onboardingSurfaceInteractive : Color.onboardingSurfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                isSelected ? Color.buttonBottom.opacity(0.82) : Color.borderStrong.opacity(0.64),
                                lineWidth: isSelected ? 2.2 : 1
                            )
                    )
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isSelected ? 0.28 : 0.16),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: height * 0.42)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
                    .shadow(color: Color.onboardingShadow.opacity(isSelected ? 0.18 : 0.1), radius: isSelected ? 18 : 12, x: 0, y: isSelected ? 10 : 7)

                Text(title)
                    .font(isSelected ? selectedTitleFont : titleFont)
                    .foregroundStyle(isSelected ? Color.ink : Color.secondaryText)
                    .multilineTextAlignment(titleAlignment == .trailing ? .trailing : .leading)
                    .frame(maxWidth: .infinity, alignment: titleAlignment)
                    .padding(.leading, titleLeadingPadding)
                    .padding(.trailing, titleTrailingPadding)
            }
            .overlay(alignment: illustrationAlignment) {
                illustration
                    .offset(illustrationOffset)
                    .allowsHitTesting(false)
            }
            .frame(height: height)
        }
        .buttonStyle(OnboardingSelectionCardPressStyle())
    }
}

struct OnboardingSectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    var headerSpacing: CGFloat = 6
    var contentSpacing: CGFloat = 18
    @ViewBuilder let content: Content

    var body: some View {
        CardSection(fill: AnyShapeStyle(Color.onboardingSurface.opacity(0.98))) {
            VStack(alignment: .leading, spacing: contentSpacing) {
                VStack(alignment: .leading, spacing: headerSpacing) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.ink)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.helperText)
                        .lineSpacing(2)
                }

                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct OnboardingPillOption: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let value: String
}

struct OnboardingPillSelector: View {
    let options: [OnboardingPillOption]
    let selectedValue: String?
    var minItemWidth: CGFloat = 140
    var itemHeight: CGFloat = 48
    let action: (String) -> Void

    @ViewBuilder
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minItemWidth), spacing: 10)], alignment: .leading, spacing: 10) {
            ForEach(options) { option in
                let isSelected = selectedValue == option.value

                Button {
                    OnboardingHaptics.soft()
                    action(option.value)
                } label: {
                    Text(option.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? Color.white : Color.secondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: itemHeight)
                        .background(
                            Capsule(style: .continuous)
                                .fill(
                                    isSelected
                                        ? AnyShapeStyle(
                                            LinearGradient(
                                                colors: [Color.buttonTop, Color.buttonBottom],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        : AnyShapeStyle(Color.onboardingSurfaceElevated)
                                )
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(
                                    isSelected ? Color.buttonHighlight.opacity(0.6) : Color.borderStrong.opacity(0.62),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: isSelected ? Color.onboardingShadow.opacity(0.18) : .clear, radius: 14, x: 0, y: 8)
                }
                .buttonStyle(OnboardingSelectionCardPressStyle())
            }
        }
    }
}

struct OnboardingWheelValuePicker: View {
    let title: String
    let valueText: String
    let selection: Binding<Int>
    let values: [Int]
    var valueFontSize: CGFloat = 34
    var wheelHeight: CGFloat = 140
    var verticalPadding: CGFloat = 6

    @ViewBuilder
    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(valueText)
                    .font(.system(size: valueFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .monospacedDigit()

                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.helperText)
                    .textCase(.uppercase)
                    .tracking(1.1)
            }
            .frame(maxWidth: .infinity)

            Picker(title, selection: selection) {
                ForEach(values, id: \.self) { value in
                    Text("\(value)")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: wheelHeight)
            .clipped()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.onboardingSurfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.borderStrong.opacity(0.62), lineWidth: 1)
        )
    }
}

struct OnboardingSteppedSlider<Option: Hashable>: View {
    let options: [Option]
    let title: (Option) -> String
    let detail: (Option) -> String
    let selection: Option
    var titleFontSize: CGFloat = 28
    var labelFontSize: CGFloat = 12
    var verticalPadding: CGFloat = 10
    let action: (Option) -> Void

    private func index(for option: Option) -> Int {
        options.firstIndex(of: option) ?? 0
    }

    @ViewBuilder
    var body: some View {
        let selectedIndex = index(for: selection)

        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title(selection))
                    .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)

                Text(detail(selection))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.helperText)
            }

            HStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.offset) { item in
                    let index = item.offset
                    let option = item.element

                    Button {
                        OnboardingHaptics.soft()
                        action(option)
                    } label: {
                        VStack(spacing: 10) {
                            Circle()
                                .fill(index <= selectedIndex ? Color.buttonBottom : Color.white.opacity(0.16))
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Circle()
                                        .stroke(index == selectedIndex ? Color.buttonHighlight : Color.borderStrong.opacity(0.5), lineWidth: index == selectedIndex ? 4 : 1)
                                )

                            Text(title(option))
                                .font(.system(size: labelFontSize, weight: index == selectedIndex ? .bold : .semibold, design: .rounded))
                                .foregroundStyle(index == selectedIndex ? Color.ink : Color.helperText)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)

                    if index < options.count - 1 {
                        Rectangle()
                            .fill(index < selectedIndex ? Color.buttonBottom.opacity(0.9) : Color.borderStrong.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .frame(height: 2)
                            .offset(y: -14)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, verticalPadding)
    }
}

private struct OnboardingSelectionCardPressStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
            .brightness(configuration.isPressed ? -0.01 : 0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct OnboardingScreenLayout<Content: View>: View {
    let currentStep: Int
    let totalSteps: Int
    let stepLabel: String
    let eyebrow: String
    let title: String
    let subtitle: String
    let primaryButtonTitle: String
    let primaryButtonEnabled: Bool
    var showsProgressIndicator: Bool = true
    var showsProgressStepLabel: Bool = true
    var showsHeader: Bool = true
    var contentUsesFullWidth: Bool = false
    var usesScrollView: Bool = true
    var contentIgnoresSafeArea: Bool = false
    var showsPrimaryButton: Bool = true
    var showsBackButton: Bool = true
    var onBack: (() -> Void)? = nil
    let onContinue: () -> Void
    @ViewBuilder let content: Content

    @ViewBuilder
    var body: some View {
        let layout = GeometryReader { proxy in
            let horizontalInset: CGFloat = OnboardingActionBarMetrics.horizontalPadding
            let contentWidth = min(max(proxy.size.width - (horizontalInset * 2), 0), 520)
            let layoutInset = contentUsesFullWidth ? 0 : horizontalInset
            let scrollContentWidth = contentUsesFullWidth ? proxy.size.width : contentWidth
            let floatingBottomInset: CGFloat = 0
            let hasActionBar = showsBackButton || showsPrimaryButton
            let actionAreaHeight: CGFloat = hasActionBar ? OnboardingActionBarMetrics.reservedHeight : 0
            let headerTopInset = proxy.safeAreaInsets.top + OnboardingHeaderMetrics.topSafeAreaOffset
            let contentStack = VStack(spacing: 22) {
                content
            }
            .frame(width: scrollContentWidth, alignment: .leading)
            .padding(.top, contentUsesFullWidth ? 0 : 0)
            .padding(.bottom, actionAreaHeight + floatingBottomInset + 20)

            VStack(spacing: OnboardingHeaderMetrics.headerToContentSpacing) {
                if showsProgressIndicator || showsHeader {
                    OnboardingHeaderView(
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        title: showsHeader ? title : "",
                        subtitle: showsHeader ? subtitle : ""
                    )
                    .frame(width: contentWidth)
                    .padding(.top, headerTopInset)
                }

                if usesScrollView {
                    ScrollView(showsIndicators: false) {
                        contentStack
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    contentStack
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, layoutInset)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if hasActionBar {
                    OnboardingActionRow(
                        showsBackButton: showsBackButton,
                        showsPrimaryButton: showsPrimaryButton,
                        backTitle: "back",
                        continueTitle: primaryButtonTitle.lowercased(),
                        primaryButtonEnabled: primaryButtonEnabled,
                        width: contentWidth,
                        horizontalPadding: horizontalInset,
                        bottomPadding: floatingBottomInset,
                        spacing: OnboardingActionBarMetrics.spacing,
                        onBack: onBack,
                        onContinue: onContinue
                    )
                    .padding(.top, OnboardingActionBarMetrics.topInset)
                }
            }
        }
        .background(OnboardingBackgroundView())
        .ignoresSafeArea(.keyboard, edges: .bottom)

        if contentIgnoresSafeArea {
            layout
                .ignoresSafeArea(.container, edges: .all)
        } else {
            layout
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HeroCard(
            eyebrow: "Today",
            title: "Day 12",
            subtitle: "nicotine-free",
            badge: "Finding your rhythm"
        ) {
            Text("Every calm day is building a new normal.")
                .font(.subheadline)
                .foregroundStyle(Color.heroSecondaryText)
        }
        KPIGrid {
            StatCard(title: "Money saved", value: "$102", symbol: "dollarsign")
            StatCard(title: "Urges outlasted", value: "14", symbol: "bolt.heart")
        }
    }
    .padding()
    .background(AppBackground())
}
