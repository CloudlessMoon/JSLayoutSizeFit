//
//  JSTableViewController.m
//  JSLayoutSizeFitExample
//
//  Created by jiasong on 2020/9/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSTableViewController.h"
#import <QMUIKit.h>
#import <Masonry.h>
#import <JSLayoutSizeFit.h>
#import "ITTestTableViewCell.h"
#import "ITTestHeaderFooterView.h"

@interface JSTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation JSTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        BeginIgnoreDeprecatedWarning
        self.automaticallyAdjustsScrollViewInsets = NO;
        EndIgnoreClangWarning
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view.mas_width);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    NSString *dataPath = [NSBundle.mainBundle pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (array && [array isKindOfClass:NSArray.class]) {
        NSMutableArray *dataSource = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *newDic = [dic mutableCopy];
            NSString *idValue = [NSString stringWithFormat:@"section-%@", @(idx)];
            [newDic setValue:idValue forKey:@"id"];
            NSMutableArray *newList = [[dic objectForKey:@"likeList"] mutableCopy];
            [newList.copy enumerateObjectsUsingBlock:^(NSDictionary *itemDic, NSUInteger idx1, BOOL * _Nonnull stop) {
                NSMutableDictionary *newItemDic = [itemDic mutableCopy];
                [newItemDic setValue:[NSString stringWithFormat:@"%@ item-%@", idValue, @(idx1)] forKey:@"id"];
                [newList replaceObjectAtIndex:idx1 withObject:newItemDic];
            }];
            [newDic setValue:newList forKey:@"likeList"];
            [dataSource addObject:newDic];
        }];
        self.dataSource = dataSource.copy;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.qmui_initialContentInset = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, self.view.safeAreaInsets.bottom, 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = [self.dataSource objectAtIndex:section];
    NSArray *array = [dic objectForKey:@"likeList"];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = [self.dataSource objectAtIndex:section];
    return [tableView js_fittingHeightForSectionClass:ITTestHeaderFooterView.class
                                           cacheByKey:[dic objectForKey:@"id"]
                                        configuration:^(__kindof ITTestHeaderFooterView * _Nonnull headerFooterView) {
        [headerFooterView updateViewWithData:dic inSection:section];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.section];
    NSArray *array = [dic objectForKey:@"likeList"];
    return [tableView js_fittingHeightForCellClass:ITTestTableViewCell.class
                                       atIndexPath:indexPath
                                        cacheByKey:[[array objectAtIndex:indexPath.row] objectForKey:@"id"]
                                     configuration:^(__kindof ITTestTableViewCell *cell) {
        [cell updateCellWithData:[array objectAtIndex:indexPath.row] atIndexPath:indexPath];
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *dataSource = [self.dataSource mutableCopy];
    NSMutableDictionary *dic = [[self.dataSource objectAtIndex:indexPath.section] mutableCopy];
    NSMutableArray *array = [[dic objectForKey:@"likeList"] mutableCopy];
    NSMutableDictionary *itemDic = [[array objectAtIndex:indexPath.row] mutableCopy];
    [itemDic setValue:NSUUID.UUID.UUIDString forKey:@"content"];
    [array replaceObjectAtIndex:indexPath.row withObject:itemDic];
    [dic setValue:array forKey:@"likeList"];
    [dataSource replaceObjectAtIndex:indexPath.section withObject:dic];
    
    [self.tableView js_invalidateFittingHeightForCacheKey:[itemDic objectForKey:@"id"]];
    self.dataSource = dataSource;
    [self.tableView reloadData];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ITTestHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(ITTestHeaderFooterView.class)];
    NSDictionary *dic = [self.dataSource objectAtIndex:section];
    [headerFooterView updateViewWithData:dic inSection:section];
    return headerFooterView;
}

- (ITTestTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ITTestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ITTestTableViewCell.class) forIndexPath:indexPath];
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.section];
    NSArray *array = [dic objectForKey:@"likeList"];
    [cell updateCellWithData:[array objectAtIndex:indexPath.row] atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.editing = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        /// 需要设置为0，否则在iOS 11.0之后会产生跳动的问题
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        [_tableView registerClass:ITTestTableViewCell.class forCellReuseIdentifier:NSStringFromClass(ITTestTableViewCell.class)];
        [_tableView registerClass:ITTestHeaderFooterView.class forHeaderFooterViewReuseIdentifier:NSStringFromClass(ITTestHeaderFooterView.class)];
    }
    return _tableView;
}

@end
