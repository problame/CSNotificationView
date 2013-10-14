//
//  CSNotificationView.m
//  CSNotificationView
//
//  Created by Christian Schwarz on 01.09.13.
//  Copyright (c) 2013 Christian Schwarz. Check LICENSE.md.
//

#import "CSNotificationView.h"

static NSInteger const kCSNotificationViewEmptySymbolViewTag = 666;

@interface CSNotificationView ()

#pragma mark - blur effect
@property (nonatomic) UIColor* blurTintColor;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) CALayer *blurLayer;

#pragma mark - presentation
@property (nonatomic, weak) UIViewController* parentViewController;
@property (nonatomic, getter = isVisible) BOOL visible;

#pragma mark - content views
@property (nonatomic, strong, readonly) UIView* symbolView; // is managed by - (void)useViewForSymbolView:(UIView*)view
@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, strong) UIColor* contentColor;

@end

@implementation CSNotificationView
@dynamic blurTintColor;

#pragma mark + quick presentation

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

#pragma mark + creators

+ (CSNotificationView*)notificationViewWithParentViewController:(UIViewController*)viewController
                                                      tintColor:(UIColor*)tintColor
                                                          image:(UIImage*)image
                                                        message:(NSString*)message
{
    NSParameterAssert(viewController);
    
    CSNotificationView* note = [[CSNotificationView alloc] initWithParentViewController:viewController];
    note.blurTintColor = tintColor;
    note.image = image;
    note.textLabel.text = message;
    
    return note;
}

#pragma mark - lifecycle

- (instancetype)initWithParentViewController:(UIViewController*)viewController
{
    self = [super initWithFrame:CGRectZero];
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
            //symbolView
            {
                [self useViewForSymbolView:nil];
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
    
    self.symbolView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat symbolViewWidth = self.symbolView.tag != kCSNotificationViewEmptySymbolViewTag ?
                                kCSNotificationViewSymbolViewSidelength : 0.0f;
    CGFloat symbolViewHeight = kCSNotificationViewSymbolViewSidelength;
    
    NSDictionary* metrics =
        @{@"symbolViewWidth": [NSNumber numberWithFloat:symbolViewWidth],
          @"symbolViewHeight":[NSNumber numberWithFloat:symbolViewHeight]};
    
    [self addConstraints:[NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-(4)-[_symbolView(symbolViewWidth)]-(5)-[_textLabel]-(10)-|"
                            options:0
                            metrics:metrics
                              views:NSDictionaryOfVariableBindings(_textLabel, _symbolView)]];
    
    [self addConstraints:[NSLayoutConstraint
        constraintsWithVisualFormat:@"V:[_symbolView(symbolViewHeight)]"
                            options:0
                            metrics:metrics
                                views:NSDictionaryOfVariableBindings(_symbolView)]];
    
    CGFloat topInset = CGRectGetHeight(self.frame) - 4;
    
    [self addConstraint:[NSLayoutConstraint
                constraintWithItem:_symbolView
                         attribute:NSLayoutAttributeBottom
                         relatedBy:NSLayoutRelationEqual
                            toItem:self
                         attribute:NSLayoutAttributeBottom
                         multiplier:0.0f constant:topInset]];
    
    [self addConstraint:[NSLayoutConstraint
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
    self.blurLayer.frame = self.bounds;
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([object isEqual:self.parentViewController.view]) {
        if ([keyPath isEqualToString:@"contentOffset"] && self.visible) {
            self.frame = [self visibleFrame];
        }
    }
}

#pragma mark - blur

- (void)setBlurTintColor:(UIColor *)blurTintColor
{
    [self.toolbar setBarTintColor:blurTintColor];
    self.contentColor = [self legibleTextColorForBlurTintColor:blurTintColor];
}

- (UIColor *)blurTintColor
{
    return self.toolbar.barTintColor;
}

#pragma mark - presentation

- (void)setVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)())completion
{
    if (_visible != visible) {
        
        NSTimeInterval animationDuration = animated ? 0.4 : 0.0;
        CGRect startFrame = visible ? [self hiddenFrame]:[self visibleFrame];
        CGRect endFrame = visible ? [self visibleFrame] : [self hiddenFrame];
        
        if (!self.superview) {
            self.frame = startFrame;
            [self.parentViewController.view addSubview:self];
        }
        
        __block typeof(self) weakself = self;
        [UIView animateWithDuration:animationDuration animations:^{
            [weakself setFrame:endFrame];
        } completion:^(BOOL finished) {
            if (!visible) {
                [weakself removeFromSuperview];
            }
            if (completion) {
                completion();
            }
        }];
        
        _visible = visible;
    } else if (completion) {
        completion();
    }
}

#pragma mark - frame calculation

- (CGRect)visibleFrame
{
    UIViewController* viewController = self.parentViewController;
    
    CGRect displayFrame = CGRectMake(0, 0, CGRectGetWidth(viewController.view.frame),
                                     kCSNotificationViewHeight + viewController.topLayoutGuide.length);
    
    if ([viewController.view isKindOfClass:[UIScrollView class]]) {
        //Add offset
        UIScrollView* scrollView = (UIScrollView*)viewController.view;
        displayFrame.origin.y += scrollView.contentOffset.y;
    }
    return displayFrame;
}

- (CGRect)hiddenFrame
{
    UIViewController* viewController = self.parentViewController;
    
    CGRect offscreenFrame = CGRectMake(0, -kCSNotificationViewHeight - viewController.topLayoutGuide.length,
                                       CGRectGetWidth(viewController.view.frame),
                                       kCSNotificationViewHeight + viewController.topLayoutGuide.length);
    
    if ([viewController.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView* scrollView = (UIScrollView*)viewController.view;
        offscreenFrame.origin.y -= scrollView.contentInset.top - scrollView.contentOffset.y;
    }
    return offscreenFrame;
}

#pragma mark - symbol view

- (void)useViewForSymbolView:(UIView*)view
{
    [self.symbolView removeFromSuperview];
    if (!view) {
        _symbolView = [[UIView alloc] initWithFrame:CGRectZero];
        _symbolView.tag = kCSNotificationViewEmptySymbolViewTag;
    } else {
        NSAssert(view.tag != kCSNotificationViewEmptySymbolViewTag, @"view is tagged with a tag that is used to identify an empty symbolView");
        _symbolView = view;
    }
    [self addSubview:_symbolView];
    [self setNeedsUpdateConstraints];
}

#pragma mark - image

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self setupSymbolViewWithImage:_image];
}

- (void)setupSymbolViewWithImage:(UIImage*)image
{
    if (!image) {
        [self useViewForSymbolView:nil];
        return;
    }
    
    //Generate UIImageView for symbolView
    UIImageView* imageView = [[UIImageView alloc] init];
    imageView.opaque = NO;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = [self imageFromAlphaChannelOfImage:image replacementColor:self.contentColor];
    [self useViewForSymbolView:imageView];
}

#pragma mark - content color

- (void)setContentColor:(UIColor *)contentColor
{
    if (![_contentColor isEqual:contentColor]) {
        _contentColor = contentColor;
        [self applyContentColor];
    }
    
}

- (void)applyContentColor
{
    self.textLabel.textColor = _contentColor;
    if (self.image) {
        [self setupSymbolViewWithImage:self.image];
    }
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
