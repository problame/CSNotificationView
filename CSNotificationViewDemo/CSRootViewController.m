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



@end
