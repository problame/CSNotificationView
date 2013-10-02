//
//  CSNotificationView.h
//  CSNotificationView
//
//  Created by Christian Schwarz on 01.09.13.
//  Copyright (c) 2013 Christian Schwarz. Check LICENSE.md.
//

#import <UIKit/UIKit.h>

static CGFloat const kCSNotificationViewHeight = 50.0f;
static CGFloat const kCSNotificationViewImageViewSidelength = 44.0f;
static NSTimeInterval const kCSNotificationViewDefaultShowDuration = 2.0;

typedef enum {
    CSNotificationViewStyleSuccess,
    CSNotificationViewStyleError,
} CSNotificationViewStyle;

@interface CSNotificationView : UIView

+ (void)showInViewController:(UIViewController*)viewController
             style:(CSNotificationViewStyle)style
           message:(NSString*)message;

+ (void)showInViewController:(UIViewController*)viewController
         tintColor:(UIColor*)tintColor
             image:(UIImage*)image
           message:(NSString*)message
          duration:(NSTimeInterval)duration;

/**
 The image property should be used for setting the image displayed in imageView
 Only the alpha value will be used and then be tinted to a 'legible' color
 */
@property (nonatomic, strong) UIImage* image;

@end
