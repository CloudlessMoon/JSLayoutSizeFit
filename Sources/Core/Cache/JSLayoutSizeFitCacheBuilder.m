//
//  JSLayoutSizeFitCacheBuilder.m
//  JSLayoutSizeFit
//
//  Created by jiasong on 2022/10/17.
//

#import "JSLayoutSizeFitCacheBuilder.h"
#import "JSCoreKit.h"
#import "JSLayoutSizeFitCacheDictionary.h"
#import "UIScrollView+JSLayoutSizeFit_Private.h"

@interface JSLayoutSizeFitCacheBuilder ()

@property (nonatomic, strong) NSMutableDictionary<NSValue *, JSLayoutSizeFitCacheDictionary *> *allSizeFitCaches;

@end

@implementation JSLayoutSizeFitCacheBuilder

- (BOOL)containsCacheKey:(id<NSCopying>)cacheKey inView:(__kindof UIView *)view {
    JSLayoutSizeFitCacheDictionary *cache = [self _fittingValueCacheInView:view];
    return [cache containsKey:cacheKey];
}

- (nullable id)valueForCacheKey:(id<NSCopying>)cacheKey inView:(__kindof UIView *)view {
    JSLayoutSizeFitCacheDictionary *cache = [self _fittingValueCacheInView:view];
    return [cache objectForKey:cacheKey];
}

- (void)setValue:(id)value forCacheKey:(id<NSCopying>)cacheKey inView:(__kindof UIView *)view {
    JSLayoutSizeFitCacheDictionary *cache = [self _fittingValueCacheInView:view];
    [cache setObject:value forKey:cacheKey];
}

- (void)invalidateValueForCacheKey:(id<NSCopying>)cacheKey inView:(__kindof UIView *)view {
    [self.allSizeFitCaches enumerateKeysAndObjectsUsingBlock:^(NSValue *key, JSLayoutSizeFitCacheDictionary *value, BOOL *stop) {
        [value removeObjectForKey:cacheKey];
    }];
}

- (void)invalidateAllValueInView:(__kindof UIView *)view {
    [self.allSizeFitCaches removeAllObjects];
}

#pragma mark - Private

- (JSLayoutSizeFitCacheDictionary *)_fittingValueCacheInView:(__kindof UIView *)view {
    NSValue *key = nil;
    /// UIScrollView
    if ([view isKindOfClass:UIScrollView.class]) {
        __kindof UIScrollView *scrollView = view;
        CGSize insetContainerSize = JSCGSizeToFixed(scrollView.js_insetContainerSize, 3, JSDecimalRoundingRuleRound);
        /// UITableView
        if ([scrollView isKindOfClass:UITableView.class]) {
            key = @(insetContainerSize.width);
        }
        /// UICollectionView
        else if ([view isKindOfClass:UICollectionView.class]) {
            UICollectionView *collectionView = scrollView;
            if ([collectionView.collectionViewLayout isKindOfClass:UICollectionViewFlowLayout.class]) {
                UICollectionViewScrollDirection scrollDirection = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout scrollDirection];
                if (scrollDirection == UICollectionViewScrollDirectionVertical) {
                    key = @(insetContainerSize.width);
                } else if (scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                    key = @(insetContainerSize.height);
                }
            } else {
                key = @(insetContainerSize);
            }
        }
        /// Other
        else {
            key = @(insetContainerSize);
        }
    }
    if (!key) {
        CGSize boundsSize = JSCGSizeToFixed(view.bounds.size, 3, JSDecimalRoundingRuleRound);
        key = @(boundsSize.width);
    }
    JSLayoutSizeFitCacheDictionary *cache = [self.allSizeFitCaches objectForKey:key];
    if (!cache) {
        cache = [[JSLayoutSizeFitCacheDictionary alloc] init];
        [self.allSizeFitCaches setObject:cache forKey:key];
    }
    return cache;
}

- (NSMutableDictionary<NSValue *, JSLayoutSizeFitCacheDictionary *> *)allSizeFitCaches {
    if (!_allSizeFitCaches) {
        _allSizeFitCaches = [NSMutableDictionary dictionary];
    }
    return _allSizeFitCaches;
}

@end
