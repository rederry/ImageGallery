//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/10.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import Foundation

class ImageGallery {
    var name: String
    var images = [ImageModel]()
    
    struct ImageModel {
        let url: URL
        let aspectRatio: Double
    }
    
    init(name: String) {
        self.name = name
    }
    
    func addImage(image: ImageModel) {
        images.append(image)
    }
}
