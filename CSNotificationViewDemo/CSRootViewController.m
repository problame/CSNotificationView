//
//  CSRootViewController.m
//  CSNotificationViewDemo
//
//  Created by Christian Schwarz on 01.09.13.
//  Copyright (c) 2013 Christian Schwarz. Check LICENSE.md.
//

#import "CSRootViewController.h"
#import "CSNotificationView.h"

@interface CSRootViewController ()

@property (nonatomic, strong) CSNotificationView* permanentNotification;

@end

@implementation CSRootViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)showError:(id)sender {
    [CSNotificationView showInViewController:self.navigationController
                                       style:CSNotificationViewStyleError
                                     message:@"A critical error happened."];
}
- (IBAction)showSuccess:(id)sender {
    [CSNotificationView showInViewController:self.navigationController
                                       style:CSNotificationViewStyleSuccess
                                     message:@"Great, it works."];
}

- (IBAction)showCustom:(id)sender {
    [CSNotificationView showInViewController:self.navigationController
            tintColor:[UIColor colorWithRed:0.000 green:0.6 blue:1.000 alpha:1]
                image:nil
              message:@"No icon and a message that needs two rows and extra "
                      @"presentation time to be displayed properly."
             duration:5.8f];
    
}

- (IBAction)showPermanent:(id)sender
{
    if (self.permanentNotification) {
        return;
    }
    
    self.permanentNotification =
        [CSNotificationView notificationViewWithParentViewController:self.navigationController
            tintColor:[UIColor colorWithRed:0.000 green:0.6 blue:1.000 alpha:1]
                image:nil message:@"I am running for two seconds."];
    
    [self.permanentNotification setShowingActivity:YES];
    
    __block typeof(self) weakself = self;
    self.permanentNotification.tapHandler = ^{
        [weakself cancel];
    };
    
    [self.permanentNotification setVisible:YES animated:YES completion:^{

        weakself.navigationItem.rightBarButtonItem =
                [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                 style:UIBarButtonItemStyleDone
                                                target:weakself
                                                action:@selector(cancel)];
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakself success];
        });
        
    }];
}

- (void)cancel
{
    self.navigationItem.rightBarButtonItem = nil;
    [self.permanentNotification dismissWithStyle:CSNotificationViewStyleError
                                         message:@"Cancelled"
                                        duration:kCSNotificationViewDefaultShowDuration animated:YES];
    self.permanentNotification = nil;
    
}

- (void)success
{
    self.navigationItem.rightBarButtonItem = nil;
    [self.permanentNotification dismissWithStyle:CSNotificationViewStyleSuccess
                                             message:@"Sucess!"
                                            duration:kCSNotificationViewDefaultShowDuration animated:YES];
    self.permanentNotification = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"push" sender:nil];
}

@end
