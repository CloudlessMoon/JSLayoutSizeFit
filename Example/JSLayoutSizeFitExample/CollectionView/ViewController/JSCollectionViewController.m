//
//  JSCollectionViewController.m
//  JSLayoutSizeFitExample
//
//  Created by jiasong on 2020/9/19.
//  Copyright © 2020 jiasong. All rights reserved.
//

#import "JSCollectionViewController.h"
#import <QMUIKit.h>
#import <Masonry.h>
#import <JSLayoutSizeFit/JSLayoutSizeFit.h>
#import "JSTestCollectionViewCell.h"
#import "JSTestCollectionReusableView.h"

@interface JSCollectionViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, copy) NSArray *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation JSCollectionViewController

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
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.width.equalTo(self.view.mas_width);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    NSString *dataPath = [NSBundle.mainBundle pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (array && [array isKindOfClass:NSArray.class]) {
        self.dataSource = array;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.qmui_initialContentInset = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, self.view.safeAreaInsets.bottom, 0);
}

#pragma mark - UICollectionViewDelegate

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 20, 0, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return [collectionView js_fittingSizeForReusableViewClass:JSTestCollectionReusableView.class
                                                 contentWidth:collectionView.qmui_width
                                                   cacheByKey:@(section)
                                                configuration:^(__kindof UICollectionReusableView * _Nonnull reusableView) {
        NSDictionary *dic = [self.dataSource objectAtIndex:section];
        [reusableView updateViewWithData:dic atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView js_fittingSizeForReusableViewClass:JSTestCollectionViewCell.class
                                                contentHeight:30
                                                   cacheByKey:indexPath.js_sizeFitCacheKey
                                                configuration:^(__kindof JSTestCollectionViewCell * _Nonnull reusableView) {
        NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.section];
        NSArray *array = [dic objectForKey:@"likeList"];
        [reusableView updateCellWithData:[array objectAtIndex:indexPath.row] atIndexPath:indexPath];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDictionary *dic = [self.dataSource objectAtIndex:section];
    NSArray *array = [dic objectForKey:@"likeList"];
    return array.count;
}

- (JSTestCollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        JSTestCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(JSTestCollectionReusableView.class) forIndexPath:indexPath];
        NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.section];
        [headerView updateViewWithData:dic atIndexPath:indexPath];
        return headerView;
    }
    return nil;
}

- (JSTestCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSTestCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(JSTestCollectionViewCell.class) forIndexPath:indexPath];
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.section];
    NSArray *array = [dic objectForKey:@"likeList"];
    [cell updateCellWithData:[array objectAtIndex:indexPath.row] atIndexPath:indexPath];
    return cell;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = nil;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [_collectionView registerClass:JSTestCollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(JSTestCollectionViewCell.class)];
        [_collectionView registerClass:JSTestCollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(JSTestCollectionReusableView.class)];
    }
    return _collectionView;
}

@end
