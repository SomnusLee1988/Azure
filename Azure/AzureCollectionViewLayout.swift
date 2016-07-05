//
//  AzureCollectionViewLayout.swift
//  Azure
//
//  Created by Somnus on 16/7/5.
//  Copyright © 2016年 Somnus. All rights reserved.
//

import UIKit

class AzureCollectionViewLayout: UICollectionViewLayout {
    
    var numberOfColumns = 2
    var cellPadding:CGFloat = 0.0
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
    
    override func invalidateLayout() {
        if !cache.isEmpty {
            cache.removeAll()
        }
        
        super.invalidateLayout()
    }
    
    override func prepareLayout() {
        if cache.isEmpty {
            // 2
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth )
            }
            var column = 0
            var yOffset = [CGFloat](count: numberOfColumns, repeatedValue: 0)
            
            // 3
            for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                
                // 4
                let width = columnWidth - cellPadding * 2
                let height = width
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = CGRectInset(frame, cellPadding, cellPadding)
                
                // 5
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                // 6
                //contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                yOffset[column] = yOffset[column] + height
                
                column = column >= (numberOfColumns - 1) ? 0 : ++column
            }
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        let columnHeight = contentWidth / CGFloat(numberOfColumns)
        let contentHeight = CGFloat(collectionView!.numberOfItemsInSection(0) / numberOfColumns) * columnHeight
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }

}
