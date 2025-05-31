//
//  TableViewCellType.swift
//  WallaMarvel
//
//  Created by Angélica Rodrigues on 29/05/2025.
//
//

import SwiftUI
import UIKit

enum TableViewCellType {
    case heroesList
    case heroesDetailsList
}

class UIHostingTableViewCell<T>: UITableViewCell {
    //<T, Z>
    var cellType: TableViewCellType = .heroesList
    
    var data: T?
//    var type: Z?
    
    var cellAction: (() -> Void)?
    
    private var hostingController: UIHostingController<AnyView>? {
        
        didSet {
            
            oldValue?.view.removeFromSuperview()
            
            contentView.subviews.forEach { $0.removeFromSuperview() }
            
            guard let hostingController = hostingController else { return }
            
            hostingController.view.backgroundColor = .clear
            
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(hostingController.view)
                        
            NSLayoutConstraint.activate([
                
                hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                
                hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                
                hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                
                hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }
    }
    
    func setContent<Content: View>(_ content: () -> Content) {
        
        let rootView = AnyView(content())
        
        let controller = UIHostingController(rootView: rootView)
        
        controller.view.invalidateIntrinsicContentSize()
        hostingController = controller
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        hostingController?.view.invalidateIntrinsicContentSize()
        
        hostingController?.view.frame = contentView.bounds
        
        hostingController?.view.layoutIfNeeded()
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        return hostingController?.view.sizeThatFits(size) ?? super.sizeThatFits(size)
        
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        hostingController = nil
        
    }
    
}

// MARK: UI Hosting Cell

extension UIHostingTableViewCell {
    
    func uiTableViewCell() {
        setContent {
            renderCellView()
        }
    }
}

extension UIHostingTableViewCell {
    
    private func renderCellView() -> some View {
        
        switch cellType {
            
        case .heroesList:
            return AnyView(
                HeroesListUIView(characterDataModel: data as? Character)                
            )
        case .heroesDetailsList:
            return AnyView(
                CharacterDetailView(characterDataModel: data as? Character)
            )
        }
    }
}
