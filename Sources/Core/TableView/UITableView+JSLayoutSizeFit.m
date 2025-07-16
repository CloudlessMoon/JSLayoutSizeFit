//
//  UITableView+JSLayoutSizeFit.m
//  JSLayoutSizeFit
//
//  Created by jiasong on 2020/9/3.
//  Copyright © 2020 RuanMei. All rights reserved.
//

#import "UITableView+JSLayoutSizeFit.h"
#import "JSCoreKit.h"
#import "JSLayoutSizeFitCache.h"
#import "JSLayoutSizeFitCacheBuilder.h"
#import "UIScrollView+JSLayoutSizeFit_Private.h"
#import "UIScrollView+JSLayoutSizeFit.h"
#import "UIView+JSLayoutSizeFit_Private.h"
#import "UIView+JSLayoutSizeFit.h"

@implementation UITableView (JSLayoutSizeFit)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JSRuntimeOverrideImplementation(UITableView.class, NSSelectorFromString(@"_configureCellForDisplay:forIndexPath:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, UITableViewCell *cell, NSIndexPath *indexPath) {
                
                // call super，-[UITableViewDelegate tableView:willDisplayCell:forRowAtIndexPath:] 比这个还晚，所以不用担心触发 delegate
                void (*originSelectorIMP)(id, SEL, UITableViewCell *, NSIndexPath *);
                originSelectorIMP = (void (*)(id, SEL, UITableViewCell *, NSIndexPath *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, cell, indexPath);
                
                if (cell.js_width == 0 || cell.contentView.js_width == 0) {
                    return;
                }
                
                __kindof UIView *templateView = [selfObject js_templateViewForViewClass:cell.class];
                if (templateView != nil) {
                    [templateView js_setRealTableViewCell:cell forIndexPath:indexPath];
                }
            };
        });
    });
}

#pragma mark - LayoutSizeFitCache

- (JSLayoutSizeFitCacheBuilder *)js_defaultFittingHeightCache {
    JSLayoutSizeFitCacheBuilder *cache = objc_getAssociatedObject(self, @selector(js_defaultFittingHeightCache));
    if (!cache) {
        cache = [[JSLayoutSizeFitCacheBuilder alloc] init];
        objc_setAssociatedObject(self, @selector(js_defaultFittingHeightCache), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

- (id<JSLayoutSizeFitCache>)js_fittingHeightCache {
    id<JSLayoutSizeFitCache> heightCache = objc_getAssociatedObject(self, @selector(js_fittingHeightCache));
    if (!heightCache) {
        heightCache = self.js_defaultFittingHeightCache;
    }
    return heightCache;
}

- (void)setJs_fittingHeightCache:(id<JSLayoutSizeFitCache>)js_fittingHeightCache {
    objc_setAssociatedObject(self, @selector(js_fittingHeightCache), js_fittingHeightCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)js_containsCacheKey:(id<NSCopying>)cacheKey {
    return [self.js_fittingHeightCache containsCacheKey:cacheKey inView:self];
}

- (void)js_setFittingHeight:(CGFloat)height forCacheKey:(id<NSCopying>)cacheKey {
    [self.js_fittingHeightCache setValue:@(height) forCacheKey:cacheKey inView:self];
}

- (CGFloat)js_fittingHeightForCacheKey:(id<NSCopying>)cacheKey {
    id value = [self.js_fittingHeightCache valueForCacheKey:cacheKey inView:self];
    if ([value isKindOfClass:NSNumber.class]) {
        return [(NSNumber *)value doubleValue];
    } else {
        return 0.0;
    }
}

- (void)js_invalidateFittingHeightForCacheKey:(id<NSCopying>)cacheKey {
    [self.js_fittingHeightCache invalidateValueForCacheKey:cacheKey inView:self];
}

- (void)js_invalidateAllFittingHeight {
    [self.js_fittingHeightCache invalidateAllValueInView:self];
}

#pragma mark - Cell

- (CGFloat)js_fittingHeightForCellClass:(Class)cellClass
                             cacheByKey:(nullable id<NSCopying>)key
                          configuration:(nullable JSConfigurationTableViewCell)configuration {
    return [self js_fittingHeightForCellClass:cellClass
                                  atIndexPath:nil
                                   cacheByKey:key
                                configuration:configuration];
}

- (CGFloat)js_fittingHeightForCellClass:(Class)cellClass
                            atIndexPath:(nullable NSIndexPath *)indexPath
                             cacheByKey:(nullable id<NSCopying>)key
                          configuration:(nullable JSConfigurationTableViewCell)configuration {
    NSAssert([cellClass isSubclassOfClass:UITableViewCell.class], @"cellClass必须是UITableViewCell类或者其子类");
    
    return [self __js_fittingHeightForViewClass:cellClass
                                    atIndexPath:indexPath
                                     cacheByKey:key
                                  configuration:configuration];
}

#pragma mark - Section

- (CGFloat)js_fittingHeightForSectionClass:(Class)sectionClass
                                cacheByKey:(nullable id<NSCopying>)key
                             configuration:(nullable JSConfigurationTableViewSection)configuration {
    NSAssert([sectionClass isSubclassOfClass:UITableViewHeaderFooterView.class], @"sectionClass必须是UITableViewHeaderFooterView类或者其子类");
    
    return [self __js_fittingHeightForViewClass:sectionClass
                                    atIndexPath:nil
                                     cacheByKey:key
                                  configuration:configuration];
}

#pragma mark - Private

- (CGFloat)__js_fittingHeightForViewClass:(Class)viewClass
                              atIndexPath:(nullable NSIndexPath *)indexPath
                               cacheByKey:(nullable id<NSCopying>)key
                            configuration:(nullable void(^)(__kindof UIView *))configuration {
    CGFloat resultHeight = 0;
    if (key != nil && [self js_containsCacheKey:key]) {
        resultHeight = [self js_fittingHeightForCacheKey:key];
    } else {
        /// 制作/获取模板View
        __kindof UIView *templateView = [self js_makeTemplateViewIfNecessaryWithViewClass:viewClass nibName:nil inBundle:nil];
        
        /// 准备
        [self js_prepareForTemplateView:templateView atIndexPath:indexPath configuration:configuration];
        
        /// 计算高度
        resultHeight = [self js_fittingHeightContainsSeparatorForTemplateView:templateView];
        
        /// 写入内存
        if (key != nil) {
            if ([templateView isKindOfClass:UITableViewHeaderFooterView.class]) {
                [self js_setFittingHeight:resultHeight forCacheKey:key];
            } else if ([templateView isKindOfClass:UITableViewCell.class] && (!indexPath || [templateView js_realTableViewCellForIndexPath:indexPath] != nil)) {
                [self js_setFittingHeight:resultHeight forCacheKey:key];
            }
        }
    }
    
    return resultHeight;
}

- (void)js_prepareForTemplateView:(__kindof UIView *)templateView
                      atIndexPath:(nullable NSIndexPath *)indexPath
                    configuration:(nullable void(^)(__kindof UIView *))configuration {
    UIView *contentView = templateView.js_templateContentView;
    
    CGFloat cellWidth = 0;
    CGFloat contentWidth = 0;
    CGFloat insetValue = self.style == UITableViewStyleGrouped + 1 ? JSUIEdgeInsetsGetHorizontalValue(self.layoutMargins) : 0;
    if ([templateView isKindOfClass:UITableViewHeaderFooterView.class]) {
        cellWidth = self.js_validViewSize.width;
        contentWidth = cellWidth - insetValue;
    } else if ([templateView isKindOfClass:UITableViewCell.class]) {
        UITableViewCell *realCell = indexPath ? [templateView js_realTableViewCellForIndexPath:indexPath] : nil;
        if (realCell != nil) {
            cellWidth = realCell.js_width;
            contentWidth = realCell.contentView.js_width;
        } else {
            cellWidth = self.js_validViewSize.width - insetValue;
            contentWidth = cellWidth;
        }
    }
    
    if (templateView.js_fixedSize.width != cellWidth || contentView.js_fixedSize.width != contentWidth) {
        /// 计算出最小height, 防止约束或布局冲突
        CGFloat minimumHeight = [self js_fittingHeightForTemplateView:templateView finallyWidth:contentWidth];
        
        templateView.js_fixedSize = CGSizeMake(cellWidth, minimumHeight);
        contentView.js_fixedSize =  CGSizeMake(contentWidth, minimumHeight);
        
        /// 强制布局, 使外部可以拿到一些控件的真实布局
        [templateView setNeedsLayout];
        [templateView layoutIfNeeded];
    }
    
    if ([templateView respondsToSelector:@selector(prepareForReuse)]) {
        [templateView prepareForReuse];
    }
    if (configuration) {
        configuration(templateView);
    }
}

- (CGFloat)js_fittingHeightContainsSeparatorForTemplateView:(__kindof UIView *)templateView {
    UIView *contentView = templateView.js_templateContentView;
    
    CGFloat fittingHeight = [self js_fittingHeightForTemplateView:templateView finallyWidth:contentView.js_width];
    
    if ([templateView isKindOfClass:UITableViewCell.class] && self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        static CGFloat pixelOne = 1;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            pixelOne = 1 / (UIScreen.mainScreen.scale ? : 1);
        });
        fittingHeight += pixelOne;
    }
    
    return fittingHeight;
}

- (CGFloat)js_fittingHeightForTemplateView:(__kindof UIView *)templateView finallyWidth:(CGFloat)finallyWidth {
    UIView *contentView = templateView.js_templateContentView;
    
    CGFloat fittingHeight = 0;
    if (templateView.js_isUseFrameLayout) {
        fittingHeight = [templateView js_templateSizeThatFits:CGSizeMake(finallyWidth, 0)].height;
    } else {
        fittingHeight = [contentView systemLayoutSizeFittingSize:CGSizeMake(finallyWidth, 0)
                                   withHorizontalFittingPriority:UILayoutPriorityRequired
                                         verticalFittingPriority:UILayoutPriorityFittingSizeLevel].height;
    }
    
    return fittingHeight;
}

@end
