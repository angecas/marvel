//
//  HeroesListUIView 3.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 30/05/2025.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: Character?
    var imageURL: URL?
    @State private var isShowingFullImage = false
    
    init(characterDataModel: Character?) {
        self.character = characterDataModel
        self.imageURL = characterDataModel?.thumbnail?.imageURL
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let modified = character?.modified {
                    Text("Last Modified: \(modified.formattedISODate())")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 180)
                        .clipped()
                        .onTapGesture {
                            isShowingFullImage = true
                        }
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(width: 180, height: 180, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                if let comics = character?.comics?.items, !comics.isEmpty {
                    Text("Comics")
                    .font(.subheadline)

                    ForEach(comics, id: \.resourceURI) { comic in
                        listItemView(title:comic.name ?? "Unknown Comic")
                    }
                }
                
                if let series = character?.series?.items, !series.isEmpty {
                    Text("Series")
                    .font(.subheadline)

                    ForEach(series, id: \.resourceURI) { seriesItem in
                        listItemView(title: seriesItem.name ?? "Unknown Series")
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $isShowingFullImage) {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .padding()
            } placeholder: {
                ProgressView()
            }
        }
    }
    
    func listItemView(title: String) -> some View {
        HStack {
            SwiftUI.Image(systemName: "chevron.right")
                .foregroundColor(.blue)
                .imageScale(.small)
            Text(title)
                .font(.caption)
        }
    }

}
