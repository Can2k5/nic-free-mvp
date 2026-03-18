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
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.border, lineWidth: 1)
        )
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

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
                    title: "Ayo Pro unlocked.",
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
                    title: "Purchases restored.",
                    message: "Ayo Pro is active on this device."
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
                        .background(Color.cardBackground.opacity(0.56))
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
                .background(Color.cardBackground.opacity(0.56))
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
            .shadow(color: Color.shadowColor.opacity(0.06), radius: 14, x: 0, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.border, lineWidth: 0.9)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
        .background(Color.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    isFocused
                        ? Color.buttonBottom
                        : Color.border,
                    lineWidth: isFocused ? 1.8 : 1.2
                )
        )
        .shadow(
            color: isFocused
                ? Color.buttonBottom.opacity(0.18)
                : Color.shadowColor.opacity(0.07),
            radius: isFocused ? 18 : 12,
            x: 0,
            y: isFocused ? 8 : 6
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
                .font(.headline)
                .foregroundStyle(isEnabled ? Color.white : Color.white.opacity(0.72))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
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
                .font(.headline)
                .foregroundStyle(isEnabled ? Color.ink : Color.secondaryText.opacity(0.72))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
        }
        .disabled(!isEnabled)
        .buttonStyle(OnboardingSecondaryButtonStyle(isEnabled: isEnabled))
    }
}

private struct OnboardingPrimaryButtonStyle: SwiftUI.ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isEnabled
                                ? [
                                    Color(red: 0.62, green: 0.45, blue: 0.99),
                                    Color(red: 0.46, green: 0.25, blue: 0.90)
                                ]
                                : [
                                    Color(red: 0.62, green: 0.45, blue: 0.99).opacity(0.4),
                                    Color(red: 0.46, green: 0.25, blue: 0.90).opacity(0.4)
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(isEnabled ? 0.22 : 0.1), lineWidth: 1)
            )
            .shadow(
                color: isEnabled
                    ? Color(red: 0.46, green: 0.25, blue: 0.90).opacity(configuration.isPressed ? 0.12 : 0.28)
                    : .clear,
                radius: configuration.isPressed ? 10 : 20,
                x: 0,
                y: configuration.isPressed ? 4 : 12
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(Animation.spring(duration: 0.12, bounce: 0.2), value: configuration.isPressed)
    }
}

private struct OnboardingSecondaryButtonStyle: SwiftUI.ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: isEnabled
                                ? [
                                    Color.white.opacity(0.98),
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
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        isEnabled
                            ? Color.border.opacity(0.95)
                            : Color.border.opacity(0.5),
                        lineWidth: 1.15
                    )
            )
            .shadow(
                color: isEnabled
                    ? Color.shadowColor.opacity(configuration.isPressed ? 0.06 : 0.12)
                    : .clear,
                radius: configuration.isPressed ? 8 : 16,
                x: 0,
                y: configuration.isPressed ? 3 : 9
            )
            .brightness(configuration.isPressed ? -0.02 : 0)
            .opacity(isEnabled ? (configuration.isPressed ? 0.97 : 1) : 0.66)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
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
                    .foregroundStyle(isSelected ? Color.white : Color.secondaryText.opacity(0.65))
                    .opacity(isSelected ? 1 : 0)
                    .scaleEffect(isSelected ? 1 : 0.85)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
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
                            : AnyShapeStyle(Color.surface)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        isSelected
                            ? Color.buttonBottom
                            : Color.border,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.buttonTop.opacity(isSelected ? 0.12 : 0), lineWidth: 3)
                    .blur(radius: 4)
            }
            .scaleEffect(isSelected ? 1.008 : 1)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 3)
        .buttonStyle(OnboardingSelectionCardPressStyle())
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
    var showsPrimaryButton: Bool = true
    var showsBackButton: Bool = true
    var onBack: (() -> Void)? = nil
    let onContinue: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { proxy in
            let horizontalInset = max(16, min(24, proxy.size.width * 0.05))
            let contentWidth = min(max(proxy.size.width - (horizontalInset * 2), 0), 520)
            let floatingBottomInset = max(proxy.safeAreaInsets.bottom, 0) + 22
            let hasActionBar = showsBackButton || showsPrimaryButton
            let actionAreaHeight: CGFloat = hasActionBar ? (showsBackButton && showsPrimaryButton ? 76 : 64) : 0

            ZStack(alignment: .bottom) {
                VStack(spacing: 22) {
                    OnboardingProgressIndicator(
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        stepLabel: stepLabel
                    )
                    .frame(width: contentWidth)

                    ScreenHeader(
                        eyebrow: eyebrow,
                        title: title,
                        subtitle: subtitle
                    )
                    .frame(width: contentWidth, alignment: .leading)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 22) {
                            content
                        }
                        .frame(width: contentWidth, alignment: .leading)
                        .padding(.top, 6)
                        .padding(.bottom, actionAreaHeight + floatingBottomInset + 20)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, horizontalInset)

                if hasActionBar {
                    HStack(spacing: 12) {
                        if showsBackButton, let onBack {
                            OnboardingSecondaryButton(
                                title: "Back",
                                action: onBack
                            )
                        }

                        if showsPrimaryButton {
                            OnboardingPrimaryButton(
                                title: primaryButtonTitle,
                                isEnabled: primaryButtonEnabled,
                                action: onContinue
                            )
                        }
                    }
                    .frame(width: contentWidth)
                    .padding(.horizontal, horizontalInset)
                    .padding(.bottom, floatingBottomInset)
                }
            }
        }
        .background(AppBackground())
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
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
