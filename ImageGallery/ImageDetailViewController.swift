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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight?.constant = scrollView.contentSize.height
        scrollViewWidth?.constant = scrollView.contentSize.width
    }
    
    // MARK: - Private Implementations
    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 1/10
            scrollView.maximumZoomScale = 2.0
            scrollView.addSubview(imageView)
            scrollView.delegate = self
        }
    }
    @IBOutlet private weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var scrollViewWidth: NSLayoutConstraint!
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            scrollView?.zoomScale = 1
            imageView.image = newValue
            imageView.sizeToFit()
            let size = imageView.bounds.size
            scrollView?.contentSize = size
            scrollViewHeight?.constant = size.height
            scrollViewWidth?.constant = size.width
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data), url == self?.imageURL {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
    }

}
