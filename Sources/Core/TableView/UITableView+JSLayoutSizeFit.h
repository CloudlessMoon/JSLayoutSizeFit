//
//  UITableView+JSLayoutSizeFit.h
//  JSLayoutSizeFit
//
//  Created by jiasong on 2020/9/3.
//  Copyright © 2020 RuanMei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JSLayoutSizeFitCache;

NS_ASSUME_NONNULL_BEGIN

typedef void(^JSConfigurationTableViewCell)(__kindof UITableViewCell *cell);
typedef void(^JSConfigurationTableViewSection)(__kindof UITableViewHeaderFooterView *headerFooterView);

@interface UITableView (JSLayoutSizeFit)

@property (null_resettable, nonatomic, strong) id<JSLayoutSizeFitCache> js_fittingHeightCache;

- (BOOL)js_containsCacheKey:(id<NSCopying>)cacheKey;

- (void)js_setFittingHeight:(CGFloat)height forCacheKey:(id<NSCopying>)cacheKey;

- (CGFloat)js_fittingHeightForCacheKey:(id<NSCopying>)cacheKey;

- (void)js_invalidateFittingHeightForCacheKey:(id<NSCopying>)cacheKey;
- (void)js_invalidateAllFittingHeight;

/// Cell
- (CGFloat)js_fittingHeightForCellClass:(Class)cellClass
                             cacheByKey:(nullable id<NSCopying>)key
                          configuration:(nullable JSConfigurationTableViewCell)configuration;

- (CGFloat)js_fittingHeightForCellClass:(Class)cellClass
                            atIndexPath:(nullable NSIndexPath *)indexPath
                             cacheByKey:(nullable id<NSCopying>)key
                          configuration:(nullable JSConfigurationTableViewCell)configuration;

/// Section
- (CGFloat)js_fittingHeightForSectionClass:(Class)sectionClass
                                cacheByKey:(nullable id<NSCopying>)key
                             configuration:(nullable JSConfigurationTableViewSection)configuration;

@end

NS_ASSUME_NONNULL_END
