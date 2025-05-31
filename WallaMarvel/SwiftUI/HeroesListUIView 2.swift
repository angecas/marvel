//
//  HeroesListUIView 2.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 30/05/2025.
//


//
//  HeroesListUIView.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 29/05/2025.
//

import SwiftUI

struct HeroesListUIView: View {
    var imageURL: URL?
    var name: String
    var description: String
    var tags: [Url]
//    @State var isExpandingDescription: Bool = false
    
    init(characterDataModel: Character?) {
        self.imageURL = characterDataModel?.thumbnail?.imageURL
        self.name = characterDataModel?.name ?? "No name"
        self.description = characterDataModel?.displayDescription ?? "No description"
        self.tags = characterDataModel?.urls ?? []
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 16) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 110)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(width: 90, height: 110)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    //                    .lineLimit(isExpandingDescription ? nil : 3)
                        .truncationMode(.tail)
                    
                    Spacer()
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            if let type = tag.type, let urlString = tag.url, let url = URL(string: urlString) {
                                Link(destination: url) {
                                    Text(type)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                }
                
                Spacer()
            }
            Divider()
        }
        .padding(8)
        .background(Color.white)
    }
}
