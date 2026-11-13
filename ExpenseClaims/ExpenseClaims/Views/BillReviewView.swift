import SwiftUI
import SwiftData

struct BillReviewView: View {
    let image: UIImage
    let category: ClaimCategory
    let currency: Currency

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ClaimTag.createdAt, order: .reverse) private var recentTags: [ClaimTag]

    @State private var isExtracting = true
    @State private var vendorName = ""
    @State private var billDate = Date()
    @State private var amountText = ""
    @State private var rawText: String?
    @State private var extractionError: String?

    @State private var showTagSheet = false
    @State private var tagName = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .center) {
                        if isExtracting {
                            ExtractionOverlay()
                        }
                    }
                    .padding(.horizontal)

                if !isExtracting {
                    VStack(spacing: 14) {
                        LabeledField(title: "Vendor / Hotel / Restaurant") {
                            TextField("Vendor name", text: $vendorName)
                                .textFieldStyle(.roundedBorder)
                        }
                        LabeledField(title: "Bill Date") {
                            DatePicker("", selection: $billDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        LabeledField(title: "Amount (\(currency.rawValue))") {
                            TextField("0.00", text: $amountText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding(.horizontal)

                    if let extractionError {
                        Text(extractionError)
                            .font(.footnote)
                            .foregroundStyle(.orange)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Continue") { showTagSheet = true }
                    .disabled(isExtracting)
            }
        }
        .task {
            await runExtraction()
        }
        .sheet(isPresented: $showTagSheet) {
            TagSelectionSheet(
                recentTags: recentTags,
                tagName: $tagName,
                onConfirm: { finalTag in
                    saveBill(withTag: finalTag)
                }
            )
            .presentationDetents([.medium])
        }
    }

    private func runExtraction() async {
        do {
            let info = try await ReceiptScannerService.extract(from: image)
            vendorName = info.vendorName ?? ""
            billDate = info.date ?? .now
            if let amount = info.amount {
                amountText = String(format: "%.2f", amount)
            }
            rawText = info.rawText
        } catch {
            extractionError = "Automatic extraction failed — please enter the details manually."
        }
        withAnimation { isExtracting = false }
    }

    private func saveBill(withTag tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespaces)
        if !trimmedTag.isEmpty && !recentTags.contains(where: { $0.name == trimmedTag }) {
            modelContext.insert(ClaimTag(name: trimmedTag))
        }

        let bill = Bill(
            category: category,
            currency: currency,
            imageData: image.jpegData(compressionQuality: 0.7),
            vendorName: vendorName,
            billDate: billDate,
            amount: Double(amountText) ?? 0,
            extractedRawText: rawText,
            tagName: trimmedTag.isEmpty ? nil : trimmedTag,
            status: .unclaimed
        )
        modelContext.insert(bill)
        try? modelContext.save()

        showTagSheet = false
        dismiss() // pop back to capture
        // Pop the whole flow off — handled by dismissing the presenting sheet.
        NotificationCenter.default.post(name: .billSavedNotification, object: nil)
    }
}

private struct ExtractionOverlay: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(.blue)
            Text("Extracting bill information\non-device.")
                .font(.footnote.bold())
                .multilineTextAlignment(.center)
            ProgressView()
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content
        }
    }
}

private struct TagSelectionSheet: View {
    let recentTags: [ClaimTag]
    @Binding var tagName: String
    var onConfirm: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your recent tags")
                    .font(.headline)

                if recentTags.isEmpty {
                    Text("No tags yet — type a new one below.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(recentTags) { tag in
                                Button(tag.name) { tagName = tag.name }
                                    .buttonStyle(.bordered)
                                    .tint(tagName == tag.name ? .blue : .gray)
                            }
                        }
                    }
                }

                TextField("Enter tag e.g Client Visit, US Visit 2026", text: $tagName)
                    .textFieldStyle(.roundedBorder)

                Spacer()

                Button {
                    onConfirm(tagName)
                    dismiss()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Tag Bill")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension Notification.Name {
    static let billSavedNotification = Notification.Name("billSavedNotification")
}
