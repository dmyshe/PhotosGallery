//
//  NSSize.swift
//  AnimationTask
//
//  Created by Дмитро  on 22/05/22.
//

import Foundation


extension NSSize {
    public func sizeByScalingProportionally(to newSize: NSSize) -> NSSize {
        let widthToHeight = width / height
        let heightToWidth = height / width
        var result: NSSize = .zero
        
        if width > height {
            if (widthToHeight * newSize.height) >= newSize.width {
                result = NSSize(width: newSize.width, height: heightToWidth * newSize.width)
            } else {
                result = NSSize(width: widthToHeight * newSize.height, height: newSize.height)
            }
        } else if (heightToWidth * newSize.width) >= newSize.height {
            result = NSSize(width: widthToHeight * newSize.height, height: newSize.height)
        } else {
            result = NSSize(width: newSize.width, height: heightToWidth * newSize.width)
            return result
        }
        return result
    }
}
