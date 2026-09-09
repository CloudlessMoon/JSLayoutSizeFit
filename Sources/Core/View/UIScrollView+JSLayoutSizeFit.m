//
//  UIScrollView+JSLayoutSizeFit.m
//  JSLayoutSizeFit
//
//  Created by jiasong on 2020/9/19.
//

#import "UIScrollView+JSLayoutSizeFit.h"
#import "UIScrollView+JSLayoutSizeFit_Private.h"
#import "JSCoreKit.h"
#import "JSLayoutSizeFitCache.h"
#import "UIView+JSLayoutSizeFit_Private.h"
#import "UIView+JSLayoutSizeFit.h"

@implementation UIScrollView (JSLayoutSizeFit)

#pragma mark - 生成模板View

- (__kindof UIView *)js_makeTemplateViewIfNecessaryWithViewClass:(Class)viewClass {
    NSAssert([viewClass isSubclassOfClass:UIView.class], @"viewClass必须为UIView类或者其子类");
    if (!viewClass) {
        return [[UIView alloc] init];
    }
    __kindof UIView *templateView = [self js_templateViewForViewClass:viewClass];
    if (!templateView) {
        templateView = [[viewClass alloc] initWithFrame:CGRectZero];
        if (templateView) {
            templateView.hidden = YES;
            templateView.js_fromTemplateView = YES;
            [self.js_allTemplateViews setObject:templateView forKey:viewClass];
        } else {
            NSAssert(NO, @"生成失败, 需要查找原因");
            templateView = [[UIView alloc] init];
        }
    }
    return templateView;
}

- (nullable __kindof UIView *)js_templateViewForViewClass:(Class)viewClass {
    NSAssert([viewClass isSubclassOfClass:UIView.class], @"viewClass必须为UIView类或者其子类");
    if (!viewClass) {
        return nil;
    }
    return [self.js_allTemplateViews objectForKey:viewClass];
}

#pragma mark - Getter

- (CGSize)js_validViewSize {
    UIEdgeInsets contentInset = self.adjustedContentInset;
    
    CGFloat width = (self.js_width ? : self.superview.js_width) ? : self.window.bounds.size.width;
    width -= JSUIEdgeInsetsGetHorizontalValue(contentInset);
    
    CGFloat height = (self.js_height ? : self.superview.js_height) ? : self.window.bounds.size.height;
    height -= JSUIEdgeInsetsGetVerticalValue(contentInset);
    
    return CGSizeMake(MAX(width, 0), MAX(height, 0));
}

- (NSMapTable<Class, __kindof UIView *> *)js_allTemplateViews {
    NSMapTable *templateViews = objc_getAssociatedObject(self, @selector(js_allTemplateViews));
    if (!templateViews) {
        templateViews = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        objc_setAssociatedObject(self, @selector(js_allTemplateViews), templateViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return templateViews;
}

@end
