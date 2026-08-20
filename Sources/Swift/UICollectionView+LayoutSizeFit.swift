//
//  UICollectionView+LayoutSizeFit.swift
//  JSLayoutSizeFit
//
//  Created by jiasong on 2021/1/13.
//

import UIKit

public extension LayoutSizeFitWrapper where Base: UICollectionView {
    
    var fittingSizeCache: JSLayoutSizeFitCache {
        get {
            return self.base.js_fittingSizeCache
        }
        set {
            self.base.js_fittingSizeCache = newValue
        }
    }
    
    func containsCacheKey(_ cacheKey: String) -> Bool {
        return self.base.js_containsCacheKey(cacheKey as NSString)
    }
    
    func setFittingSize(_ size: CGSize, for cacheKey: String) {
        self.base.js_setFitting(size, forCacheKey: cacheKey as NSString)
    }
    
    func fittingSize(for cacheKey: String) -> CGSize {
        return self.base.js_fittingSize(forCacheKey: cacheKey as NSString)
    }
    
    func invalidateFittingSize(for cacheKey: String) {
        self.base.js_invalidateFittingSize(forCacheKey: cacheKey as NSString)
    }
    
    func invalidateAllFittingSize() {
        self.base.js_invalidateAllFittingSize()
    }
    
    // swiftlint:disable force_cast
    
    func fittingSize<ReusableView: UICollectionReusableView>(
        forReusableViewClass viewClass: ReusableView.Type,
        cacheBy key: String? = nil,
        configuration: ((ReusableView) -> Void)? = nil
    ) -> CGSize {
        return self.base.js_fittingSize(
            forReusableViewClass: viewClass,
            cacheByKey: key as? NSString
        ) { (reusableView) in
            configuration?(reusableView as! ReusableView)
        }
    }
    
    func fittingSize<ReusableView: UICollectionReusableView>(
        forReusableViewClass viewClass: ReusableView.Type,
        contentWidth: CGFloat,
        cacheBy key: String? = nil,
        configuration: ((ReusableView) -> Void)? = nil
    ) -> CGSize {
        return self.base.js_fittingSize(
            forReusableViewClass: viewClass,
            contentWidth: contentWidth,
            cacheByKey: key as? NSString
        ) { (reusableView) in
            configuration?(reusableView as! ReusableView)
        }
    }
    
    func fittingSize<ReusableView: UICollectionReusableView>(
        forReusableViewClass viewClass: ReusableView.Type,
        maximumContentWidth: CGFloat,
        cacheBy key: String? = nil,
        configuration: ((ReusableView) -> Void)? = nil
    ) -> CGSize {
        return self.base.js_fittingSize(
            forReusableViewClass: viewClass,
            maximumContentWidth: maximumContentWidth,
            cacheByKey: key as? NSString
        ) { (reusableView) in
            configuration?(reusableView as! ReusableView)
        }
    }
    
    func fittingSize<ReusableView: UICollectionReusableView>(
        forReusableViewClass viewClass: ReusableView.Type,
        contentHeight: CGFloat,
        cacheBy key: String? = nil,
        configuration: ((ReusableView) -> Void)? = nil
    ) -> CGSize {
        return self.base.js_fittingSize(
            forReusableViewClass: viewClass,
            contentHeight: contentHeight,
            cacheByKey: key as? NSString
        ) { (reusableView) in
            configuration?(reusableView as! ReusableView)
        }
    }
    
    func fittingSize<ReusableView: UICollectionReusableView>(
        forReusableViewClass viewClass: ReusableView.Type,
        maximumContentHeight: CGFloat,
        cacheBy key: String? = nil,
        configuration: ((ReusableView) -> Void)? = nil
    ) -> CGSize {
        return self.base.js_fittingSize(
            forReusableViewClass: viewClass,
            maximumContentHeight: maximumContentHeight,
            cacheByKey: key as? NSString
        ) { (reusableView) in
            configuration?(reusableView as! ReusableView)
        }
    }
    
    // swiftlint:enable force_cast
    
}
