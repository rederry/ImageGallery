//
//  ImageGalleryCollectionViewController.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/5.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GalleryImageCell"

class ImageGalleryCollectionViewController: UICollectionViewController, UICollectionViewDropDelegate {
    
    
    // Temporary model
    var imageURLs = [URL]()
    
    func setupImageURLs() {
        if let u1 = URL(string: "https://i.imgur.com/Wm1xcNZ.jpg"), let u2 = URL(string: "https://i.imgur.com/pDygWBH.jpg") {
            imageURLs += [u1, u2]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageURLs()

//        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
    }
    
    // MARK: - UICollectionViewDragDelegate
//    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//
//    }
    
    // MARK: - UICollectionViewDropDelegate
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .copy)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath : IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let item = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(item: item, section: section)
        }
        
        for (index, item) in coordinator.items.enumerated() {
            let indexPath = IndexPath(item: destinationIndexPath.item + index, section: destinationIndexPath.section)
            let placeHolderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: indexPath, reuseIdentifier: "DropPlaceholderCell"))
            item.dragItem.itemProvider.loadObject(ofClass: NSURL.self, completionHandler: { (provider, error) in
                DispatchQueue.main.async {
                    if let url = provider as? NSURL{
                        placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
//                            print("index: \(insertionIndexPath) url: \((url as URL).imageURL)")
                            self.imageURLs.insert((url as URL).imageURL, at: insertionIndexPath.item)
                        })
                    } else {
                        placeHolderContext.deletePlaceholder()
                    }
                }
            })
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
            imageCell.imageURL = imageURLs[indexPath.item]
        }

        return cell
    }
    
    // MARK: - Private Implementations
    

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

}
