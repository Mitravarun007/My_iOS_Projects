import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage("userDisplayName") private var userDisplayName: String = "Jyotindrakumar"

    @State private var showSaveBillsFlow = false
    @State private var showClaimNowFlow = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hi, \(userDisplayName)!")
                        .font(.title.bold())
                    Text("Welcome to Claims,")
                        .foregroundStyle(.secondary)
                    Text("What would you like to do today?")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                HomeActionCard(
                    icon: "doc.badge.arrow.up",
                    tint: .blue,
                    title: "Save Bills",
                    subtitle: "Capture or Upload a bill for Travel or Other Claims"
                ) {
                    showSaveBillsFlow = true
                }

                HomeActionCard(
                    icon: "doc.badge.plus",
                    tint: .orange,
                    title: "Claim Now",
                    subtitle: "Raise a Claim with or without bills"
                ) {
                    showClaimNowFlow = true
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Claims")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSaveBillsFlow) {
            NavigationStack {
                CategorySelectionView()
            }
        }
        .sheet(isPresented: $showClaimNowFlow) {
            NavigationStack {
                MyBillsView(startOnUnclaimedForRaise: true)
            }
        }
    }
}

private struct HomeActionCard: View {
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(tint)
                    .frame(width: 36, height: 36)
                    .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { HomeView() }
        .modelContainer(for: [Bill.self, Claim.self, ClaimTag.self], inMemory: true)
}
