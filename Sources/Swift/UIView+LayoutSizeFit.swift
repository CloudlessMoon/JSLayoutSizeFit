//
//  UIView+LayoutSizeFit.swift
//  JSLayoutSizeFit
//
//  Created by jiasong on 2021/1/13.
//

import UIKit

public extension LayoutSizeFitWrapper where Base: UIView {
    
    var isUseFrameLayout: Bool {
        get {
            return self.base.js_isUseFrameLayout
        }
        set {
            self.base.js_isUseFrameLayout = newValue
        }
    }
    
    var isFromTemplateView: Bool {
        return self.base.js_isFromTemplateView
    }
    
}
