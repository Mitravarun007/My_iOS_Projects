//
//  BuffetSelectionView.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

struct BuffetSelectionView: View {
    @EnvironmentObject var cateringService: CateringService
    @Binding var selectedBuffetItems: [BuffetItem]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: BuffetCategory = .starter
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                Text("Select Buffet Items")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose items from different categories")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            
            // Category Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(BuffetCategory.allCases) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            .background(Color.white)
            
            // Items List
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(cateringService.getBuffetItems(for: selectedCategory)) { item in
                        BuffetItemSelectionCard(
                            item: item,
                            isSelected: selectedBuffetItems.contains { $0.id == item.id },
                            onToggle: { toggleBuffetItem(item) }
                        )
                    }
                }
                .padding()
            }
            
            // Bottom Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selectedBuffetItems.count) items selected")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !selectedBuffetItems.isEmpty {
                        let totalPrice = selectedBuffetItems.reduce(0) { $0 + $1.pricePerPerson }
                        Text("₹\(Int(totalPrice)) per person")
                            .font(.caption)
                            .foregroundColor(.orange)
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
        .navigationTitle("Buffet Selection")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleBuffetItem(_ item: BuffetItem) {
        if let index = selectedBuffetItems.firstIndex(where: { $0.id == item.id }) {
            selectedBuffetItems.remove(at: index)
        } else {
            selectedBuffetItems.append(item)
        }
    }
}

struct CategoryButton: View {
    let category: BuffetCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    private var categoryIcon: String {
        switch category {
        case .starter: return "flame.fill"
        case .mainCourse: return "fork.knife"
        case .dessert: return "birthday.cake"
        case .drinks: return "cup.and.saucer.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: categoryIcon)
                    .font(.body)
                
                Text(category.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .orange)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.orange : Color.orange.opacity(0.1))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange, lineWidth: 1)
                    .opacity(isSelected ? 0 : 1)
            )
        }
    }
}

struct BuffetItemSelectionCard: View {
    let item: BuffetItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            // Selection Button
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .orange : .gray)
            }
            
            // Item Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if item.isVegetarian {
                        Image(systemName: "leaf.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("₹\(Int(item.pricePerPerson))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("per person")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(item.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(3)
                
                // Category Tag
                HStack {
                    Text(item.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                }
            }
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
        BuffetSelectionView(selectedBuffetItems: .constant([]))
            .environmentObject(CateringService())
    }
}