//
//  UIColorExtension.swift
//  Pods
//
//  Created by Somnus on 16/6/26.
//
//

import Foundation

public extension UIColor {
    static func RGBA (r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat) -> UIColor {
        return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    static func RGB (r:CGFloat, _ g:CGFloat, _ b:CGFloat) -> UIColor {
        return RGBA(r, g, b, 1);
    }
    
    static func grayColorForValue(value:CGFloat) -> UIColor{
        return self.RGB(value, value, value);
    }
}
