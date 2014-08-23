//
//  CSLayerStealingBlurView.m
//  CSNotificationViewDemo
//
//  Created by Christian Schwarz on 23.08.14.
//  Copyright (c) 2014 Christian Schwarz. Check LICENSE.md.
//

#import "CSLayerStealingBlurView.h"

@interface CSLayerStealingBlurView ()

#pragma mark - blur effect
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) CALayer *blurLayer;

@end

@implementation CSLayerStealingBlurView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //Thanks to https://github.com/JagCesar/iOS-blur for providing this under the WTFPL-license!
        
        self.toolbar = [[UIToolbar alloc] initWithFrame:[self toolbarFrame]];
        self.blurLayer = self.toolbar.layer;
        
        self.userInteractionEnabled = NO;
        [self.layer addSublayer:self.blurLayer];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
 
    //Update blur layer frame by updating the bounds frame
    self.toolbar.frame = [self toolbarFrame];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.toolbar.frame = [self toolbarFrame];    
}

- (CGRect)toolbarFrame
{
    return CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (void)setBlurTintColor:(UIColor *)tintColor
{
    NSParameterAssert(tintColor);
    self.toolbar.barTintColor = [tintColor colorWithAlphaComponent:0.6];
}


@end
