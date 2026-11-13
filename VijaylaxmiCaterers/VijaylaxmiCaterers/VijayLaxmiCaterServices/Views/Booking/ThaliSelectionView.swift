//
//  ThaliSelectionView.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

struct ThaliSelectionView: View {
    @EnvironmentObject var cateringService: CateringService
    @Binding var selectedThalis: [ThaliItem]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                Text("Select Thali Options")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose from our delicious thali systems")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            
            // Thali List
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(cateringService.thaliItems) { thali in
                        ThaliSelectionCard(
                            thali: thali,
                            isSelected: selectedThalis.contains { $0.id == thali.id },
                            onToggle: { toggleThali(thali) }
                        )
                    }
                }
                .padding()
            }
            
            // Bottom Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selectedThalis.count) selected")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !selectedThalis.isEmpty {
                        Text("Tap to view details")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.orange)
                        .cornerRadius(25)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
        }
        .navigationTitle("Thali Selection")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleThali(_ thali: ThaliItem) {
        if let index = selectedThalis.firstIndex(where: { $0.id == thali.id }) {
            selectedThalis.remove(at: index)
        } else {
            selectedThalis.append(thali)
        }
    }
}

struct ThaliSelectionCard: View {
    let thali: ThaliItem
    let isSelected: Bool
    let onToggle: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack(alignment: .top) {
                Button(action: onToggle) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(isSelected ? .orange : .gray)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(thali.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if thali.isVegetarian {
                            Image(systemName: "leaf.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        Text("₹\(Int(thali.price))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    Text(thali.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineLimit(isExpanded ? nil : 2)
                }
            }
            
            // Items List (Expandable)
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Includes (\(thali.items.count) items):")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(thali.items, id: \.self) { item in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text(item)
                                    .font(.body)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.top, 5)
                .padding(.leading, 35)
            }
            
            // Show More/Less Button
            Button(action: {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Spacer()
                    
                    Text(isExpanded ? "Show Less" : "View Items (\(thali.items.count))")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Spacer()
                }
            }
            .padding(.leading, 35)
        }
        .padding()
        .background(isSelected ? Color.orange.opacity(0.1) : Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.orange : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    NavigationView {
        ThaliSelectionView(selectedThalis: .constant([]))
            .environmentObject(CateringService())
    }
}