//
//  StopsViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "StopsViewController.h"

#define kCellReuseID        @"stopCell"
#define kCollapsedHeight  80
#define kExpanedHeight self.view.bounds.size.height

@interface StopsViewController ()

@property (nonatomic, strong) NSArray *arrivals;
@property NSUInteger selectedIndex;

@end

@implementation StopsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:10];
    
    for (int cell_idx = 0; cell_idx < 10; cell_idx++) {
        [temp addObject:@{@"Name":@"Test Name"}];
    }
    self.arrivals = temp;
    self.selectedIndex = NSUIntegerMax;
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrivals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellReuseID forIndexPath:indexPath];
    cell.contentView.backgroundColor = indexPath.item % 2 ? [UIColor grayColor] : [UIColor orangeColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, (indexPath.item==self.selectedIndex)?kExpanedHeight:kCollapsedHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger currentHeight = [collectionView cellForItemAtIndexPath:indexPath].bounds.size.height;
    BOOL expand = currentHeight == kCollapsedHeight;
    collectionView.scrollEnabled = !expand;
    [collectionView performBatchUpdates:^{
        self.selectedIndex = expand ? indexPath.item : NSUIntegerMax;
    } completion:^(BOOL finished) {
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
