//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/5.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GalleryImageCell"
private let showDetailSegue = "Show Image Detail"

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDropDelegate, UICollectionViewDragDelegate, UICollectionViewDelegateFlowLayout {
    
    var imageGallery = ImageGallery(name: "tt") {
        didSet {
            if !(imageGallery === oldValue) {
                print("reload")
                collectionView?.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(adjustCellWidth))
        collectionView?.addGestureRecognizer(pinch)
        
//        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
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
                        imageGallery.images.remove(at: sourceIndexPath.item)
                        imageGallery.images.insert(ImageModel(url: url as URL, aspectRatio: 1), at: indexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: indexPath, reuseIdentifier: "DropPlaceholderCell"))
                var localAspectRatio = CGFloat()
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
                                let imageModel = ImageModel(url: (url as URL).imageURL, aspectRatio: Double(localAspectRatio))
                                self.imageGallery.images.insert(imageModel, at: insertionIndexPath.item)
                            })
                        } else {
                            placeHolderContext.deletePlaceholder()
                        }
                    }
                })
            }
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageGallery.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageURL = imageGallery.images[indexPath.item].url
        }

        return cell
    }

    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: showDetailSegue, sender: indexPath)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case showDetailSegue:
                if let indexPath = sender as? IndexPath,
                   let imgvc = segue.destination as? ImageDetailViewController {
                    imgvc.imageURL = imageGallery.images[indexPath.item].url
                }
            default: break
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth * CGFloat(imageGallery.images[indexPath.item].aspectRatio))
    }
    
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
