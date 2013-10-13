//
//  CSNotificationView.m
//  CSNotificationView
//
//  Created by Christian Schwarz on 01.09.13.
//  Copyright (c) 2013 Christian Schwarz. Check LICENSE.md.
//

#import "CSNotificationView.h"

@interface CSNotificationView ()

#pragma mark - blur effect
@property (nonatomic) UIColor* blurTintColor;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) CALayer *blurLayer;

#pragma mark - presentation
@property (nonatomic, weak) UIViewController* parentViewController;

#pragma mark - content views
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UILabel* textLabel;

@end

@implementation CSNotificationView
@dynamic blurTintColor;

#pragma mark + public

+ (void)showInViewController:(UIViewController*)viewController
         tintColor:(UIColor*)tintColor
             image:(UIImage*)image
           message:(NSString*)message
          duration:(NSTimeInterval)duration
{
    NSAssert(message, @"'message' must not be nil.");
    
    __block CSNotificationView* note = [[CSNotificationView alloc] initWithParentViewController:viewController];
    note.blurTintColor = tintColor;
    note.image = image;
    note.textLabel.text = message;
    
    [viewController.view addSubview:note];
    
    __block typeof(viewController) weakViewController = viewController;
    [UIView animateWithDuration:0.4 animations:^{
        [note setFrame:[CSNotificationView displayFrameInParentViewController:weakViewController]];
    } completion:^(BOOL finished) {
        dispatch_time_t popTime =
                dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.4 animations:^{
                [note setFrame:[CSNotificationView offscreenFrameForInParentViewController:weakViewController]];
            } completion:^(BOOL finished) {
                [note removeFromSuperview];
            }];
        });
    }];
    
}

+ (void)showInViewController:(UIViewController *)viewController
             style:(CSNotificationViewStyle)style
           message:(NSString *)message
{
    UIColor* blurTintColor;
    UIImage* image;
    switch (style) {
        case CSNotificationViewStyleSuccess:
            blurTintColor = [UIColor colorWithRed:0.21 green:0.72 blue:0.00 alpha:1.0];
            image = [UIImage imageNamed:@"CSNotificationView_checkmarkIcon"];
            break;
        case CSNotificationViewStyleError:
            blurTintColor = [UIColor redColor];
            image = [UIImage imageNamed:@"CSNotificationView_exclamationMarkIcon"];
            break;
        default:
            NSAssert(NO, @"You used an invalid notification style.");
            break;
    }
    
    NSAssert(blurTintColor, @"'blurTintColor' is not defined");
    
    [CSNotificationView showInViewController:viewController
                         tintColor:blurTintColor
                             image:image
                           message:message
                          duration:kCSNotificationViewDefaultShowDuration];
}

#pragma mark - Progress:
+ (CSNotificationView *)showProgressInViewController:(UIViewController*)viewController
                                                tintColor:(UIColor*)tintColor
                                               image:(UIImage*)image
                                             message:(NSString*)message

{
    NSAssert(message, @"'message' must not be nil.");
    
    __block CSNotificationView* note = [[CSNotificationView alloc] initWithParentViewController:viewController];
    note.blurTintColor = tintColor;
    note.image = image;
    note.textLabel.text = message;
    
    [viewController.view addSubview:note];
    
    __block typeof(viewController) weakViewController = viewController;
    note.displayedFrame = [CSNotificationView displayFrameInParentViewController:weakViewController];
    note.hiddenFrame = [CSNotificationView offscreenFrameForInParentViewController:weakViewController];
    
    return note;
}

-(void)show{
    [UIView animateWithDuration:0.4 animations:^{
        [self setFrame:self.displayedFrame];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)dismiss{
    [UIView animateWithDuration:0.4 animations:^{
        [self setFrame:self.hiddenFrame];
    } completion:^(BOOL finished) {
        
    }];
}



#pragma mark + frame calculation

+ (CGRect)offscreenFrameForInParentViewController:(UIViewController*)viewController
{
    CGRect offscreenFrame = CGRectMake(0, -kCSNotificationViewHeight - viewController.topLayoutGuide.length,
                                       CGRectGetWidth(viewController.view.frame),
                                       kCSNotificationViewHeight + viewController.topLayoutGuide.length);
    
    if ([viewController.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView* scrollView = (UIScrollView*)viewController.view;
        offscreenFrame.origin.y -= scrollView.contentInset.top - scrollView.contentOffset.y;
    }
    return offscreenFrame;
}

+ (CGRect)displayFrameInParentViewController:(UIViewController*)viewController
{
    CGRect displayFrame = CGRectMake(0, 0, CGRectGetWidth(viewController.view.frame),
                                    kCSNotificationViewHeight + viewController.topLayoutGuide.length);
    
    if ([viewController.view isKindOfClass:[UIScrollView class]]) {
        //Add offset
        UIScrollView* scrollView = (UIScrollView*)viewController.view;
        displayFrame.origin.y += scrollView.contentOffset.y;
    }
    return displayFrame;
}

#pragma mark - lifecycle

- (instancetype)initWithParentViewController:(UIViewController*)viewController
{
    self = [super initWithFrame:[CSNotificationView offscreenFrameForInParentViewController:viewController]];
    if (self) {
        
        //Blur | thanks to https://github.com/JagCesar/iOS-blur for providing this under the WTFPL-license!
        {
            [self setToolbar:[[UIToolbar alloc] initWithFrame:[self bounds]]];
            [self setBlurLayer:[[self toolbar] layer]];
            
            UIView *blurView = [UIView new];
            [blurView setUserInteractionEnabled:NO];
            [blurView.layer addSublayer:[self blurLayer]];
            [blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [self insertSubview:blurView atIndex:0];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(blurView)]];
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-1)-[blurView]-(-1)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(blurView)]];
            
            [self setBackgroundColor:[UIColor clearColor]];
        }
        
        //Parent view
        {
            self.parentViewController = viewController;
            if ([self.parentViewController.view isKindOfClass:[UIScrollView class]]) {
                [self.parentViewController.view addObserver:self
                                  forKeyPath:@"contentOffset"
                                     options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                                     context:NULL];
            }
        }
        
        //Content views
        {
            //textLabel
            {
                _textLabel = [[UILabel alloc] init];
                
                UIFontDescriptor* textLabelFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
                _textLabel.font = [UIFont fontWithDescriptor:textLabelFontDescriptor size:17.0f];
                _textLabel.minimumScaleFactor = 0.6;
                _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                _textLabel.adjustsFontSizeToFitWidth = YES;
                
                _textLabel.numberOfLines = 2;
                _textLabel.textColor = [UIColor whiteColor];
                _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:_textLabel];
            }
            //imageView
            {
                _imageView = [[UIImageView alloc] init];
                _imageView.opaque = NO;
                _imageView.backgroundColor = [UIColor clearColor];
                _imageView.translatesAutoresizingMaskIntoConstraints = NO;
                _imageView.contentMode = UIViewContentModeCenter;
                [self addSubview:_imageView];
            }
        }
        
    }
    return self;
}

- (void)dealloc
{
    if ([self.parentViewController.view isKindOfClass:[UIScrollView class]]) {
        [self.parentViewController.view removeObserver:self forKeyPath:@"contentOffset"];
    }
}

#pragma mark - layout

- (void)updateConstraints
{
    [self removeConstraints:self.constraints];
    
    CGFloat imageViewWidth = self.imageView.image ?
                                kCSNotificationViewImageViewSidelength : 0.0f;
    CGFloat imageViewHeight = kCSNotificationViewImageViewSidelength;
    
    NSDictionary* metrics =
        @{@"imageViewWidth": [NSNumber numberWithFloat:imageViewWidth],
          @"imageViewHeight":[NSNumber numberWithFloat:imageViewHeight]};
    
    [self addConstraints:[NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-(4)-[_imageView(imageViewWidth)]-(5)-[_textLabel]-(10)-|"
                            options:0
                            metrics:metrics
                              views:NSDictionaryOfVariableBindings(_textLabel, _imageView)]];
    
    [self addConstraints:[NSLayoutConstraint
        constraintsWithVisualFormat:@"V:[_imageView(imageViewHeight)]"
                            options:0
                            metrics:metrics
                                views:NSDictionaryOfVariableBindings(_imageView)]];
    
    CGFloat topInset = CGRectGetHeight(self.frame) - 4;
    
    [self addConstraint:[NSLayoutConstraint
                constraintWithItem:_imageView
                         attribute:NSLayoutAttributeBottom
                         relatedBy:NSLayoutRelationEqual
                            toItem:self
                         attribute:NSLayoutAttributeBottom
                         multiplier:0.0f constant:topInset]];
    
    [self addConstraint:[NSLayoutConstraint
        constraintWithItem:_textLabel
                 attribute:NSLayoutAttributeCenterY
                 relatedBy:NSLayoutRelationEqual
                    toItem:_imageView
                 attribute:NSLayoutAttributeCenterY
                multiplier:1.0f constant:0]];
    
    [super updateConstraints];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.blurLayer.frame = self.bounds;
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isEqual:self.parentViewController.view]) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            self.frame = [CSNotificationView
                          displayFrameInParentViewController:self.parentViewController];
        }
    }
}

#pragma mark - blur

- (void)setBlurTintColor:(UIColor *)blurTintColor
{
    [self.toolbar setBarTintColor:blurTintColor];
    [self updateForegroundColorsForBlurTintColor:blurTintColor];
}

- (UIColor *)blurTintColor
{
    return self.toolbar.barTintColor;
}

#pragma mark - image

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self updateForegroundColorsForBlurTintColor:self.blurTintColor];
}

#pragma mark - dynamic foreground color

- (void)updateForegroundColorsForBlurTintColor:(UIColor*)blurTintColor
{
    NSParameterAssert(blurTintColor);
    UIColor* legibleColor = [self legibleTextColorForBlurTintColor:blurTintColor];
    self.textLabel.textColor = legibleColor;
    self.imageView.image = [self imageFromAlphaChannelOfImage:self.image replacementColor:legibleColor];
}

#pragma mark -- helpers

- (UIColor*)legibleTextColorForBlurTintColor:(UIColor*)blurTintColor
{
    CGFloat r, g, b, a;
    BOOL couldConvert = [blurTintColor getRed:&r green:&g blue:&b alpha:&a];
    
    UIColor* textColor = [UIColor whiteColor];
    
    CGFloat average = (r+g+b)/3.0; //Not considering alpha here, transperency is added by toolbar
    if (couldConvert && average > 0.65) //0.65 is mostly gut-feeling
    {
        textColor = [[UIColor alloc] initWithWhite:0.2 alpha:1.0];
    }
    
    return textColor;
}

- (UIImage*)imageFromAlphaChannelOfImage:(UIImage*)image replacementColor:(UIColor*)tintColor
{
    if (!image) return nil;
    NSParameterAssert([tintColor isKindOfClass:[UIColor class]]);
 
    //Credits: https://gist.github.com/omz/1102091
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [tintColor CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
