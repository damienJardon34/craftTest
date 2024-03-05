//
//  ViewController.swift
//  CraftLite
//
//  Created by Damien Jardon on 27/02/2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    // MARK: - Document Model
    
    enum BlockPosition{
        case none
        case top
        case middle
        case bottom
        case single
    }
    
    enum SeparatorStyle{
        case none
        case line
        case section
    }
    
    enum ItemColor {
        case black
        case red
        case green
        case orange
        
        var primaryColor : UIColor {
            get {
                switch self {
                case .black : return #colorLiteral(red: 0.1202401295, green: 0.1327391565, blue: 0.1458084583, alpha: 1)
                case .red : return #colorLiteral(red: 0.9376744032, green: 0.07434072345, blue: 0.1639658213, alpha: 1)
                case .green : return #colorLiteral(red: 0.2336432338, green: 0.710355103, blue: 0.4720264673, alpha: 1)
                case .orange : return #colorLiteral(red: 0.95499295, green: 0.5711356401, blue: 0.01815802045, alpha: 1)
                }
            }
        }
        
        var secondaryColor : UIColor {
            get {
                switch self {
                case .black : return #colorLiteral(red: 0.2529816031, green: 0.2621857822, blue: 0.2752051055, alpha: 1)
                case .red : return #colorLiteral(red: 0.5297382474, green: 0.07548048347, blue: 0.1538034081, alpha: 1)
                case .green : return #colorLiteral(red: 0.1430327892, green: 0.4611076713, blue: 0.3324843943, alpha: 1)
                case .orange : return #colorLiteral(red: 0.5621396899, green: 0.3534098566, blue: 0.06935928762, alpha: 1)
                }
            }
        }
        
        var backgroundColor : UIColor {
            get {
                switch self {
                case .black : return #colorLiteral(red: 0.9725490212, green: 0.9725490212, blue: 0.9725490212, alpha: 1)
                case .red : return #colorLiteral(red: 0.991787374, green: 0.9256435037, blue: 0.9371240735, alpha: 1)
                case .green : return #colorLiteral(red: 0.9252095819, green: 0.9845669866, blue: 0.9643004537, alpha: 1)
                case .orange : return #colorLiteral(red: 0.9942391515, green: 0.9664692283, blue: 0.9230394959, alpha: 1)
                }
            }
        }

    }
    
    struct Item: Hashable{
        var text: String = ""
        var textStyle: UIFont.TextStyle = .body
        var color: ItemColor = .black
        var blockPosition: BlockPosition = .none
        var separatorStyle : SeparatorStyle = .none
        
        private let identifier = UUID()
    }
    
    var document = [
        Item(text: "My Craft Lite Test", textStyle: .title1, color: .green),
        Item(text: "This is a technical test to check some basic feature of Craft",textStyle: .headline, color:.orange, blockPosition: .single),
        Item(separatorStyle: .section),
        Item(text: "1 - Data Model",textStyle: .title2, color:.orange),
        Item(text: "How to represent the structure of the document ?",color:.red, blockPosition: .single),
        Item(text: "The document must handle the colors, the text styles and also the blocks and the separators."),
        Item(separatorStyle: .section),
        Item(text: "2 - Display",textStyle: .title2, color:.orange),
        Item(text: "How to display the document using a UICollectionView ?",color:.red, blockPosition: .single),
        Item(text: "You need to find tricks to handles the blocks adn the section separators"),
        Item(separatorStyle: .section),
        Item(text: "3 - Selection",textStyle: .title2, color:.orange),
        Item(text: "How to select and display a proper selection feedback ?",color:.red, blockPosition: .single),
        Item(text: "You need to make the multi selection enable."),
        Item(text: "Don't forget to make the section separators selectable !",color:.black, blockPosition: .single),
        Item(separatorStyle: .section),
        Item(text: "4 - Drag'n'Drop",textStyle: .title2, color:.orange),
        Item(text: "How drag'n'drop a multi-selection ?",color:.red, blockPosition: .single),
        Item(text: "You need to allow the drag'n'drop of a selection of multiple items. You also need to add a visual feedback while moving the seletion over the document."),
        Item(text: "Don't forget to collapse multiple blocks of the same color.",color:.black, blockPosition: .single)
    ]
    
    // MARK: -
    
    let sectionHeaderElementKind = "section-header-element-kind"
    let sectionFooterElementKind = "section-footer-element-kind"
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, Item>!
    
    let dropHint = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ #colorLiteral(red: 0.1629023254, green: 0.365462184, blue: 0.9643927217, alpha: 1).cgColor , #colorLiteral(red: 0.3481386006, green: 0.6783847809, blue: 0.7677429318, alpha: 1).cgColor]
        gradientLayer.frame = self.view.layer.frame
        self.view.layer.addSublayer(gradientLayer)
        
        
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44.0))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44.0))
        let groupLayout = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                             subitems: [itemLayout])

        let sectionLayout = NSCollectionLayoutSection(group: groupLayout)
        
        let sectionInset = 15.0
        
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0.0,
                                                              leading: sectionInset,
                                                              bottom: 0.0,
                                                              trailing: sectionInset)
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(10))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: sectionHeaderElementKind, alignment: .top)
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: sectionFooterElementKind, alignment: .bottom)
        sectionLayout.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        
        let layout = UICollectionViewCompositionalLayout(section: sectionLayout)
                
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        configureDataSource()
        applySnapshot()
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        dropHint.frame = CGRect(x: 25,
                                y: 0,
                                width: self.view.frame.size.width - 50,
                                height: 2)
        dropHint.backgroundColor = #colorLiteral(red: 0, green: 0.5775085688, blue: 0.9992151856, alpha: 1)
        
    }
    // MARK: - DataSource
    func configureDataSource(){
        // list cell
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            
            var contentConfiguration = UIListContentConfiguration.cell()
            contentConfiguration.text = item.text
            var textProperties = contentConfiguration.textProperties
            textProperties.font = .preferredFont(forTextStyle: item.textStyle)
            textProperties.color = item.color.primaryColor
            contentConfiguration.directionalLayoutMargins = .init(top: 0,
                                                                  leading: 0,
                                                                  bottom: 0,
                                                                  trailing: 0)
            
            let background = UIView()
            background.backgroundColor = .white
            
            
            let selectedBackground = UIView()
            selectedBackground.backgroundColor = .clear
            let selectionColored = UIView()
            selectionColored.translatesAutoresizingMaskIntoConstraints = false
            selectionColored.backgroundColor = #colorLiteral(red: 0, green: 0.5775085688, blue: 0.9992151856, alpha: 1).withAlphaComponent(0.2)
            selectionColored.layer.cornerRadius = 5.0
            selectedBackground.addSubview(selectionColored)
            
            if (item.blockPosition != .none){
                textProperties.color = item.color.secondaryColor
                let coloredBackground = UIView()
                coloredBackground.translatesAutoresizingMaskIntoConstraints = false
                background.addSubview(coloredBackground)
                coloredBackground.backgroundColor = item.color.backgroundColor
                coloredBackground.layer.cornerRadius = 5.0
                let margin = 20.0
                switch item.blockPosition {
                case .top:
                    coloredBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    let constraints = [
                        coloredBackground.topAnchor.constraint(equalTo: background.topAnchor, constant: margin * 0.5),
                        coloredBackground.leftAnchor.constraint(equalTo: background.leftAnchor, constant: margin * 0.5),
                        coloredBackground.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: 0.0),
                        coloredBackground.rightAnchor.constraint(equalTo: background.rightAnchor, constant: margin * -0.5)
                    ]
                    NSLayoutConstraint.activate(constraints)
                    
                    let selectionConstraints = [
                        selectionColored.topAnchor.constraint(equalTo: selectedBackground.topAnchor, constant: margin * 0.8),
                        selectionColored.leftAnchor.constraint(equalTo: selectedBackground.leftAnchor, constant: margin * 0.8),
                        selectionColored.bottomAnchor.constraint(equalTo: selectedBackground.bottomAnchor, constant: 0.0),
                        selectionColored.rightAnchor.constraint(equalTo: selectedBackground.rightAnchor, constant: margin * -0.8)
                    ]
                    NSLayoutConstraint.activate(selectionConstraints)
                    
                    contentConfiguration.directionalLayoutMargins = .init(top: margin,
                                                                          leading: margin,
                                                                          bottom: 0,
                                                                          trailing: margin)
                case .bottom:
                    coloredBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    let constraints = [
                        coloredBackground.topAnchor.constraint(equalTo: background.topAnchor, constant: 0.0),
                        coloredBackground.leftAnchor.constraint(equalTo: background.leftAnchor, constant: margin * 0.5),
                        coloredBackground.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: margin * -0.5),
                        coloredBackground.rightAnchor.constraint(equalTo: background.rightAnchor, constant: margin * -0.5)
                    ]
                    NSLayoutConstraint.activate(constraints)
                    let selectionConstraints = [
                        selectionColored.topAnchor.constraint(equalTo: selectedBackground.topAnchor, constant: 2.0),
                        selectionColored.leftAnchor.constraint(equalTo: selectedBackground.leftAnchor, constant: margin * 0.8),
                        selectionColored.bottomAnchor.constraint(equalTo: selectedBackground.bottomAnchor, constant: margin * -0.8),
                        selectionColored.rightAnchor.constraint(equalTo: selectedBackground.rightAnchor, constant: margin * -0.8)
                    ]
                    NSLayoutConstraint.activate(selectionConstraints)
                    
                    
                    contentConfiguration.directionalLayoutMargins = .init(top: 0,
                                                                          leading: margin,
                                                                          bottom: margin,
                                                                          trailing: margin)
                case .single:
                    let constraints = [
                        coloredBackground.topAnchor.constraint(equalTo: background.topAnchor, constant: margin * 0.5),
                        coloredBackground.leftAnchor.constraint(equalTo: background.leftAnchor, constant: margin * 0.5),
                        coloredBackground.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: margin * -0.5),
                        coloredBackground.rightAnchor.constraint(equalTo: background.rightAnchor, constant: margin * -0.5)
                    ]
                    NSLayoutConstraint.activate(constraints)
                    let selectionConstraints = [
                        selectionColored.topAnchor.constraint(equalTo: selectedBackground.topAnchor, constant: margin * 0.8),
                        selectionColored.leftAnchor.constraint(equalTo: selectedBackground.leftAnchor, constant: margin * 0.8),
                        selectionColored.bottomAnchor.constraint(equalTo: selectedBackground.bottomAnchor, constant: margin * -0.8),
                        selectionColored.rightAnchor.constraint(equalTo: selectedBackground.rightAnchor, constant: margin * -0.8)
                    ]
                    NSLayoutConstraint.activate(selectionConstraints)
                    contentConfiguration.directionalLayoutMargins = .init(top: margin,
                                                                          leading: margin,
                                                                          bottom: margin,
                                                                          trailing: margin)
                default:
                    let constraints = [
                        coloredBackground.topAnchor.constraint(equalTo: background.topAnchor, constant: 0.0),
                        coloredBackground.leftAnchor.constraint(equalTo: background.leftAnchor, constant: margin * 0.5),
                        coloredBackground.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: 0.0),
                        coloredBackground.rightAnchor.constraint(equalTo: background.rightAnchor, constant: margin * -0.5)
                    ]
                    NSLayoutConstraint.activate(constraints)
                    let selectionConstraints = [
                        selectionColored.topAnchor.constraint(equalTo: selectedBackground.topAnchor, constant: 2),
                        selectionColored.leftAnchor.constraint(equalTo: selectedBackground.leftAnchor, constant: margin * 0.8),
                        selectionColored.bottomAnchor.constraint(equalTo: selectedBackground.bottomAnchor, constant: -2),
                        selectionColored.rightAnchor.constraint(equalTo: selectedBackground.rightAnchor, constant: margin * -0.8)
                    ]
                    NSLayoutConstraint.activate(selectionConstraints)
                    contentConfiguration.directionalLayoutMargins = .init(top: 0,
                                                                          leading: margin,
                                                                          bottom: 0,
                                                                          trailing: margin)
                    coloredBackground.layer.cornerRadius = 0.0
                }
            }
            else {
                let selectionConstraints = [
                    selectionColored.topAnchor.constraint(equalTo: selectedBackground.topAnchor, constant: 5.0),
                    selectionColored.leftAnchor.constraint(equalTo: selectedBackground.leftAnchor, constant: 5.0),
                    selectionColored.bottomAnchor.constraint(equalTo: selectedBackground.bottomAnchor, constant: -5.0),
                    selectionColored.rightAnchor.constraint(equalTo: selectedBackground.rightAnchor, constant: -5.0)
                ]
                NSLayoutConstraint.activate(selectionConstraints)
            }
            cell.backgroundView = background
            cell.selectedBackgroundView = selectedBackground
            contentConfiguration.textProperties = textProperties
            cell.contentConfiguration = contentConfiguration
        }
        
        let separatorRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            
            let background = UIView()
            background.backgroundColor = .clear
            
            let topBorder = UIView()
            topBorder.translatesAutoresizingMaskIntoConstraints = false
            background.addSubview(topBorder)
            topBorder.backgroundColor = .white
            topBorder.layer.cornerRadius = 6.0
            topBorder.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            let topConstraints = [
                topBorder.topAnchor.constraint(equalTo: background.topAnchor, constant: 0.0),
                topBorder.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 0.0),
                topBorder.heightAnchor.constraint(equalToConstant: 10.0),
                topBorder.rightAnchor.constraint(equalTo: background.rightAnchor, constant: 0.0)
            ]
            NSLayoutConstraint.activate(topConstraints)
            
            let bottomBorder = UIView()
            bottomBorder.translatesAutoresizingMaskIntoConstraints = false
            background.addSubview(bottomBorder)
            bottomBorder.backgroundColor = .white
            bottomBorder.layer.cornerRadius = 6.0
            bottomBorder.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            let bottomConstraints = [
                bottomBorder.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: 0.0),
                bottomBorder.leftAnchor.constraint(equalTo: background.leftAnchor, constant: 0.0),
                bottomBorder.heightAnchor.constraint(equalToConstant: 10.0),
                bottomBorder.rightAnchor.constraint(equalTo: background.rightAnchor, constant: 0.0)
            ]
            NSLayoutConstraint.activate(bottomConstraints)
        
            cell.backgroundView = background
            
            let selectedBackground = UIView()
            selectedBackground.backgroundColor = .clear
            let selectionColored = UIView()
            selectionColored.translatesAutoresizingMaskIntoConstraints = false
            selectionColored.backgroundColor = #colorLiteral(red: 0, green: 0.5775085688, blue: 0.9992151856, alpha: 1).withAlphaComponent(0.2)
            selectionColored.layer.cornerRadius = 5.0
            selectedBackground.addSubview(selectionColored)
            
            let selectionConstraints = [
                selectionColored.topAnchor.constraint(equalTo: selectedBackground.topAnchor, constant: 0.0),
                selectionColored.leftAnchor.constraint(equalTo: selectedBackground.leftAnchor, constant: 0.0),
                selectionColored.bottomAnchor.constraint(equalTo: selectedBackground.bottomAnchor, constant: -0.0),
                selectionColored.rightAnchor.constraint(equalTo: selectedBackground.rightAnchor, constant: -0.0)
            ]
            NSLayoutConstraint.activate(selectionConstraints)
            cell.selectedBackgroundView = selectedBackground
            
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration <UICollectionReusableView>(elementKind: sectionHeaderElementKind) {
            (supplementaryView, string, indexPath) in
            supplementaryView.backgroundColor = .white
            supplementaryView.layer.cornerRadius = 6.0
            supplementaryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        let footerRegistration = UICollectionView.SupplementaryRegistration <UICollectionReusableView>(elementKind: sectionFooterElementKind) {
            (supplementaryView, string, indexPath) in
            supplementaryView.backgroundColor = .white
            supplementaryView.layer.cornerRadius = 6.0
            supplementaryView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        // data source
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: (item.separatorStyle != .none) ? separatorRegistration  : cellRegistration,
                                                                for: indexPath,
                                                                item: item)
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: kind == self.sectionHeaderElementKind ? headerRegistration : footerRegistration, for: index)
        }
    }
    // MARK: - Snapshot
    func applySnapshot(){
        resetBlocks()
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(document, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func resetBlocks(){
        for (index, _) in document.enumerated(){
            if (document[index].blockPosition != .none){
                document[index].blockPosition = .single
                if (index > 0 &&
                    (document[index - 1].blockPosition == .top || document[index - 1].blockPosition == .middle)){
                    document[index].blockPosition = .bottom
                }
                if (index < document.count - 1 &&
                    document[index + 1].blockPosition != .none &&
                    document[index + 1].color == document[index].color){
                    if (document[index].blockPosition == .bottom){
                        document[index].blockPosition = .middle
                    }
                    else {
                        document[index].blockPosition = .top
                    }
                }
            }
        }
    }
    
    // MARK: - Drag'n'drop
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        let itemProvider = NSItemProvider(object: indexPath.description as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = document[indexPath.row]

        return [dragItem]
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        dragSessionWillBegin session: UIDragSession
    ){
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { collectionView.deselectItem(at: indexPath, animated: false) }
        
        self.view.addSubview(dropHint)
        dropHint.alpha = 0.0

    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if (collectionView.hasActiveDrag){
            if let destination = destinationIndexPath, let cell = collectionView.cellForItem(at: destination){
                let convertFrame = cell.convert(cell.bounds, to: self.view)
                UIView.animate(withDuration: 0.2) {
                    self.dropHint.alpha = 1.0
                    self.dropHint.frame.origin.y = convertFrame.origin.y
                }
            }
            else {
                dropHint.alpha = 0.0
            }
            
            return UICollectionViewDropProposal(operation: .move, intent: .unspecified)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let destinationIndex = coordinator.destinationIndexPath?.row{
            dropHint.alpha = 0.0
            var movedItems : [Item] = []
            var destinationOffset = 0
            var sourceOffset = 0
            for dropItem in coordinator.items {
                if (dropItem.sourceIndexPath!.row < destinationIndex){
                    destinationOffset -= 1
                }
                let sourceIndex = dropItem.sourceIndexPath!.row + sourceOffset
                movedItems.append(document[sourceIndex])
                document.remove(at: sourceIndex)
                sourceOffset -= 1
            }
            for movedItem in movedItems{
                document.insert(movedItem, at: destinationIndex + destinationOffset)
                destinationOffset += 1
            }
            applySnapshot()
        }
    }
}

