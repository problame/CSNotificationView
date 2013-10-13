//
//  CSRootViewController.m
//  CSNotificationViewDemo
//
//  Created by Christian Schwarz on 01.09.13.
//  Copyright (c) 2013 Christian Schwarz. Check LICENSE.md.
//

#import "CSRootViewController.h"
#import "CSNotificationView.h"

@interface CSRootViewController (){
    CSNotificationView *currentCard;
}

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
    CSNotificationView *progressCard = [CSNotificationView showProgressInViewController:self tintColor:[UIColor blueColor] image:nil message:@"Loading Data..."];
    
    [progressCard show];
    
    //Temporary Variable to keep track of the progress card
    currentCard = progressCard;
    
    //show a button on the navigation bar to hide the progressBar on demand
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleDone target:self action:@selector(dismissProgressCard)];
}

-(void)dismissProgressCard{
    [currentCard dismiss];
    self.navigationItem.rightBarButtonItem = nil;
}



@end
