//
//  ITTestHeaderFooterView.h
//  JSLayoutSizeFit
//
//  Created by jiasong on 2020/9/3.
//  Copyright © 2020 RuanMei. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ITTestHeaderFooterView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *nameLabel;

- (void)updateViewWithData:(id)data inSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
