//
//  TrashBarButtonItem.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/15.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import UIKit

class TrashBarButtonItem: UIBarButtonItem, UIDropInteractionDelegate{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {        
        let dropInteraction = UIDropInteraction(delegate: self)
        let label = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 40, height: 20)))
        label.text = "Trash"
        label.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        label.addInteraction(dropInteraction)
        customView = label
        
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        print(session)
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        print(session)
    }
    
}
