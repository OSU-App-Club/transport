//
//  InfoViewController.h
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate>

- (IBAction) closeInfoScreen:(id)sender;

@end
