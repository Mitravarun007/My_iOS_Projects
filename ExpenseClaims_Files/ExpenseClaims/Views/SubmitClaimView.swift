import SwiftUI
import SwiftData

struct SubmitClaimView: View {
    let claim: Claim

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var agreedToTerms = false
    @State private var isSubmitting = false
    @State private var showConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 24) {
                    VStack(alignment: .leading) {
                        Text("Total Bills").font(.caption).foregroundStyle(.secondary)
                        Text("\(claim.bills.count)").font(.title2.bold())
                    }
                    VStack(alignment: .leading) {
                        Text("Total Amount").font(.caption).foregroundStyle(.secondary)
                        Text(String(format: "%.2f", claim.totalAmount)).font(.title2.bold())
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))

                ForEach(claim.bills) { bill in
                    HStack(spacing: 12) {
                        if let data = bill.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable().scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(bill.category.rawValue).font(.caption2).foregroundStyle(.secondary)
                            Text(bill.vendorName.isEmpty ? "Bill" : bill.vendorName).font(.subheadline.bold())
                            Text(bill.billDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Total").font(.caption2).foregroundStyle(.secondary)
                            Text(bill.formattedAmount).font(.subheadline.bold())
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }

                Toggle(isOn: $agreedToTerms) {
                    Text("I confirm that I have read the terms and conditions related to claims reimbursement policy and I will abide with them.")
                        .font(.footnote)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle("Submit Claim")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                submit()
            } label: {
                if isSubmitting {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Submit Claim").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!agreedToTerms || isSubmitting)
            .padding()
            .background(.bar)
        }
        .alert("Claim Submitted", isPresented: $showConfirmation) {
            Button("Done") { dismiss() }
        } message: {
            Text("Your claim for \(String(format: "%.2f", claim.totalAmount)) has been submitted successfully.")
        }
    }

    private func submit() {
        isSubmitting = true
        for bill in claim.bills {
            bill.status = .raised
        }
        claim.status = .submitted
        claim.submittedAt = .now
        modelContext.insert(claim) // no-op if already tracked
        try? modelContext.save()

        Task {
            try? await Task.sleep(for: .seconds(0.6)) // mirrors the brief "please wait" submit state
            isSubmitting = false
            showConfirmation = true
        }
    }
}
