//
//  UIScrollView+JSLayoutSizeFit_Private.h
//  JSLayoutSizeFit
//
//  Created by jiasong on 2021/1/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (JSLayoutSizeFit_Private)

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, __kindof UIView *> *js_allTemplateViews;
@property (nonatomic, assign, readonly) CGSize js_validViewSize;

- (__kindof UIView *)js_makeTemplateViewIfNecessaryWithViewClass:(Class)viewClass;
- (nullable __kindof UIView *)js_templateViewForViewClass:(Class)viewClass;

@end

NS_ASSUME_NONNULL_END
