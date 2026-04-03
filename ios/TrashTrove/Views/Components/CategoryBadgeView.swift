import SwiftUI

struct CategoryBadgeView: View {
    let label: String
    var isSelectable: Bool = false
    var isSelected: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        if isSelectable {
            Button {
                onTap?()
            } label: {
                badgeContent
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityLabel("\(label) category")
            .accessibilityHint(isSelectable ? "Double tap to \(isSelected ? "deselect" : "select")" : "")
        } else {
            badgeContent
                .accessibilityLabel("\(label) category")
        }
    }

    private var badgeContent: some View {
        Text(label)
            .font(.caption2.weight(.medium))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: isSelectable ? 1.5 : 0)
            )
    }

    // MARK: - Styling

    private var foregroundColor: Color {
        if isSelectable && isSelected {
            return .white
        }
        return Color.treasure700
    }

    private var backgroundColor: Color {
        if isSelectable && isSelected {
            return Color.treasure600
        }
        return Color.treasure50
    }

    private var borderColor: Color {
        if isSelectable && isSelected {
            return Color.treasure600
        } else if isSelectable {
            return Color.treasure200
        }
        return .clear
    }
}

// MARK: - Preview

#Preview("Category Badges") {
    struct BadgePreview: View {
        @State var selectedCategories: Set<String> = ["Electronics"]

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Display Mode")
                    .font(.headline)

                HStack(spacing: 8) {
                    CategoryBadgeView(label: "Furniture")
                    CategoryBadgeView(label: "Electronics")
                    CategoryBadgeView(label: "Books")
                }

                Divider()

                Text("Selectable Mode")
                    .font(.headline)

                FlowLayout(spacing: 8) {
                    ForEach(SALE_CATEGORIES, id: \.self) { category in
                        CategoryBadgeView(
                            label: category,
                            isSelectable: true,
                            isSelected: selectedCategories.contains(category)
                        ) {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    return BadgePreview()
}

// MARK: - Flow Layout Helper

/// A simple flow layout that wraps children to the next line when they exceed available width.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }

        return (positions, CGSize(width: maxX, height: currentY + lineHeight))
    }
}
