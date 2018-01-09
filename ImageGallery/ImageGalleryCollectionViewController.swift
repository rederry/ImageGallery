//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/5.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GalleryImageCell"

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDropDelegate, UICollectionViewDragDelegate, UICollectionViewDelegateFlowLayout {
    
    // Temporary model
    var imageURLs = [(URL, CGFloat)]()
    
    func setupImageURLs() {
        if let u1 = URL(string: "https://i.imgur.com/Wm1xcNZ.jpg"), let u2 = URL(string: "https://i.imgur.com/pDygWBH.jpg") {
            imageURLs += [(u1, 1.1), (u2, 1.7)]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageURLs()

        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(adjustCellWidth))
        collectionView?.addGestureRecognizer(pinch)
    }
    
    // MARK: - UICollectionViewDragDelegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        print("Dragging")
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    // MARK: - UICollectionViewDropDelegate
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        // TODO: Use and operator
        return session.canLoadObjects(ofClass: NSURL.self) || session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//        let destinationIndexPath : IndexPath
//        if let indexPath = coordinator.destinationIndexPath {
//            destinationIndexPath = indexPath
//        } else {
//            let section = collectionView.numberOfSections - 1
//            let item = collectionView.numberOfItems(inSection: section)
//            destinationIndexPath = IndexPath(item: item, section: section)
//        }
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for (index, item) in coordinator.items.enumerated() {
            
            let indexPath = IndexPath(item: destinationIndexPath.item + index, section: destinationIndexPath.section)
            
            if let sourceIndexPath = item.sourceIndexPath {
                if  let url = item.dragItem.localObject as? NSURL {
                    print("Drag locally with \(url)")
                    collectionView.performBatchUpdates({
                        imageURLs.remove(at: sourceIndexPath.item)
                        imageURLs.insert((url as URL, 1), at: indexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
//                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: indexPath, reuseIdentifier: "DropPlaceholderCell"))
                var localAspectRatio: CGFloat?
                // Load UIImage
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (provider, error) in
                    if let image = provider as? UIImage {
                        localAspectRatio = image.size.height / image.size.width
                    }
                })
                // Load URL
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self, completionHandler: { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? NSURL{
                            placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                // MARK: Warning
                                self.imageURLs.insert(((url as URL).imageURL, localAspectRatio!), at: insertionIndexPath.item)
                            })
                        } else {
                            placeHolderContext.deletePlaceholder()
                        }
                    }
                })
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageURL = imageURLs[indexPath.item].0
        }

        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth * imageURLs[indexPath.item].1)
    }

    // MARK: - UICollectionViewDelegate
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: - Private Implementations
    private var cellWidth: CGFloat = 130
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let itemCell = collectionView?.cellForItem(at: indexPath) as? ImageCollectionViewCell {
//            let provider = NSItemProvider(object: <#T##NSItemProviderWriting#>) TODO
            let item = UIDragItem(itemProvider: NSItemProvider(object: itemCell.imageURL! as NSURL))
            item.localObject = itemCell.imageURL! as NSURL
            return [item]
        } else {
            return []
        }
    }
    
    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    @objc private func adjustCellWidth(byHandlingGestureRecognizedBy recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            flowLayout?.invalidateLayout()
            cellWidth *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
}
