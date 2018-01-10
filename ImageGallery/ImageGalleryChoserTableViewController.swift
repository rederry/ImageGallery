//
//  ImageGalleryChoserTableViewController.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/9.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Gallery Cell"

class ImageGalleryChoserTableViewController: UITableViewController {
    
    var imageGalleries = ImageGalleries()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update model
        let im1 = ImageModel(url: URL(string: "https://i.imgur.com/Wm1xcNZ.jpg")!, aspectRatio: 1.1)
        let im2 = ImageModel(url: URL(string: "https://i.imgur.com/pDygWBH.jpg")!, aspectRatio: 1.7)
        let im3 = ImageModel(url: URL(string: "https://i.imgur.com/a8uy2uy.png")!, aspectRatio: 0.8)
        let ig1 = ImageGallery(name: "image gallery 1")
        let ig2 = ImageGallery(name: "image gallery deleted 1")
        ig1.addImage(image: im1)
        ig1.addImage(image: im2)
        ig2.addImage(image: im3)
        imageGalleries.galleries.append(ig1)
        imageGalleries.recentlyDeleted.append(ig2)

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
        cell.textLabel?.text = galleryName(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        default:
            return "Recently Deleted"
        }
    }
    
    private func galleryName(at indexPath: IndexPath) -> String {
        return imageGalleries.all[indexPath.section][indexPath.row].name
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
