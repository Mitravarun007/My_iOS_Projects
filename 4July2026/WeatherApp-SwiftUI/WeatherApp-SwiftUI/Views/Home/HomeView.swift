//
//  HomeView.swift
//  WeatherApp-SwiftUI
//
//  Created by Mitravarun Chauhan on 03/07/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    Image(systemName:"mappin")
                        .foregroundColor(Color.red)
                        .foregroundStyle(.tint)
                    
                    Text("Indore")
                        .font(.title2)
                                .fontWeight(.semibold)
                }
                
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 80))
                        .foregroundStyle(.yellow)
                Text("31°C")
                    .font(.system(size: 70))
                        .fontWeight(.bold)
                Text("Sunny")
                    .font(.title2)
                Text("Feels Like 33°")
                    .foregroundStyle(.secondary)
                Text("Humidity 65%")
                Text("Wind 10 km/h")
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        
    }
    
}
#Preview {
    HomeView()
}
