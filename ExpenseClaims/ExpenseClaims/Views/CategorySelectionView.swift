import SwiftData

import SwiftUI

struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategory: ClaimCategory?
    @State private var selectedCurrency: Currency = .usd
    @State private var navigateToCapture = false

    var body: some View {
        Form {
            Section {
                Picker("Select Category", selection: $selectedCategory) {
                    Text("Select Category").tag(ClaimCategory?.none)
                    ForEach(ClaimCategory.allCases) { category in
                        Label(category.rawValue, systemImage: category.systemImage)
                            .tag(Optional(category))
                    }
                }
            } header: {
                Text("Claim Category *")
            }

            Section {
                Picker("Currency", selection: $selectedCurrency) {
                    ForEach(Currency.allCases) { currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
            } header: {
                Text("Currency")
            }
        }
        .navigationTitle("Save Bills")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Next") { navigateToCapture = true }
                    .disabled(selectedCategory == nil)
            }
        }
        .navigationDestination(isPresented: $navigateToCapture) {
            if let selectedCategory {
                BillCaptureView(category: selectedCategory, currency: selectedCurrency)
            }
        }
    }
}

#Preview {
    NavigationStack { CategorySelectionView() }
        .modelContainer(for: [Bill.self, Claim.self, ClaimTag.self], inMemory: true)
}

