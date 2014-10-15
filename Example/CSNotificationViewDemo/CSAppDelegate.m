//
//  CSAppDelegate.m
//  CSNotificationViewDemo
//
//  Created by Christian Schwarz on 01.09.13.
//  Copyright (c) 2013 Christian Schwarz. Check LICENSE.md.
//

#import "CSAppDelegate.h"

@implementation CSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.detailsViewController = (CSDetailsViewController *)self.window.rootViewController;
    return YES;
}

@end
