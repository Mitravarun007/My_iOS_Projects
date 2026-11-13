//
//  MenuView.swift
//  VijayLaxmiCaterServices
//
//  Created on 17/11/2025.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var cateringService: CateringService
    @State private var selectedTab: MenuTab = .thali
    
    enum MenuTab: String, CaseIterable {
        case thali = "Thali System"
        case buffet = "Buffet Items"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Bar
                MenuTabBar(selectedTab: $selectedTab)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    ThaliMenuView()
                        .tag(MenuTab.thali)
                    
                    BuffetMenuView()
                        .tag(MenuTab.buffet)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Our Menu")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MenuTabBar: View {
    @Binding var selectedTab: MenuView.MenuTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MenuView.MenuTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(tab.rawValue)
                            .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? .orange : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Color.orange : Color.clear)
                            .frame(height: 3)
                            .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Thali Menu View
struct ThaliMenuView: View {
    @EnvironmentObject var cateringService: CateringService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(cateringService.thaliItems) { thali in
                    ThaliCard(thali: thali)
                }
            }
            .padding()
        }
    }
}

struct ThaliCard: View {
    let thali: ThaliItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(thali.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if thali.isVegetarian {
                            Image(systemName: "leaf.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(thali.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineLimit(isExpanded ? nil : 2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("₹\(Int(thali.price))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("per plate")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Items list
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Includes:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(thali.items, id: \.self) { item in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text(item)
                                    .font(.body)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.top, 5)
            }
            
            // Expand/Collapse button
            Button(action: {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? "Show Less" : "Show Items")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Buffet Menu View
struct BuffetMenuView: View {
    @EnvironmentObject var cateringService: CateringService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(BuffetCategory.allCases) { category in
                    BuffetCategorySection(category: category)
                }
            }
            .padding()
        }
    }
}

struct BuffetCategorySection: View {
    let category: BuffetCategory
    @EnvironmentObject var cateringService: CateringService
    
    private var categoryItems: [BuffetItem] {
        cateringService.getBuffetItems(for: category)
    }
    
    private var categoryIcon: String {
        switch category {
        case .starter: return "flame.fill"
        case .mainCourse: return "fork.knife"
        case .dessert: return "birthday.cake"
        case .drinks: return "cup.and.saucer.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Category Header
            HStack {
                Image(systemName: categoryIcon)
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text(category.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Items
            ForEach(categoryItems) { item in
                BuffetItemCard(item: item)
            }
        }
    }
}

struct BuffetItemCard: View {
    let item: BuffetItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if item.isVegetarian {
                        Image(systemName: "leaf.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Text(item.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("₹\(Int(item.pricePerPerson))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text("per person")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    MenuView()
        .environmentObject(CateringService())
}