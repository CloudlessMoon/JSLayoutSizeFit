//
//  IndexPath+LayoutSizeFitKey.swift
//  JSLayoutSizeFit
//
//  Created by jiasong on 2021/1/13.
//

import Foundation

public extension LayoutSizeFitWrapper where Base == IndexPath {
    
    var sizeFitCacheKey: String {
        let row = self.base.item != NSNotFound ? self.base.item : self.base.row
        return "section:\(self.base.section)|row:\(row)"
    }
    
}
