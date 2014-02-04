//
//  CSNotificationView.m
//  CSNotificationView
//
//  Created by Christian Schwarz on 01.09.13.
//  Copyright (c) 2013 Christian Schwarz. Check LICENSE.md.
//

#import "CSNotificationView.h"

static NSInteger const kCSNotificationViewEmptySymbolViewTag = 666;

@interface CSNotificationView (){
    UIView *_messageView;
    UIDynamicAnimator *_animator;
}

#pragma mark - blur effect
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) CALayer *blurLayer;

#pragma mark - presentation
@property (nonatomic, weak) UIViewController* parentViewController;
@property (nonatomic, weak) UINavigationController* parentNavigationController;
@property (nonatomic, getter = isVisible) BOOL visible;

#pragma mark - content views
@property (nonatomic, strong, readonly) UIView* symbolView; // is updated by -(void)updateSymbolView
@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, strong) UIColor* contentColor;

@end

@implementation CSNotificationView

#pragma mark + quick presentation

+ (void)showInViewController:(UIViewController*)viewController
         tintColor:(UIColor*)tintColor
             image:(UIImage*)image
           message:(NSString*)message
          duration:(NSTimeInterval)duration
{
    NSAssert(message, @"'message' must not be nil.");
    
    __block CSNotificationView* note = [[CSNotificationView alloc] initWithParentViewController:viewController];
    note.tintColor = tintColor;
    note.image = image;
    note.textLabel.text = message;
    
    void (^completion)() = ^{[note setVisible:NO animated:YES completion:nil];};
    [note setVisible:YES animated:YES completion:^{
        double delayInSeconds = duration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            completion();
        });
    }];
    
}

+ (void)showInViewController:(UIViewController *)viewController
             style:(CSNotificationViewStyle)style
           message:(NSString *)message
{
    
    
    [CSNotificationView showInViewController:viewController
                         tintColor:[CSNotificationView blurTintColorForStyle:style]
                             image:[CSNotificationView imageForStyle:style]
                           message:message
                          duration:kCSNotificationViewDefaultShowDuration];
}

#pragma mark + creators

+ (CSNotificationView*)notificationViewWithParentViewController:(UIViewController*)viewController
                                                      tintColor:(UIColor*)tintColor
                                                          image:(UIImage*)image
                                                        message:(NSString*)message
{
    NSParameterAssert(viewController);
    
    CSNotificationView* note = [[CSNotificationView alloc] initWithParentViewController:viewController];
    note.tintColor = tintColor;
    note.image = image;
    note.textLabel.text = message;
    
    return note;
}

#pragma mark - lifecycle

- (instancetype)initWithParentViewController:(UIViewController*)viewController
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        _messageView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_messageView];
        
        //Blur | thanks to https://github.com/JagCesar/iOS-blur for providing this under the WTFPL-license!
        {
            [self setToolbar:[[UIToolbar alloc] initWithFrame:[_messageView bounds]]];
            [self setBlurLayer:[[self toolbar] layer]];
            
            UIView *blurView = [UIView new];
            [blurView setUserInteractionEnabled:NO];
            [blurView.layer addSublayer:[self blurLayer]];
            [blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [_messageView insertSubview:blurView atIndex:0];
            
            [_messageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(blurView)]];
            [_messageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-1)-[blurView]-(-1)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(blurView)]];
            
            [self setBackgroundColor:[UIColor clearColor]];
            [_messageView setBackgroundColor:[UIColor clearColor]];
        }
        
        //Parent view
        {
            self.parentViewController = viewController;
            
            NSAssert(!([self.parentViewController isKindOfClass:[UITableViewController class]] && !self.parentViewController.navigationController), @"Due to a bug in iOS 7.0.1|2|3 UITableViewController, CSNotificationView cannot present in UITableViewController without a parent UINavigationController");
            
            if (self.parentViewController.navigationController) {
                self.parentNavigationController = self.parentViewController.navigationController;
            }
            if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
                self.parentNavigationController = (UINavigationController*)self.parentViewController;
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
                [_messageView addSubview:_textLabel];
            }
            //symbolView
            {
                [self updateSymbolView];
            }
        }
        
        self.autoresizingMask = UIViewAutoresizingNone;
        _messageView.autoresizingMask = UIViewAutoresizingNone;
    }
    return self;
}

#pragma mark - layout

- (void)updateConstraints
{
    [_messageView removeConstraints:_messageView.constraints];
    
    CGFloat symbolViewWidth = self.symbolView.tag != kCSNotificationViewEmptySymbolViewTag ?
                                kCSNotificationViewSymbolViewSidelength : 0.0f;
    CGFloat symbolViewHeight = kCSNotificationViewSymbolViewSidelength;
    
    NSDictionary* metrics =
        @{@"symbolViewWidth": [NSNumber numberWithFloat:symbolViewWidth],
          @"symbolViewHeight":[NSNumber numberWithFloat:symbolViewHeight]};
    
    [_messageView addConstraints:[NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-(4)-[_symbolView(symbolViewWidth)]-(5)-[_textLabel]-(10)-|"
                            options:0
                            metrics:metrics
                              views:NSDictionaryOfVariableBindings(_textLabel, _symbolView)]];
    
    [_messageView addConstraints:[NSLayoutConstraint
        constraintsWithVisualFormat:@"V:[_symbolView(symbolViewHeight)]"
                            options:0
                            metrics:metrics
                                views:NSDictionaryOfVariableBindings(_symbolView)]];
    
    CGFloat topInset = CGRectGetHeight(_messageView.frame) - 4;
    
    [_messageView addConstraint:[NSLayoutConstraint
                constraintWithItem:_symbolView
                         attribute:NSLayoutAttributeBottom
                         relatedBy:NSLayoutRelationEqual
                            toItem:_messageView
                         attribute:NSLayoutAttributeBottom
                         multiplier:0.0f constant:topInset]];
    
    [_messageView addConstraint:[NSLayoutConstraint
        constraintWithItem:_textLabel
                 attribute:NSLayoutAttributeCenterY
                 relatedBy:NSLayoutRelationEqual
                    toItem:_symbolView
                 attribute:NSLayoutAttributeCenterY
                multiplier:1.0f constant:0]];
    
    [super updateConstraints];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _messageView.frame = [self hiddenFrame];
    self.blurLayer.frame = _messageView.bounds;
}

#pragma mark - tint color

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    //Use 0.6 alpha value for translucency blur in UIToolbar
    [self.toolbar setBarTintColor:[tintColor colorWithAlphaComponent:0.6]];
    self.contentColor = [self legibleTextColorForBlurTintColor:tintColor];
}

#pragma mark - presentation

- (void)setVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)())completion
{
    if (_visible != visible) {
        
        self.frame = [self bigFrame];
        
        if (self.parentNavigationController) {
            [self.parentNavigationController.view insertSubview:self belowSubview:self.parentNavigationController.navigationBar];
        } else {
            [self.parentViewController.view addSubview:self];
        }
        
        if (visible) {
            _messageView.frame = [self hiddenFrame];
            
            UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
            
            UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[_messageView]];
            
            UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_messageView]];
            collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
            
            UIDynamicItemBehavior *dynamicItem = [[UIDynamicItemBehavior alloc] initWithItems:@[_messageView]];
            dynamicItem.elasticity = 0.4;
            dynamicItem.allowsRotation = NO;
            
            [animator addBehavior:dynamicItem];
            [animator addBehavior:collisionBehavior];
            [animator addBehavior:gravityBehavior];
            
            _animator = animator;
            
            if (completion) {
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    completion();
                });
            }
        }else{
            CGRect frame = [self hiddenFrame];
            frame.origin.y = self.bounds.size.height - frame.size.height;
            _messageView.frame = frame;
            [UIView animateWithDuration:0.4 animations:^{
                _messageView.frame = [self hiddenFrame];
            }completion:^(BOOL finished) {
                [self removeFromSuperview];
                if (completion) {
                    completion();
                }
            }];
        }
    
        _visible = visible;
    } else if (completion) {
        completion();
    }
}

- (void)dismissWithStyle:(CSNotificationViewStyle)style message:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated
{
    NSParameterAssert(message);

    __block typeof(self) weakself = self;
    [UIView animateWithDuration:0.1 animations:^{

        weakself.showingActivity = NO;
        weakself.image = [CSNotificationView imageForStyle:style];
        weakself.textLabel.text = message;
        weakself.tintColor = [CSNotificationView blurTintColorForStyle:style];
        
    } completion:^(BOOL finished) {
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakself setVisible:NO animated:animated completion:nil];
        });
    }];
}

#pragma mark - frame calculation

//Workaround as there is a bug: sometimes, when accessing topLayoutGuide, it will render contentSize of UITableViewControllers to be {0, 0}
- (CGFloat)topLayoutGuideLengthCalculation
{
    CGFloat top = 0;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        top = CGRectGetWidth([[UIApplication sharedApplication] statusBarFrame]);
    }else{
        top = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    }
    
    if (self.parentNavigationController) {
        
        top += CGRectIntersection(self.parentNavigationController.view.bounds, self.parentNavigationController.navigationBar.frame).size.height;
    }
    
    return top;
}

- (CGFloat)widthLayoutGuideLengthCalculation
{
    CGFloat width = 0;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        width = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    }else{
        width = CGRectGetWidth([[UIApplication sharedApplication] statusBarFrame]);
    }
    
    return width;
}

- (CGRect)bigFrame
{
    CGFloat topLayoutGuideLength = [self topLayoutGuideLengthCalculation];
    
    CGFloat totalWidth = [self widthLayoutGuideLengthCalculation];

    CGRect displayFrame = CGRectMake(0, -(topLayoutGuideLength + kCSNotificationViewHeight),
                                     totalWidth, 2*(kCSNotificationViewHeight + topLayoutGuideLength));
    
    return displayFrame;
}

- (CGRect)hiddenFrame
{
    CGRect offscreenFrame = self.bounds;
    offscreenFrame.size.height /= 2;
    return offscreenFrame;
}

- (CGSize)intrinsicContentSize
{
    UIViewController* viewController = self.parentNavigationController ?: self.parentViewController;
    return CGSizeMake(CGRectGetWidth(viewController.view.frame),
                      kCSNotificationViewHeight);
}

#pragma mark - symbol view

- (void)updateSymbolView
{
    [self.symbolView removeFromSuperview];
    
    if (self.isShowingActivity) {
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.color = self.contentColor;
        [indicator startAnimating];
        _symbolView = indicator;
    } else if (self.image) {
        //Generate UIImageView for symbolView
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.opaque = NO;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = [self imageFromAlphaChannelOfImage:self.image replacementColor:self.contentColor];
        _symbolView = imageView;
    } else {
        _symbolView = [[UIView alloc] initWithFrame:CGRectZero];
        _symbolView.tag = kCSNotificationViewEmptySymbolViewTag;
    }
    _symbolView.translatesAutoresizingMaskIntoConstraints = NO;
    [_messageView addSubview:_symbolView];
    [self setNeedsUpdateConstraints];

}

#pragma mark -- image

- (void)setImage:(UIImage *)image
{
    if (![_image isEqual:image]) {
        _image = image;
        [self updateSymbolView];
    }
}

#pragma mark -- activity

- (void)setShowingActivity:(BOOL)showingActivity
{
    if (_showingActivity != showingActivity) {
        _showingActivity = showingActivity;
        [self updateSymbolView];
    }
}


#pragma mark - content color

- (void)setContentColor:(UIColor *)contentColor
{
    if (![_contentColor isEqual:contentColor]) {
        _contentColor = contentColor;
        self.textLabel.textColor = _contentColor;
        [self updateSymbolView];
    }
}

#pragma mark helpers

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

+ (UIImage*)imageForStyle:(CSNotificationViewStyle)style
{
    UIImage* matchedImage = nil;
    switch (style) {
        case CSNotificationViewStyleSuccess:
            matchedImage = [UIImage imageNamed:@"CSNotificationView_checkmarkIcon"];
            break;
        case CSNotificationViewStyleError:
            matchedImage = [UIImage imageNamed:@"CSNotificationView_exclamationMarkIcon"];
            break;
        default:
            break;
    }
    return matchedImage;
}

+ (UIColor*)blurTintColorForStyle:(CSNotificationViewStyle)style
{
    UIColor* blurTintColor;
    switch (style) {
        case CSNotificationViewStyleSuccess:
            blurTintColor = [UIColor colorWithRed:0.21 green:0.72 blue:0.00 alpha:1.0];
            break;
        case CSNotificationViewStyleError:
            blurTintColor = [UIColor redColor];
            break;
        default:
            break;
    }
    return blurTintColor;
}

@end
