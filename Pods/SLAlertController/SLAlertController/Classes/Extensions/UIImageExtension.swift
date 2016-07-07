//
//  UIImageExtension.swift
//  Pods
//
//  Created by Somnus on 16/6/24.
//
//

import Foundation
import UIKit

public extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSizeMake(1, 1)) {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }
    
    func imageWithColor(color:UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let context:CGContextRef = UIGraphicsGetCurrentContext()!;
        CGContextTranslateCTM(context, 0, self.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, .Normal);
        let rect = CGRectMake(0, 0, self.size.width, self.size.height);
        CGContextClipToMask(context, rect, self.CGImage);
        color.setFill();
        CGContextFillRect(context, rect);
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    func imageFitInSize(viewsize:CGSize) -> UIImage
    {
        // calculate the fitted size
        let size:CGSize = self.fitSize(self.size, inSize: viewsize);
        
        UIGraphicsBeginImageContext(viewsize);
        
        let dwidth:CGFloat = (viewsize.width - size.width) / 2.0;
        let dheight:CGFloat = (viewsize.height - size.height) / 2.0;
        
        let rect:CGRect = CGRectMake(dwidth, dheight, size.width, size.height);
        self.drawInRect(rect);
        
        let newimg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newimg;
    }
    
    func fitSize(thisSize:CGSize, inSize aSize:CGSize) -> CGSize
    {
        var scale:CGFloat;
        var newsize = thisSize;
        
        if (newsize.height > 0) && (newsize.height > aSize.height) {
            
            scale = aSize.height / newsize.height;
            newsize.width *= scale;
            newsize.height *= scale;
        }
        
        if (newsize.width > 0) && (newsize.width >= aSize.width) {
            
            scale = aSize.width / newsize.width;
            newsize.width *= scale;
            newsize.height *= scale;
        }
        
        return newsize;
    }
}
