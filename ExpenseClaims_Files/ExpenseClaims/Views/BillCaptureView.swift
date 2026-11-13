import SwiftUI
import PhotosUI

struct BillCaptureView: View {
    let category: ClaimCategory
    let currency: Currency

    @State private var showCamera = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var navigateToReview = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Capture or upload a receipt for **\(category.rawValue)**")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    showCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    Label("Choose from Library", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .navigationTitle("Claim Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(category.rawValue).font(.caption.bold())
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView(
                onCapture: { image in
                    capturedImage = image
                    showCamera = false
                    navigateToReview = true
                },
                onCancel: { showCamera = false }
            )
            .ignoresSafeArea()
        }
        .onChange(of: photoPickerItem) { _, newItem in
            Task {
                guard let newItem else { return }
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    capturedImage = image
                    navigateToReview = true
                } else {
                    errorMessage = "Couldn't load the selected photo."
                }
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
        .navigationDestination(isPresented: $navigateToReview) {
            if let capturedImage {
                BillReviewView(image: capturedImage, category: category, currency: currency)
            }
        }
    }
}
