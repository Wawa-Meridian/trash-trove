import SwiftUI

// MARK: - Full Screen Loading

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.treasure600)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

// MARK: - Inline Loading

struct InlineLoadingView: View {
    var message: String?

    var body: some View {
        HStack(spacing: 10) {
            ProgressView()
                .tint(Color.treasure600)

            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "Loading")
    }
}

// MARK: - Skeleton Card

struct SkeletonCardView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo placeholder
            Rectangle()
                .fill(shimmerGradient)
                .aspectRatio(4.0 / 3.0, contentMode: .fill)

            // Details placeholder
            VStack(alignment: .leading, spacing: 10) {
                // Title
                RoundedRectangle(cornerRadius: 4)
                    .fill(shimmerGradient)
                    .frame(height: 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 40)

                // Location
                RoundedRectangle(cornerRadius: 4)
                    .fill(shimmerGradient)
                    .frame(width: 140, height: 12)

                // Date and time
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(shimmerGradient)
                        .frame(width: 100, height: 12)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(shimmerGradient)
                        .frame(width: 80, height: 12)
                }

                // Category pills
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(shimmerGradient)
                            .frame(width: 70, height: 22)
                    }
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .accessibilityHidden(true)
    }

    private var shimmerGradient: some ShapeStyle {
        Color(.systemGray5).opacity(isAnimating ? 0.6 : 1.0)
    }
}

// MARK: - Skeleton List

struct SkeletonSaleListView: View {
    var count: Int = 3

    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<count, id: \.self) { _ in
                SkeletonCardView()
            }
        }
        .accessibilityLabel("Loading sales")
    }
}

// MARK: - Previews

#Preview("Full Screen Loading") {
    LoadingView(message: "Finding nearby sales...")
}

#Preview("Inline Loading") {
    VStack(spacing: 20) {
        InlineLoadingView(message: "Loading more results...")
        InlineLoadingView()
    }
}

#Preview("Skeleton Card") {
    ScrollView {
        SkeletonSaleListView(count: 3)
            .padding()
    }
}
