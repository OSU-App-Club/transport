//
//  InfoViewController.m
//  Transport
//
//  Created by Chris Vanderschuere on 4/19/14.
//  Copyright (c) 2014 OSU App Club. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)openFeedback:(id)sender {
    MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
    [mailView setToRecipients:[NSArray arrayWithObject:@"osuappclub@gmail.com"]];
    mailView.mailComposeDelegate = self;
    
    //Contact Developer
    [mailView setSubject:[NSString stringWithFormat:@"Transport %@ %@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[UIDevice currentDevice].model ,[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]]];
    
    [self presentViewController:mailView animated:YES completion:NULL];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeInfoScreen:(id)sender{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openProjectWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://osu-app-club.github.io/transport"]];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
