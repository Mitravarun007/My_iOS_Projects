import SwiftUI
import SwiftData

struct NotificationsView: View {
    @Query(sort: \Claim.createdAt, order: .reverse) private var claims: [Claim]

    var body: some View {
        List {
            ForEach(claims.filter { $0.status == .submitted }) { claim in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Claim submitted")
                        .font(.subheadline.bold())
                    Text("\(claim.bills.count) bills • Total \(String(format: "%.2f", claim.totalAmount))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let submittedAt = claim.submittedAt {
                        Text(submittedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .overlay {
            if claims.filter({ $0.status == .submitted }).isEmpty {
                ContentUnavailableView("No Notifications", systemImage: "bell")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}
