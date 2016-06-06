//
//  TransportViewController.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/24/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+Utils.h"

@interface TransportViewController : UICollectionViewController

@property NSUInteger selectedIndex;

- (void) updateCell:(UICollectionViewCell *) cell ToState:(BOOL) isExpanded;


@end
