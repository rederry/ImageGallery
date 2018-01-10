//
//  ImageGalleries.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/10.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import Foundation

class ImageGalleries {
    var galleries = [ImageGallery]()
    var recentlyDeleted = [ImageGallery]()
    var all: [[ImageGallery]] {
        return [galleries, recentlyDeleted]
    }
}
