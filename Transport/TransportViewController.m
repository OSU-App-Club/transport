//
//  TransportViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/24/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "TransportViewController.h"

#define kCollapsedHeight  80
#define kExpanedHeight self.view.bounds.size.height - (self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height)

@interface TransportViewController ()

@end

@implementation TransportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.selectedIndex = NSUIntegerMax;
    self.collectionView.alwaysBounceVertical = YES;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Customize layout for paging
    //MUST DO IT HERE: not setup yet in viewDidLoad
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = .8;
}

#pragma mark - UICollectionView Delegate & Datasource
- (void) updateCell: (UICollectionViewCell *) cell ToState:(BOOL) isExpanded{
    // Do nothing by default
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = (indexPath.item==self.selectedIndex)?kExpanedHeight:kCollapsedHeight;
    if (indexPath.item == 1 && indexPath.item == self.selectedIndex) {
        height -= kCollapsedHeight; // Account for second row issue
    }
    
    return CGSizeMake(collectionView.bounds.size.width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger currentHeight = [collectionView cellForItemAtIndexPath:indexPath].bounds.size.height;
    BOOL expand = (currentHeight == kCollapsedHeight);
    collectionView.scrollEnabled = !expand;
    
    [self updateCell:[collectionView cellForItemAtIndexPath:indexPath]ToState:expand];
    
    [collectionView performBatchUpdates:^{
        self.selectedIndex = expand ? indexPath.item : NSUIntegerMax;
    } completion:^(BOOL finished) {
        if (expand) {
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

@end
