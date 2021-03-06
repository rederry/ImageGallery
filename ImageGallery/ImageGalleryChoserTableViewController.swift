//
//  ImageGalleryChoserTableViewController.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/9.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Gallery Cell"
private let choseGallerySegueId = "Chose Gallery"

class ImageGalleryChoserTableViewController: UITableViewController {
    
    var imageGalleries = ImageGalleries()
    
    // MARK: - View Controller Lifecycle
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModel()
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return imageGalleries.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageGalleries.all[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let galleryCell = cell as? ImageGalleryNameTableViewCell {
            galleryCell.titleTextField.text = galleryName(at: indexPath)
            galleryCell.resignationHandler = { [weak self] (currentCell) in
                if let newIndexPath = tableView.indexPath(for: currentCell) {
                    self?.imageGalleries.all[newIndexPath.section][newIndexPath.row].name = galleryCell.titleTextField.text!
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Recently Deleted"
        default:
            return nil
        }
    }
    
    private func selectFirstRow() {
        if tableView(self.tableView, numberOfRowsInSection: 0) > 0 {
            self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            Timer.scheduledTimer(withTimeInterval: 1.1, repeats: false, block: { (timer) in
                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // The Model MUST be in sync with the new state of affairs before you change tableview rows!
            if indexPath.section == 0 {
                tableView.performBatchUpdates({
                    imageGalleries.recentlyDeleted.insert(imageGalleries.galleries.remove(at: indexPath.row), at: 0)
                    tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 1))
                })
                selectFirstRow()
            } else {
                tableView.performBatchUpdates({
                    imageGalleries.recentlyDeleted.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                })
                selectFirstRow()
            }
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 1 {  //, indexPath != lastSelectIndexPath {
//            lastSelectIndexPath = indexPath
            performSegue(withIdentifier: choseGallerySegueId, sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let undelete = UIContextualAction(style: .normal, title: "Undelete", handler: { (contextAction, sourceView, completionHandler) in
                let lastIndex = self.imageGalleries.galleries.count
                self.imageGalleries.galleries.insert(self.imageGalleries.recentlyDeleted.remove(at: indexPath.row), at: lastIndex)
                tableView.moveRow(at: indexPath, to: IndexPath(row: lastIndex, section: 0))
                self.selectFirstRow()
                completionHandler(true)
            })
            return UISwipeActionsConfiguration(actions: [undelete])
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case choseGallerySegueId:
                if let indexPath = sender as? IndexPath {
                    if let ivc = (segue.destination as? UINavigationController)?.visibleViewController as? ImageGalleryCollectionViewController {
                        ivc.imageGallery = imageGalleries.all[indexPath.section][indexPath.row]
                        ivc.navigationItem.title = imageGalleries.all[indexPath.section][indexPath.row].name
                    }
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Private Implementation
    
//    private var lastSelectIndexPath: IndexPath?
    
    private func galleryName(at indexPath: IndexPath) -> String {
        return imageGalleries.all[indexPath.section][indexPath.row].name
    }
    
    @IBAction func newGallery(_ sender: UIBarButtonItem) {
        let gallery = ImageGallery(name: "New Gallery")
        imageGalleries.galleries.append(gallery)
        tableView.reloadData()
        selectFirstRow()
    }
    
    private func setupModel() {
        // Update model
        let im1 = ImageGallery.ImageModel(url: URL(string: "https://i.imgur.com/Wm1xcNZ.jpg")!, aspectRatio: 1.1)
        let im2 = ImageGallery.ImageModel(url: URL(string: "https://i.imgur.com/pDygWBH.jpg")!, aspectRatio: 1.7)
        let im3 = ImageGallery.ImageModel(url: URL(string: "https://i.imgur.com/a8uy2uy.png")!, aspectRatio: 0.8)
        let ig1 = ImageGallery(name: "New Gallery")
        let ig2 = ImageGallery(name: "Deleted Gallery")
        ig2.addImage(image: im1)
        ig2.addImage(image: im2)
        ig2.addImage(image: im3)
        imageGalleries.galleries.append(ig1)
        imageGalleries.recentlyDeleted.append(ig2)
    }

}
