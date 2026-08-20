//
//  UITableView+LayoutSizeFit.swift
//  JSLayoutSizeFit
//
//  Created by jiasong on 2021/1/13.
//

import UIKit

public extension LayoutSizeFitWrapper where Base: UITableView {
    
    var fittingHeightCache: JSLayoutSizeFitCache {
        get {
            return self.base.js_fittingHeightCache
        }
        set {
            self.base.js_fittingHeightCache = newValue
        }
    }
    
    func containsCacheKey(_ cacheKey: String) -> Bool {
        return self.base.js_containsCacheKey(cacheKey as NSString)
    }
    
    func setFittingHeight(_ height: CGFloat, for cacheKey: String) {
        self.base.js_setFittingHeight(height, forCacheKey: cacheKey as NSString)
    }
    
    func fittingHeight(for cacheKey: String) -> CGFloat {
        return self.base.js_fittingHeight(forCacheKey: cacheKey as NSString)
    }
    
    func invalidateFittingHeight(for cacheKey: String) {
        self.base.js_invalidateFittingHeight(forCacheKey: cacheKey as NSString)
    }
    
    func invalidateAllFittingHeight() {
        self.base.js_invalidateAllFittingHeight()
    }
    
    // swiftlint:disable force_cast
    
    func fittingHeight<Cell: UITableViewCell>(
        forCellClass cellClass: Cell.Type,
        at indexPath: IndexPath,
        cacheBy key: String? = nil,
        configuration: ((Cell) -> Void)? = nil
    ) -> CGFloat {
        return self.base.js_fittingHeight(
            forCellClass: cellClass,
            at: indexPath,
            cacheByKey: key as NSString?
        ) { (cell) in
            configuration?(cell as! Cell)
        }
    }
    
    func fittingHeight<Section: UITableViewHeaderFooterView>(
        forSectionClass sectionClass: Section.Type,
        cacheBy key: String? = nil,
        configuration: ((Section) -> Void)? = nil
    ) -> CGFloat {
        return self.base.js_fittingHeight(
            forSectionClass: sectionClass,
            cacheByKey: key as NSString?
        ) { (section) in
            configuration?(section as! Section)
        }
    }
    
    // swiftlint:enable force_cast
    
}
