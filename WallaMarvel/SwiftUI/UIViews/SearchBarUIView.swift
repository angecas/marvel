//
//  SearchBarUIView.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 30/05/2025.
//

import SwiftUI
import UIKit
import Combine

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        TextField("Search...", text: $searchText)
            .padding(.all, 10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal, 6)
    }
}
