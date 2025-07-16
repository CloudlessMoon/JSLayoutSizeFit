//
//  UICollectionView+JSLayoutSizeFit.m
//  JSLayoutSizeFit
//
//  Created by jiasong on 2020/9/19.
//

#import "UICollectionView+JSLayoutSizeFit.h"
#import "JSCoreKit.h"
#import "JSLayoutSizeFitCache.h"
#import "JSLayoutSizeFitCacheBuilder.h"
#import "UIScrollView+JSLayoutSizeFit_Private.h"
#import "UIScrollView+JSLayoutSizeFit.h"
#import "UIView+JSLayoutSizeFit_Private.h"
#import "UIView+JSLayoutSizeFit.h"

@implementation UICollectionView (JSLayoutSizeFit)

#pragma mark - LayoutSizeFitCache

- (JSLayoutSizeFitCacheBuilder *)js_defaultFittingSizeCache {
    JSLayoutSizeFitCacheBuilder *cache = objc_getAssociatedObject(self, @selector(js_defaultFittingSizeCache));
    if (!cache) {
        cache = [[JSLayoutSizeFitCacheBuilder alloc] init];
        objc_setAssociatedObject(self, @selector(js_defaultFittingSizeCache), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

- (id<JSLayoutSizeFitCache>)js_fittingSizeCache {
    id<JSLayoutSizeFitCache> sizeCache = objc_getAssociatedObject(self, @selector(js_fittingSizeCache));
    if (!sizeCache) {
        sizeCache = self.js_defaultFittingSizeCache;
    }
    return sizeCache;
}

- (void)setJs_fittingSizeCache:(id<JSLayoutSizeFitCache>)js_fittingSizeCache {
    objc_setAssociatedObject(self, @selector(js_fittingSizeCache), js_fittingSizeCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)js_containsCacheKey:(id<NSCopying>)cacheKey {
    return [self.js_fittingSizeCache containsCacheKey:cacheKey inView:self];
}

- (void)js_setFittingSize:(CGSize)size forCacheKey:(id<NSCopying>)cacheKey {
    [self.js_fittingSizeCache setValue:[NSValue valueWithCGSize:size] forCacheKey:cacheKey inView:self];
}

- (CGSize)js_fittingSizeForCacheKey:(id<NSCopying>)cacheKey {
    id value = [self.js_fittingSizeCache valueForCacheKey:cacheKey inView:self];
    if ([value isKindOfClass:NSValue.class]) {
        return [(NSValue *)value CGSizeValue];
    } else {
        return CGSizeZero;
    }
}

- (void)js_invalidateFittingSizeForCacheKey:(id<NSCopying>)cacheKey {
    [self.js_fittingSizeCache invalidateValueForCacheKey:cacheKey inView:self];
}

- (void)js_invalidateAllFittingSize {
    [self.js_fittingSizeCache invalidateAllValueInView:self];
}

#pragma mark - UICollectionReusableView

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration {
    return [self __js_fittingSizeForReusableViewClass:viewClass
                                          contentSize:CGSizeZero
                                        isMaximumSize:NO
                                           cacheByKey:key
                                        configuration:configuration];
}

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                                contentWidth:(CGFloat)contentWidth
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration {
    NSAssert(contentWidth >= 0, @"contentWidth必须 >= 0");
    
    return [self __js_fittingSizeForReusableViewClass:viewClass
                                          contentSize:CGSizeMake(contentWidth, 0)
                                        isMaximumSize:NO
                                           cacheByKey:key
                                        configuration:configuration];
}

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                         maximumContentWidth:(CGFloat)maximumContentWidth
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration {
    NSAssert(maximumContentWidth >= 0, @"maximumContentWidth必须 >= 0");
    
    return [self __js_fittingSizeForReusableViewClass:viewClass
                                          contentSize:CGSizeMake(maximumContentWidth, 0)
                                        isMaximumSize:YES
                                           cacheByKey:key
                                        configuration:configuration];
}

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                               contentHeight:(CGFloat)contentHeight
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration {
    NSAssert(contentHeight >= 0, @"contentHeight必须 >= 0");
    
    return [self __js_fittingSizeForReusableViewClass:viewClass
                                          contentSize:CGSizeMake(0, contentHeight)
                                        isMaximumSize:NO
                                           cacheByKey:key
                                        configuration:configuration];
}

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                        maximumContentHeight:(CGFloat)maximumContentHeight
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration {
    NSAssert(maximumContentHeight >= 0, @"maximumContentHeight必须 >= 0");
    
    return [self __js_fittingSizeForReusableViewClass:viewClass
                                          contentSize:CGSizeMake(0, maximumContentHeight)
                                        isMaximumSize:YES
                                           cacheByKey:key
                                        configuration:configuration];
}

#pragma mark - Private

- (CGSize)__js_fittingSizeForReusableViewClass:(Class)viewClass
                                   contentSize:(CGSize)contentSize
                                 isMaximumSize:(BOOL)isMaximumSize
                                    cacheByKey:(nullable id<NSCopying>)key
                                 configuration:(nullable JSConfigurationReusableView)configuration {
    NSAssert([viewClass isSubclassOfClass:UICollectionReusableView.class], @"viewClass必须为UICollectionReusableView类或者其子类");
    
    CGSize resultSize = CGSizeZero;
    if (key != nil && [self js_containsCacheKey:key]) {
        resultSize = [self js_fittingSizeForCacheKey:key];
    } else {
        /// 制作/获取模板View
        __kindof UICollectionReusableView *templateView = [self js_makeTemplateViewIfNecessaryWithViewClass:viewClass nibName:nil inBundle:nil];
        
        /// 准备
        [self js_prepareForTemplateView:templateView contentSize:contentSize configuration:configuration];
        
        /// 计算size
        resultSize = [self js_fittingSizeForTemplateView:templateView contentSize:contentSize finallySize:templateView.js_size];
        
        /// 设置外部的宽/高
        if (isMaximumSize) {
            if (contentSize.width > 0) {
                resultSize.width = MIN(resultSize.width, contentSize.width);
            }
            if (contentSize.height > 0) {
                resultSize.height = MIN(resultSize.height, contentSize.height);
            }
        } else {
            if (contentSize.width > 0) {
                resultSize.width = contentSize.width;
            }
            if (contentSize.height > 0) {
                resultSize.height = contentSize.height;
            }
        }
        
        /// 若Key存在时则写入内存
        if (key != nil) {
            [self js_setFittingSize:resultSize forCacheKey:key];
        }
    }
    
    return resultSize;
}

- (void)js_prepareForTemplateView:(__kindof UIView *)templateView
                      contentSize:(CGSize)contentSize
                    configuration:(nullable JSConfigurationReusableView)configuration {
    UIView *contentView = templateView.js_templateContentView;
    
    CGSize fixedSize = templateView.js_fixedSize;
    if (contentSize.width > 0 && contentSize.height <= 0) {
        fixedSize.height = 0;
    } else if (contentSize.height > 0 && contentSize.width <= 0) {
        fixedSize.width = 0;
    }
    BOOL isChangeFixedSize = NO;
    if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
        isChangeFixedSize = CGSizeEqualToSize(fixedSize, JSCoreViewFixedSizeNone);
    } else {
        isChangeFixedSize = !CGSizeEqualToSize(fixedSize, contentSize);
    }
    if (isChangeFixedSize) {
        /// 计算出最小size, 防止约束或布局冲突
        CGSize minimumSize = [self js_fittingSizeForTemplateView:templateView contentSize:contentSize finallySize:contentSize];
        
        CGSize maximumSize = CGSizeMake(MAX(contentSize.width, minimumSize.width),
                                        MAX(contentSize.height, minimumSize.height));
        templateView.js_fixedSize = maximumSize;
        contentView.js_fixedSize = maximumSize;
        
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

- (CGSize)js_fittingSizeForTemplateView:(__kindof UIView *)templateView contentSize:(CGSize)contentSize finallySize:(CGSize)finallySize {
    CGSize fittingSize = CGSizeZero;
    if (templateView.js_isUseFrameLayout) {
        fittingSize = [templateView js_templateSizeThatFits:finallySize];
    } else {
        UILayoutPriority horizontalPriority = contentSize.width > 0 && contentSize.height <= 0 ? UILayoutPriorityRequired : UILayoutPriorityFittingSizeLevel;
        UILayoutPriority verticalPriority = contentSize.height > 0 && contentSize.width <= 0 ? UILayoutPriorityRequired : UILayoutPriorityFittingSizeLevel;
        fittingSize = [templateView systemLayoutSizeFittingSize:finallySize
                                  withHorizontalFittingPriority:horizontalPriority
                                        verticalFittingPriority:verticalPriority];
    }
    
    return fittingSize;
}

@end
