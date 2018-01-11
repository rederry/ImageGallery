//
//  ImageGalleryNameTableViewCell.swift
//  ImageGallery
//
//  Created by KangKang on 2018/1/11.
//  Copyright © 2018年 KangKang. All rights reserved.
//

import UIKit

class ImageGalleryNameTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(beginEditing))
            tap.numberOfTapsRequired = 2
            addGestureRecognizer(tap)
            titleTextField.delegate = self
        }
    }
    
    var resignationHandler: ((UITableViewCell) -> Void)?
    
    @objc func beginEditing() {
        titleTextField.isEnabled = true
        titleTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isEnabled = false
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?(self)
    }

}
