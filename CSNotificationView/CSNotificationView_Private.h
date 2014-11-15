//
//  CSNotificationView_Private.h
//  CSNotificationViewDemo
//
//  Created by Christian Schwarz on 23.08.14.
//  Copyright (c) 2014 Christian Schwarz. Check LICENSE.md.
//

#import "CSNotificationView.h"

static NSInteger const kCSNotificationViewEmptySymbolViewTag = 666;

static NSString* const kCSNotificationViewUINavigationControllerWillShowViewControllerNotification = @"UINavigationControllerWillShowViewControllerNotification";
static NSString* const kCSNotificationViewUINavigationControllerDidShowViewControllerNotification = @"UINavigationControllerDidShowViewControllerNotification";

static void * kCSNavigationBarObservationContext = &kCSNavigationBarObservationContext;
static NSString * kCSNavigationBarBoundsKeyPath = @"parentNavigationController.navigationBar.bounds";

@protocol CSNotificationViewBlurViewProtocol <NSObject>

///The tint of the blur view
- (void)setBlurTintColor:(UIColor*)tintColor;

@end

@interface CSNotificationView ()

#pragma mark - blur view
@property (nonatomic) UIView<CSNotificationViewBlurViewProtocol>* blurView;

#pragma mark - presentation
@property (nonatomic, weak) UIViewController* parentViewController;
@property (nonatomic, strong) UINavigationController* parentNavigationController; //Has to be strong-referenced because CSNotificationView does KVO on parentNavigationController
@property (nonatomic, getter = isVisible) BOOL visible;

#pragma mark - content views
@property (nonatomic, strong, readonly) UIView* symbolView; // is updated by -(void)updateSymbolView
@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, strong) UIColor* contentColor;

#pragma mark - interaction
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;

@end
