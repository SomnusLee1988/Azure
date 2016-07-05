//
//  AzureCollectionViewCell.swift
//  Azure
//
//  Created by Somnus on 16/7/5.
//  Copyright © 2016年 Somnus. All rights reserved.
//

import UIKit

class AzureCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var descriptionLabel: UILabel!
    
    override func updateConstraints() {
        super.updateConstraints()
        
        NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: imageView, attribute: .Width, multiplier: 0.75, constant: 1.0).active = true
    }
}
