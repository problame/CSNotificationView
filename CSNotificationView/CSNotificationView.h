//
//  CSNotificationView.h
//  CSNotificationView
//
//  Created by Christian Schwarz on 01.09.13.
//  Copyright (c) 2013 Christian Schwarz. Check LICENSE.md.
//

#import <UIKit/UIKit.h>

static CGFloat const kCSNotificationViewHeight = 50.0f;
static CGFloat const kCSNotificationViewSymbolViewSidelength = 44.0f;
static NSTimeInterval const kCSNotificationViewDefaultShowDuration = 2.0;

typedef NS_ENUM(NSInteger, CSNotificationViewStyle) {
    CSNotificationViewStyleSuccess,
    CSNotificationViewStyleError
};

typedef void(^CSVoidBlock)();

@interface CSNotificationView : UIView

#pragma mark + quick presentation

+ (void)showInViewController:(UIViewController*)viewController
             style:(CSNotificationViewStyle)style
           message:(NSString*)message;

+ (void)showInViewController:(UIViewController*)viewController
         tintColor:(UIColor*)tintColor
             image:(UIImage*)image
           message:(NSString*)message
          duration:(NSTimeInterval)duration;

+ (void)showInViewController:(UIViewController*)viewController
                   tintColor:(UIColor*)tintColor
                        font:(UIFont*)font
               textAlignment:(NSTextAlignment)textAlignment
                       image:(UIImage*)image
                     message:(NSString*)message
                    duration:(NSTimeInterval)duration;

#pragma mark + creators

+ (CSNotificationView*)notificationViewWithParentViewController:(UIViewController*)viewController
                                                      tintColor:(UIColor*)tintColor
                                                          image:(UIImage*)image
                                                        message:(NSString*)message;

#pragma mark + icons

/**
 * @return The included images that are used for the `image` property when creating a notification with `style`.
 */
+ (UIImage*)imageForStyle:(CSNotificationViewStyle)style;

#pragma mark - initialization

/**
 * Why initialize with the view controller?
 * CSNotificationView stays visible if `viewController` is pushed off the UINavigationController stack.
 * Furthermore, presentation in a UITableViewController is not possible so CSNotificationView uses
 * the parent view controller's view for presentation.
 * @param viewController The view controller in which the notification shall be presented.
 */
- (instancetype)initWithParentViewController:(UIViewController*)viewController NS_DESIGNATED_INITIALIZER;

#pragma mark - presentation

/**
 * @param showing Should the notification view be visible?
 * @param animated Should a change in `showing` be animated?
 * @param completion `nil` or a callback called on the main thread after changes to the interface are completed.
 */
- (void)setVisible:(BOOL)showing animated:(BOOL)animated completion:(void (^)())completion;

/**
 * Convenience method to dismiss with a(nother) predefined style and / or message.
 */
- (void)dismissWithStyle:(CSNotificationViewStyle)style message:(NSString*)message duration:(NSTimeInterval)duration animated:(BOOL)animated;

@property (readonly, nonatomic, getter = isShowing) BOOL visible;

#pragma mark - visible properties

/**
 * The image displayed as an icon on the left side of `textLabel`.
 * Only the alpha value will be used and then be tinted to a 'legible' color.
 */
@property (nonatomic, strong) UIImage* image;

/**
 * The tint applied to the blurred background.
 * Note that `textLabel.textColor` is adjusted to make `textLabel` legible on the tinted background.
 */
@property (nonatomic, strong) UIColor* tintColor;

/**
 * The label containing the message displayed to the user.
 */
@property (nonatomic, readonly) UILabel* textLabel;

@property (nonatomic, getter = isShowingActivity) BOOL showingActivity;

/**
 * A callback called if the user taps on the notification.
 */
@property (nonatomic, copy) CSVoidBlock tapHandler;

@end
