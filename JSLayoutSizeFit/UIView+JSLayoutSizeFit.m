//
//  UIView+JSLayoutSizeFit.m
//  JSLayoutSizeFit
//
//  Created by jiasong on 2020/9/3.
//  Copyright © 2020 RuanMei. All rights reserved.
//

#import "UIView+JSLayoutSizeFit.h"
#import "JSCommonDefines.h"

@implementation UIView (JSLayoutSizeFit)

JSSynthesizeBOOLProperty(js_enforceFrameLayout, setJs_enforceFrameLayout)
JSSynthesizeIdStrongProperty(js_widthFenceConstraint, setJs_widthFenceConstraint)

- (nullable __kindof UIView *)js_templateContentView {
    UIView *contentView = nil;
    if ([self isKindOfClass:UITableViewCell.class]) {
        contentView = [(UITableViewCell *)self contentView];
    } else if ([self isKindOfClass:UITableViewHeaderFooterView.class]) {
        contentView = [(UITableViewHeaderFooterView *)self contentView];
    }
    return contentView;
}

@end
