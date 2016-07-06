//
//  SLButton.swift
//  Azure
//
//  Created by Somnus on 16/7/7.
//  Copyright © 2016年 Somnus. All rights reserved.
//

import UIKit

class SLButton: UIButton {
    
    var handler:()->Void = {}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addHandler(handler:()->Void) {
        self.handler = handler
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
