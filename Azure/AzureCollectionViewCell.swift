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
    
    @IBOutlet var coverView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var playButton: SLButton!
    
    @IBOutlet var imageHeightConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let view:UIView = NSBundle.mainBundle().loadNibNamed("AzureCollectionViewCell", owner: self, options: nil)[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        
        self.imageView.layer.cornerRadius = 3.0
        self.imageView.layer.masksToBounds = true
        self.coverView.layer.cornerRadius = 3.0
        self.coverView.layer.masksToBounds = true
        
        self.titleLabel.text = ""
        self.descriptionLabel.text = ""
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        imageHeightConstraint.constant = imageView.frame.width * 0.75
    }
    
    @IBAction func playButtonCliced(sender: AnyObject) {
        
        let button = sender as! SLButton
        
        button.handler()
    }
}
