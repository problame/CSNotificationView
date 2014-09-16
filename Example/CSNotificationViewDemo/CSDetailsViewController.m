//
//  CSDetailsViewController.m
//  CSNotificationViewDemo
//
//  Created by Christian Schwarz on 24.02.14.
//  Copyright (c) 2014 Christian Schwarz. Check LICENSE.md.
//

#import "CSDetailsViewController.h"
#import <CSNotificationView/CSNotificationView.h>

@interface CSDetailsViewController ()

@end

@implementation CSDetailsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)didPushBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPushPresentNotificationView:(id)sender
{
    [CSNotificationView showInViewController:self
                                   tintColor:[UIColor colorWithRed:0.000 green:0.6 blue:1.000 alpha:1]
                                       image:nil
                                     message:@"Some message that should resize when showing the navbar again." duration:10.0f];
}

@end
