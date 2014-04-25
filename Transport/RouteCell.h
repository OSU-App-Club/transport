//
//  RouteCell.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteCell : UICollectionViewCell <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSArray *stops;
@property (weak, nonatomic) IBOutlet UITableView *stopsTableView;

@end
