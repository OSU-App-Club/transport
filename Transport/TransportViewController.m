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
    
    self.routeColorDict = @{
                            @"1":[UIColor colorWithRed:0.0/255.0 green:173.0/255.0 blue:238.0/255.0 alpha:1.0],
                            @"2":[UIColor colorWithRed:136.0/255.0 green:39.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"3":[UIColor colorWithRed:136.0/255.0 green:101.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"4":[UIColor colorWithRed:140.0/255.0 green:197.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"5":[UIColor colorWithRed:189.0/255.0 green:85.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"6":[UIColor colorWithRed:3.0/255.0 green:77.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"7":[UIColor colorWithRed:215.0/255.0 green:24.0/255.0 blue:144.0/255.0 alpha:1.0],
                            @"8":[UIColor colorWithRed:0.0/255.0 green:133.0/255.0 blue:64.0/255.0 alpha:1.0],
                            @"BBN":[UIColor colorWithRed:76.0/255.0 green:229.0/255.0 blue:0.0/255.0 alpha:1.0],
                            @"BBSE":[UIColor colorWithRed:255.0/255.0 green:170.0/255.0 blue:0.0/255.0 alpha:1.0],
                            @"BBSW":[UIColor colorWithRed:0.0/255.0 green:91.0/255.0 blue:229.0/255.0 alpha:1.0],
                            @"C1":[UIColor colorWithRed:97.0/255.0 green:70.0/255.0 blue:48.0/255.0 alpha:1.0],
                            @"C2":[UIColor colorWithRed:0.0/255.0 green:118.0/255.0 blue:163.0/255.0 alpha:1.0],
                            @"C3":[UIColor colorWithRed:236.0/255.0 green:12.0/255.0 blue:108.0/255.0 alpha:1.0],
                            @"CVA":[UIColor colorWithRed:63.0/255.0 green:40.0/255.0 blue:133.0/255.0 alpha:1.0],
                            };
    
    self.selectedIndex = NSUIntegerMax;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.collectionView.alwaysBounceVertical = YES;

}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //Customize layout for paging
    //MUST DO IT HERE: not setup yet in viewDidLoad
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = .8;
}

- (void) startRefresh:(UIRefreshControl*) control{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    BOOL expand = currentHeight == kCollapsedHeight;
    collectionView.scrollEnabled = !expand;
    
    [collectionView performBatchUpdates:^{
        self.selectedIndex = expand ? indexPath.item : NSUIntegerMax;
    } completion:^(BOOL finished) {
        if (expand) {
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
        }
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
