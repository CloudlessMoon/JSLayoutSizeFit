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

- (__kindof UIView *)js_makeTemplateViewIfNecessaryWithViewClass:(Class)viewClass nibName:(nullable NSString *)nibName inBundle:(nullable NSBundle *)bundle {
    if (![viewClass isSubclassOfClass:UIView.class]) {
        NSAssert(NO, @"viewClass必须为UIView类或者其子类");
        return nil;
    }
    
    __kindof UIView *templateView = [self js_templateViewForViewClass:viewClass];
    if (!templateView) {
        NSString *viewClassString = NSStringFromClass(viewClass);
        NSArray<UIView *> *templateNibs = nil;
        if (nibName.length > 0) {
            UINib *nib = [UINib nibWithNibName:nibName bundle:bundle];
            templateNibs = [nib instantiateWithOwner:nil options:nil];
        } else {
            NSBundle *resourceBundle = bundle ? : [NSBundle bundleForClass:viewClass];
            NSString *nibPath = [resourceBundle pathForResource:viewClassString ofType:@"nib"];
            if (nibPath) {
                templateNibs = [resourceBundle loadNibNamed:viewClassString owner:nil options:nil];
            }
        }
        if (templateNibs.count > 0) {
            for (UIView *templateNib in templateNibs) {
                if ([templateNib isKindOfClass:viewClass]) {
                    templateView = templateNib;
                    break;
                }
            }
        } else {
            templateView = [[viewClass alloc] initWithFrame:CGRectZero];
        }
        
        templateView.hidden = YES;
        templateView.js_fromTemplateView = YES;
        
        NSAssert(templateView, @"生成失败, 需要查找原因");
        [self.js_allTemplateViews setValue:templateView forKey:viewClassString];
    }
    return templateView;
}

- (nullable __kindof UIView *)js_templateViewForViewClass:(Class)viewClass {
    if (![viewClass isSubclassOfClass:UIView.class]) {
        NSAssert(NO, @"viewClass必须为UIView类或者其子类");
        return nil;
    }
    
    NSString *viewClassString = NSStringFromClass(viewClass);
    return [self.js_allTemplateViews objectForKey:viewClassString];
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

- (NSMutableDictionary *)js_allTemplateViews {
    NSMutableDictionary *templateViews = objc_getAssociatedObject(self, _cmd);
    if (!templateViews) {
        templateViews = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, templateViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return templateViews;
}

@end
