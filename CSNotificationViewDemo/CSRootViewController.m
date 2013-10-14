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

- (IBAction)showError:(id)sender {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleError
                                     message:@"A critical error happened."];
}
- (IBAction)showSuccess:(id)sender {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleSuccess
                                     message:@"Great, it works."];
}

- (IBAction)showCustom:(id)sender {
    [CSNotificationView showInViewController:self
            tintColor:[UIColor colorWithRed:0.000 green:0.6 blue:1.000 alpha:1]
                image:nil
              message:@"No icon and a message that needs two rows and extra \
                        presentation time to be displayed properly."
             duration:5.8f];
    
}

- (IBAction)showPermanent:(id)sender
{
    if (self.permanentNotification) {
        return;
    }
    
    CSNotificationView *progressCard = [CSNotificationView notificationViewWithParentViewController:self
                                                                                          tintColor:[UIColor blueColor]
                                                                                              image:nil message:@"I'm here until dismissal."];
    
    
    self.permanentNotification = progressCard;
    
    //show a button on the navigation bar to hide the permanent view on demand
    __block typeof(self) weakself = self;
    [progressCard setVisible:YES animated:YES completion:^{
        weakself.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleDone target:self action:@selector(dismissPermanentNotification)];
    }];
}

-(void)dismissPermanentNotification {
    __block typeof(self) weakself = self;
    [self.permanentNotification setVisible:NO animated:YES completion:^{
        weakself.navigationItem.rightBarButtonItem = nil;
        weakself.permanentNotification = nil;
    }];
}



@end
