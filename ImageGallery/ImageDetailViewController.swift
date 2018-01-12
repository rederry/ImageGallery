//
//  ImageDetailViewController.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/11.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController, UIScrollViewDelegate {
    
    var imageURL: URL?

    override func viewDidAppear(_ animated: Bool) {
        if imageView.image == nil{
            fetchImage()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: - Private Implementations
    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 1/25
            scrollView.maximumZoomScale = 1.0
            scrollView.addSubview(imageView)
            scrollView.delegate = self
        }
    }
    
    private var imageView = UIImageView()
    
    private func fetchImage() {
        if let url = imageURL {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data), url == self?.imageURL {
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                            self?.imageView.sizeToFit()
                            self?.scrollView.contentSize = (self?.imageView.frame.size)!
                        }
                    }
                }
            }
        }
    }

}
