//
//  CSNotificationViewPresentationTests.m
//  CSNotificationViewDemo
//
//  Created by Christian Schwarz on 15.10.14.
//  Copyright (c) 2014 Christian Schwarz. Check LICENSE.md.
//

#import <XCTest/XCTest.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <CSNotificationView/CSNotificationView.h>
#import <CSNotificationView/CSNotificationView_Private.h>
#import <XCTAsyncTestCase/XCTAsyncTestCase.h>
#import <OCMock/OCMock.h>

#import "CSAppDelegate.h"
#import "CSDetailsViewController.h"

typedef void(^VoidBlock)();


@interface CSNotificationViewPresentationTests : XCTAsyncTestCase

- (CSDetailsViewController *)detailsViewController;

@end

@implementation CSNotificationViewPresentationTests

- (CSDetailsViewController *)detailsViewController
{
    CSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return delegate.detailsViewController;
}
    

- (void)testDismissalDuringDismissalOfParentModalNavigationViewControllerRemovedNavigationBarObserver
{
    
    UIViewController *modalRootVC = [[UIViewController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:modalRootVC];

    CSNotificationView *note = [[CSNotificationView alloc] initWithParentViewController:modalRootVC];
    id mockNote = OCMPartialMock(note);
    [[mockNote expect] removeNavigationBarObserver];
    
    @weakify(modalRootVC, mockNote);
    [self.detailsViewController presentViewController:navVC animated:NO completion:^{
        @strongify(mockNote);
        
        [mockNote setVisible:YES animated:NO completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(modalRootVC, mockNote);
                
                //Animated hide gives us time to call for dimissal of the modal view controller
                [mockNote setVisible:NO animated:YES completion:nil];
                
                //Immediate dismissal should cause navigation bar to be deallocated
                [modalRootVC dismissViewControllerAnimated:NO completion:nil];
                
            });
        }];
        
    }];
    
    [mockNote verify];
    
}

@end
