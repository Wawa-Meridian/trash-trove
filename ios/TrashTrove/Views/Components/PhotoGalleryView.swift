import SwiftUI

struct PhotoGalleryView: View {
    let photos: [SalePhoto]

    @State private var selectedIndex = 0
    @State private var isFullScreen = false

    var body: some View {
        Group {
            if photos.isEmpty {
                emptyPlaceholder
            } else {
                galleryContent
            }
        }
    }

    // MARK: - Gallery Content

    private var galleryContent: some View {
        let sortedPhotos = photos.sorted { $0.displayOrder < $1.displayOrder }

        return ZStack(alignment: .bottom) {
            TabView(selection: $selectedIndex) {
                ForEach(Array(sortedPhotos.enumerated()), id: \.element.id) { index, photo in
                    photoPage(photo: photo)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .aspectRatio(4.0 / 3.0, contentMode: .fit)

            if sortedPhotos.count > 1 {
                pageIndicator(count: sortedPhotos.count)
                    .padding(.bottom, 12)
            }
        }
        .onTapGesture {
            isFullScreen = true
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenPhotoViewer(
                photos: sortedPhotos,
                selectedIndex: $selectedIndex
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Photo gallery, \(photos.count) photos, showing photo \(selectedIndex + 1)")
        .accessibilityHint("Swipe to browse photos. Double tap to view full screen.")
    }

    private func photoPage(photo: SalePhoto) -> some View {
        Group {
            if let url = photo.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        photoErrorView
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.treasure50)
                    @unknown default:
                        photoErrorView
                    }
                }
            } else {
                photoErrorView
            }
        }
        .clipped()
    }

    private func pageIndicator(count: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? Color.white : Color.white.opacity(0.5))
                    .frame(width: 7, height: 7)
                    .scaleEffect(index == selectedIndex ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: selectedIndex)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.black.opacity(0.35))
        .clipShape(Capsule())
    }

    // MARK: - Placeholders

    private var emptyPlaceholder: some View {
        ZStack {
            Color.treasure50
            VStack(spacing: 8) {
                Image(systemName: "camera")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.treasure300)
                Text("No photos")
                    .font(.subheadline)
                    .foregroundStyle(Color.treasure400)
            }
        }
        .aspectRatio(4.0 / 3.0, contentMode: .fit)
        .accessibilityLabel("No photos available")
    }

    private var photoErrorView: some View {
        ZStack {
            Color.treasure50
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundStyle(Color.treasure400)
                Text("Failed to load")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Full Screen Photo Viewer

struct FullScreenPhotoViewer: View {
    let photos: [SalePhoto]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $selectedIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    zoomablePhoto(photo: photo)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close full screen viewer")
                }
                .padding()

                Spacer()

                if photos.count > 1 {
                    Text("\(selectedIndex + 1) / \(photos.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.4))
                        .clipShape(Capsule())
                        .padding(.bottom)
                }
            }
        }
        .onChange(of: selectedIndex) {
            scale = 1.0
            lastScale = 1.0
            offset = .zero
        }
    }

    private func zoomablePhoto(photo: SalePhoto) -> some View {
        Group {
            if let url = photo.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(magnificationGesture)
                            .gesture(scale > 1.0 ? dragGesture : nil)
                            .onTapGesture(count: 2) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    if scale > 1.0 {
                                        scale = 1.0
                                        lastScale = 1.0
                                        offset = .zero
                                    } else {
                                        scale = 2.5
                                        lastScale = 2.5
                                    }
                                }
                            }
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    case .empty:
                        ProgressView()
                            .tint(.white)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .accessibilityLabel(photo.caption ?? "Photo \(photos.firstIndex(where: { $0.id == photo.id }).map { $0 + 1 } ?? 0)")
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1.0), 5.0)
            }
            .onEnded { _ in
                lastScale = 1.0
                if scale < 1.0 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        scale = 1.0
                        offset = .zero
                    }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { _ in
                if scale <= 1.0 {
                    withAnimation {
                        offset = .zero
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview("Photo Gallery - Empty") {
    PhotoGalleryView(photos: [])
}

#Preview("Photo Gallery - With Photos") {
    let photos = (0..<5).map { index in
        SalePhoto(
            id: UUID(),
            saleId: UUID(),
            url: "https://picsum.photos/seed/sale\(index)/800/600",
            caption: "Photo \(index + 1)",
            displayOrder: index
        )
    }

    PhotoGalleryView(photos: photos)
}
