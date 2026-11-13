import SwiftUI
import SwiftData

struct RaiseClaimView: View {
    let bills: [Bill]

    @Environment(\.modelContext) private var modelContext
    @State private var currentIndex = 0
    @State private var perBillEmployeeContribution: [UUID: Double]
    @State private var perBillClientRecoverable: [UUID: Bool]
    @State private var clientEntertained: String
    @State private var attendeeNames: [String]
    @State private var remarks: String
    @State private var confirmedPolicy = false
    @State private var navigateToSubmit = false

    init(bills: [Bill]) {
        self.bills = bills
        _perBillEmployeeContribution = State(initialValue: Dictionary(uniqueKeysWithValues: bills.map { ($0.id, 0) }))
        _perBillClientRecoverable = State(initialValue: Dictionary(uniqueKeysWithValues: bills.map { ($0.id, false) }))
        _clientEntertained = State(initialValue: "")
        _attendeeNames = State(initialValue: [""])
        _remarks = State(initialValue: bills.first?.category.rawValue ?? "")
    }

    private var currentBill: Bill? {
        bills.indices.contains(currentIndex) ? bills[currentIndex] : nil
    }

    var body: some View {
        Form {
            if let bill = currentBill {
                Section {
                    HStack {
                        Button {
                            currentIndex = max(0, currentIndex - 1)
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .disabled(currentIndex == 0)

                        Spacer()
                        VStack {
                            Text("\(currentIndex + 1)/\(bills.count)")
                                .font(.caption).foregroundStyle(.secondary)
                            Text(bill.vendorName.isEmpty ? "Bill" : bill.vendorName)
                                .font(.subheadline.bold())
                        }
                        Spacer()

                        Button {
                            currentIndex = min(bills.count - 1, currentIndex + 1)
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .disabled(currentIndex == bills.count - 1)
                    }
                }

                Section("Bill Date *") {
                    DatePicker("Bill date", selection: Binding(
                        get: { bill.billDate },
                        set: { bill.billDate = $0 }
                    ), displayedComponents: .date)
                    .labelsHidden()
                }

                Section("Bill Amount *") {
                    HStack {
                        Text(bill.currency.rawValue).foregroundStyle(.secondary)
                        TextField("Amount", value: Binding(
                            get: { bill.amount },
                            set: { bill.amount = $0 }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                    }
                }

                Section("Employee Contribution") {
                    HStack {
                        Text(bill.currency.rawValue).foregroundStyle(.secondary)
                        TextField("0", value: Binding(
                            get: { perBillEmployeeContribution[bill.id] ?? 0 },
                            set: { perBillEmployeeContribution[bill.id] = $0 }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                    }
                }

                Section {
                    Toggle("Client Recoverable", isOn: Binding(
                        get: { perBillClientRecoverable[bill.id] ?? false },
                        set: { perBillClientRecoverable[bill.id] = $0 }
                    ))
                }

                Section("Client Entertained *") {
                    TextField("Client name", text: $clientEntertained)
                }

                Section("Name of Hotel/Restaurant *") {
                    TextField("Vendor name", text: Binding(
                        get: { bill.vendorName },
                        set: { bill.vendorName = $0 }
                    ))
                }

                Section {
                    ForEach(attendeeNames.indices, id: \.self) { i in
                        HStack {
                            Text("TCS").foregroundStyle(.secondary)
                            TextField("Enter Employee Name", text: Binding(
                                get: { attendeeNames[i] },
                                set: { attendeeNames[i] = $0 }
                            ))
                        }
                    }
                    Button {
                        attendeeNames.append("")
                    } label: {
                        Label("Add Row", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Attendee Details *")
                }

                Section("Remarks *") {
                    TextField("Remarks", text: $remarks, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle(isOn: $confirmedPolicy) {
                        Text("I confirm that the expenses claimed herewith are in compliance with company policy.")
                            .font(.footnote)
                    }
                }
            }
        }
        .navigationTitle("Raise Claim")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button("Save as Draft") { saveClaim(status: .draft) }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)

                Button("Next") { navigateToSubmit = true }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(!confirmedPolicy || clientEntertained.isEmpty)
            }
            .padding()
            .background(.bar)
        }
        .navigationDestination(isPresented: $navigateToSubmit) {
            SubmitClaimView(claim: buildClaim())
        }
    }

    private func buildClaim() -> Claim {
        // Ensure bills are not already tied to another claim to avoid relationship conflicts
        for bill in bills {
            if let existingClaim = bill.claim {
                // Detach bill from existing claim
                existingClaim.bills.removeAll(where: { $0.id == bill.id })
                bill.claim = nil
            }
        }

        let totalEmployeeContribution = perBillEmployeeContribution.values.reduce(0, +)
        let claim = Claim(
            status: .draft,
            employeeContribution: totalEmployeeContribution,
            clientRecoverable: perBillClientRecoverable.values.contains(true),
            clientEntertained: clientEntertained,
            hotelOrRestaurantName: bills.first?.vendorName ?? "",
            attendeeNames: attendeeNames.filter { !$0.isEmpty },
            remarks: remarks,
            bills: bills
        )
        return claim
    }

    private func saveClaim(status: ClaimStatus) {
        // Update bill statuses based on desired claim status
        for bill in bills {
            bill.status = status == .draft ? .draft : .raised
        }

        // Try to reuse an existing claim that already owns these bills
        var claimToSave: Claim?
        if let firstBill = bills.first, let existingClaim = firstBill.claim, Set(existingClaim.bills.map { $0.id }) == Set(bills.map { $0.id }) {
            claimToSave = existingClaim
            // Update properties on existing claim
            let totalEmployeeContribution = perBillEmployeeContribution.values.reduce(0, +)
            existingClaim.employeeContribution = totalEmployeeContribution
            existingClaim.clientRecoverable = perBillClientRecoverable.values.contains(true)
            existingClaim.clientEntertained = clientEntertained
            existingClaim.hotelOrRestaurantName = bills.first?.vendorName ?? ""
            existingClaim.attendeeNames = attendeeNames.filter { !$0.isEmpty }
            existingClaim.remarks = remarks
        } else {
            // Build a fresh claim after detaching bills from any prior claim
            claimToSave = buildClaim()
            if let claimToSave { modelContext.insert(claimToSave) }
        }

        claimToSave?.status = status

        do {
            try modelContext.save()
        } catch {
            // You may want to surface this to the UI later
            assertionFailure("Failed to save claim: \(error)")
        }
    }
}
