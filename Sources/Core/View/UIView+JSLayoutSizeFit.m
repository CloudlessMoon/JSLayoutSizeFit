//
//  UIView+JSLayoutSizeFit.m
//  JSLayoutSizeFit
//
//  Created by jiasong on 2020/9/19.
//

#import "UIView+JSLayoutSizeFit.h"
#import "UIView+JSLayoutSizeFit_Private.h"
#import "JSCoreKit.h"

@implementation UIView (JSLayoutSizeFit)

JSSynthesizeBOOLProperty(js_isUseFrameLayout, setJs_useFrameLayout)
JSSynthesizeBOOLProperty(js_fromTemplateView, setJs_fromTemplateView)

- (CGSize)js_templateSizeThatFits:(CGSize)size {
    CGSize resultSize = CGSizeZero;
    if (self.js_isFromTemplateView) {
        /// js_fixedSize会拦截view.sizeThatFits返回fixedSize, 这里先设置为JSCoreViewFixedSizeNone防止被拦截
        CGSize fixedSize = self.js_fixedSize;
        self.js_fixedSize = JSCoreViewFixedSizeNone;
        resultSize = [self sizeThatFits:size];
        self.js_fixedSize = fixedSize;
    } else {
        resultSize = [self sizeThatFits:size];
    }
    return resultSize;
}

- (void)js_setRealTableViewCell:(__kindof UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if (![cell isKindOfClass:UITableViewCell.class] || cell.isHidden || !indexPath) {
        return;
    }
    
    [self.js_allRealTableViewCells setObject:cell forKey:indexPath];
}

- (nullable __kindof UITableViewCell *)js_realTableViewCellForIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }

    __kindof UITableViewCell *cell = [self.js_allRealTableViewCells objectForKey:indexPath];
    if ([cell isKindOfClass:UITableViewCell.class] && !cell.isHidden) {
        return cell;
    } else {
        return nil;
    }
}

#pragma mark - Getter

- (BOOL)js_isFromTemplateView {
    return self.js_fromTemplateView;
}

- (nullable __kindof UIView *)js_templateContentView {
    UIView *contentView = nil;
    if ([self isKindOfClass:UITableViewCell.class]) {
        contentView = [(UITableViewCell *)self contentView];
    } else if ([self isKindOfClass:UITableViewHeaderFooterView.class]) {
        contentView = [(UITableViewHeaderFooterView *)self contentView];
    } else if ([self isKindOfClass:UICollectionViewCell.class]) {
        contentView = [(UICollectionViewCell *)self contentView];
    }
    return contentView;
}

- (NSMapTable<NSIndexPath *, __kindof UITableViewCell *> *)js_allRealTableViewCells {
    NSMapTable *keyCahces = objc_getAssociatedObject(self, @selector(js_allRealTableViewCells));
    if (!keyCahces) {
        keyCahces = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        objc_setAssociatedObject(self, @selector(js_allRealTableViewCells), keyCahces, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return keyCahces;
}

@end
