import SwiftUI
import SwiftData

struct MyBillsView: View {
    var startOnUnclaimedForRaise: Bool = false

    @Query(sort: \Bill.createdAt, order: .reverse) private var allBills: [Bill]
    @State private var selectedStatus: BillStatus = .unclaimed
    @State private var selectedBillIDs = Set<PersistentIdentifier>()
    @State private var navigateToRaiseClaim = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("Status", selection: $selectedStatus) {
                ForEach(BillStatus.allCases) { status in
                    Text(status.rawValue).tag(status)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            let bills = allBills.filter { $0.status == selectedStatus }
            let grouped = Dictionary(grouping: bills, by: { $0.tagName ?? "Untagged" })

            if bills.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No \(selectedStatus.rawValue) Bills",
                    systemImage: "doc.text",
                    description: Text(selectedStatus == .unclaimed ? "Save a bill from Home to get started." : "")
                )
                Spacer()
            } else {
                List {
                    ForEach(grouped.keys.sorted(), id: \.self) { tag in
                        Section(header: Text("\(tag) (\(grouped[tag]?.count ?? 0) Bills)")) {
                            ForEach(grouped[tag] ?? []) { bill in
                                BillRow(bill: bill, isSelected: selectedBillIDs.contains(bill.persistentModelID))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        guard selectedStatus == .unclaimed else { return }
                                        toggleSelection(bill)
                                    }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }

            if selectedStatus == .unclaimed && !selectedBillIDs.isEmpty {
                Button {
                    navigateToRaiseClaim = true
                } label: {
                    Text("Raise a claim now (\(selectedBillIDs.count) selected)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .navigationTitle("Claims")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToRaiseClaim) {
            let selected = allBills.filter { selectedBillIDs.contains($0.persistentModelID) }
            RaiseClaimView(bills: selected)
        }
    }

    private func toggleSelection(_ bill: Bill) {
        if selectedBillIDs.contains(bill.persistentModelID) {
            selectedBillIDs.remove(bill.persistentModelID)
        } else {
            selectedBillIDs.insert(bill.persistentModelID)
        }
    }
}

private struct BillRow: View {
    let bill: Bill
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            if let data = bill.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Image(systemName: bill.category.systemImage)
                    .frame(width: 40, height: 40)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 6))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(bill.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text(bill.vendorName.isEmpty ? "Untitled Bill" : bill.vendorName)
                    .font(.subheadline.bold())
                Text(bill.billDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(bill.formattedAmount)
                .font(.subheadline.bold())

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { MyBillsView() }
        .modelContainer(for: [Bill.self, Claim.self, ClaimTag.self], inMemory: true)
}
