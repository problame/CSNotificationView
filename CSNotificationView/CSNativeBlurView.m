//
//  CSNativeBlurView.m
//  CSNotificationViewDemo
//
//  Created by Christian Schwarz on 23.08.14.
//  Copyright (c) 2014 Christian Schwarz. Check LICENSE.md.
//

#import "CSNativeBlurView.h"

@interface CSNativeBlurView ()

/**
 A view that is used for 'injecting' the tint color
 The results look nicer than setting self.backgroundColor directly.
 */
@property (nonatomic, strong) UIView* tintColorView;

@end

@implementation CSNativeBlurView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    if (self) {
        self.tintColorView = [[UIView alloc] initWithFrame:self.bounds];
        self.tintColorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.tintColorView];
    }
    return self;
}

- (void)setBlurTintColor:(UIColor *)tintColor
{
    self.tintColorView.backgroundColor = [tintColor colorWithAlphaComponent:0.6];
}

@end
