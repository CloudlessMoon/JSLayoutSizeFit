//
//  UICollectionView+JSLayoutSizeFit.h
//  JSLayoutSizeFit
//
//  Created by jiasong on 2020/9/19.
//

#import <UIKit/UIKit.h>

@protocol JSLayoutSizeFitCache;

NS_ASSUME_NONNULL_BEGIN

typedef void(^JSConfigurationReusableView)(__kindof UICollectionReusableView *reusableView);

@interface UICollectionView (JSLayoutSizeFit)

@property (null_resettable, nonatomic, strong) id<JSLayoutSizeFitCache> js_fittingSizeCache;

- (BOOL)js_containsCacheKey:(id<NSCopying>)cacheKey;

- (void)js_setFittingSize:(CGSize)size forCacheKey:(id<NSCopying>)cacheKey;

- (CGSize)js_fittingSizeForCacheKey:(id<NSCopying>)cacheKey;

- (void)js_invalidateFittingSizeForCacheKey:(id<NSCopying>)cacheKey;
- (void)js_invalidateAllFittingSize;

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration;

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                                contentWidth:(CGFloat)contentWidth
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration;

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                         maximumContentWidth:(CGFloat)maximumContentWidth
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration;

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                               contentHeight:(CGFloat)contentHeight
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration;

- (CGSize)js_fittingSizeForReusableViewClass:(Class)viewClass
                        maximumContentHeight:(CGFloat)maximumContentHeight
                                  cacheByKey:(nullable id<NSCopying>)key
                               configuration:(nullable JSConfigurationReusableView)configuration;

@end

NS_ASSUME_NONNULL_END
