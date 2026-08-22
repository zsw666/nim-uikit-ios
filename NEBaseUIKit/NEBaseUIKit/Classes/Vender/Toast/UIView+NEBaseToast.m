// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
#import "UIView+NEBaseToast.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// Positions
NSString * NEBaseToastPositionTop                       = @"NEBaseToastPositionTop";
NSString * NEBaseToastPositionCenter                    = @"NEBaseToastPositionCenter";
NSString * NEBaseToastPositionBottom                    = @"NEBaseToastPositionBottom";

// Keys for values associated with toast views
static const NSString * NEBaseToastTimerKey             = @"NEBaseToastTimerKey";
static const NSString * NEBaseToastDurationKey          = @"NEBaseToastDurationKey";
static const NSString * NEBaseToastPositionKey          = @"NEBaseToastPositionKey";
static const NSString * NEBaseToastCompletionKey        = @"NEBaseToastCompletionKey";

// Keys for values associated with self
static const NSString * NEBaseToastActiveKey            = @"NEBaseToastActiveKey";
static const NSString * NEBaseToastActivityViewKey      = @"NEBaseToastActivityViewKey";
static const NSString * NEBaseToastQueueKey             = @"NEBaseToastQueueKey";

@interface UIView (ToastPrivate)

- (void)nebase_showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position;
- (void)nebase_hideToast:(UIView *)toast;
- (void)nebase_hideToast:(UIView *)toast fromTap:(BOOL)fromTap;
- (void)nebase_toastTimerDidFinish:(NSTimer *)timer;
- (void)nebase_handleToastTapped:(UITapGestureRecognizer *)recognizer;
- (CGPoint)nebase_centerPointForPosition:(id)position withToast:(UIView *)toast;
- (NSMutableArray *)nebase_toastQueue;

@end

@implementation UIView (NEBaseToast)

#pragma mark - Make Toast Methods

- (void)ne_baseMakeToast:(NSString *)message {
    [self ne_baseMakeToast:message duration:[NEBaseToastManager defaultDuration] position:[NEBaseToastManager defaultPosition] style:nil];
}

- (void)ne_baseMakeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position {
    [self ne_baseMakeToast:message duration:duration position:position style:nil];
}

- (void)ne_baseMakeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position style:(NEBaseToastStyle *)style {
    UIView *toast = [self ne_baseToastViewForMessage:message title:nil image:nil style:style];
    [self ne_baseShowToast:toast duration:duration position:position completion:nil];
}

- (void)ne_baseMakeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position title:(NSString *)title image:(UIImage *)image style:(NEBaseToastStyle *)style completion:(void(^)(BOOL didTap))completion {
    UIView *toast = [self ne_baseToastViewForMessage:message title:title image:image style:style];
    [self ne_baseShowToast:toast duration:duration position:position completion:completion];
}

#pragma mark - Show Toast Methods

- (void)ne_baseShowToast:(UIView *)toast {
    [self ne_baseShowToast:toast duration:[NEBaseToastManager defaultDuration] position:[NEBaseToastManager defaultPosition] completion:nil];
}

- (void)ne_baseShowToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position completion:(void(^)(BOOL didTap))completion {
    // sanity
    if (toast == nil) return;

    // store the completion block on the toast view
    objc_setAssociatedObject(toast, &NEBaseToastCompletionKey, completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if ([NEBaseToastManager isQueueEnabled] && [self.nebase_activeToasts count] > 0) {
        // we're about to queue this toast view so we need to store the duration and position as well
        objc_setAssociatedObject(toast, &NEBaseToastDurationKey, @(duration), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(toast, &NEBaseToastPositionKey, position, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        // enqueue
        [self.nebase_toastQueue addObject:toast];
    } else {
        // present
        [self nebase_showToast:toast duration:duration position:position];
    }
}

#pragma mark - Hide Toast Methods

- (void)ne_baseHideToast {
    [self ne_baseHideToast:[[self nebase_activeToasts] firstObject]];
}

- (void)ne_baseHideToast:(UIView *)toast {
    // sanity
    if (!toast || ![[self nebase_activeToasts] containsObject:toast]) return;

    [self nebase_hideToast:toast];
}

- (void)ne_baseHideAllToasts {
    [self ne_baseHideAllToasts:NO clearQueue:YES];
}

- (void)ne_baseHideAllToasts:(BOOL)includeActivity clearQueue:(BOOL)clearQueue {
    if (clearQueue) {
        [self ne_baseClearToastQueue];
    }

    for (UIView *toast in [self nebase_activeToasts]) {
        [self ne_baseHideToast:toast];
    }

    if (includeActivity) {
        [self ne_baseHideToastActivity];
    }
}

- (void)ne_baseClearToastQueue {
    [[self nebase_toastQueue] removeAllObjects];
}

#pragma mark - Private Show/Hide Methods

- (void)nebase_showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position {
    toast.center = [self nebase_centerPointForPosition:position withToast:toast];
    toast.alpha = 0.0;

    if ([NEBaseToastManager isTapToDismissEnabled]) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nebase_handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        toast.exclusiveTouch = YES;
    }

    [[self nebase_activeToasts] addObject:toast];

    [self addSubview:toast];

    [UIView animateWithDuration:[[NEBaseToastManager sharedStyle] fadeDuration]
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(nebase_toastTimerDidFinish:) userInfo:toast repeats:NO];
                         [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                         objc_setAssociatedObject(toast, &NEBaseToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}

- (void)nebase_hideToast:(UIView *)toast {
    [self nebase_hideToast:toast fromTap:NO];
}

- (void)nebase_hideToast:(UIView *)toast fromTap:(BOOL)fromTap {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(toast, &NEBaseToastTimerKey);
    [timer invalidate];

    [UIView animateWithDuration:[[NEBaseToastManager sharedStyle] fadeDuration]
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];

                         // remove
                         [[self nebase_activeToasts] removeObject:toast];

                         // execute the completion block, if necessary
                         void (^completion)(BOOL didTap) = objc_getAssociatedObject(toast, &NEBaseToastCompletionKey);
                         if (completion) {
                             completion(fromTap);
                         }

                         if ([self.nebase_toastQueue count] > 0) {
                             // dequeue
                             UIView *nextToast = [[self nebase_toastQueue] firstObject];
                             [[self nebase_toastQueue] removeObjectAtIndex:0];

                             // present the next toast
                             NSTimeInterval duration = [objc_getAssociatedObject(nextToast, &NEBaseToastDurationKey) doubleValue];
                             id position = objc_getAssociatedObject(nextToast, &NEBaseToastPositionKey);
                             [self nebase_showToast:nextToast duration:duration position:position];
                         }
                     }];
}

#pragma mark - View Construction

- (UIView *)ne_baseToastViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image style:(NEBaseToastStyle *)style {
    // sanity
    if (message == nil && title == nil && image == nil) return nil;

    // default to the shared style
    if (style == nil) {
        style = [NEBaseToastManager sharedStyle];
    }

    // dynamically build a toast view with any combination of message, title, & image
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;

    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = style.cornerRadius;

    if (style.displayShadow) {
        wrapperView.layer.shadowColor = style.shadowColor.CGColor;
        wrapperView.layer.shadowOpacity = style.shadowOpacity;
        wrapperView.layer.shadowRadius = style.shadowRadius;
        wrapperView.layer.shadowOffset = style.shadowOffset;
    }

    wrapperView.backgroundColor = style.backgroundColor;

    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(style.horizontalPadding, style.verticalPadding, style.imageSize.width, style.imageSize.height);
    }

    CGRect imageRect = CGRectZero;

    if(imageView != nil) {
        imageRect.origin.x = style.horizontalPadding;
        imageRect.origin.y = style.verticalPadding;
        imageRect.size.width = imageView.bounds.size.width;
        imageRect.size.height = imageView.bounds.size.height;
    }

    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = style.titleNumberOfLines;
        titleLabel.font = style.titleFont;
        titleLabel.textAlignment = style.titleAlignment;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textColor = style.titleColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;

        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, self.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeTitle = [titleLabel sizeThatFits:maxSizeTitle];
        // UILabel can return a size larger than the max size when the number of lines is 1
        expectedSizeTitle = CGSizeMake(MIN(maxSizeTitle.width, expectedSizeTitle.width), MIN(maxSizeTitle.height, expectedSizeTitle.height));
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }

    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = style.messageNumberOfLines;
        messageLabel.font = style.messageFont;
        messageLabel.textAlignment = style.messageAlignment;
        messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        messageLabel.textColor = style.messageColor;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;

        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, self.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeMessage = [messageLabel sizeThatFits:maxSizeMessage];
        // UILabel can return a size larger than the max size when the number of lines is 1
        expectedSizeMessage = CGSizeMake(MIN(maxSizeMessage.width, expectedSizeMessage.width), MIN(maxSizeMessage.height, expectedSizeMessage.height));
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }

    CGRect titleRect = CGRectZero;

    if(titleLabel != nil) {
        titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding;
        titleRect.origin.y = style.verticalPadding;
        titleRect.size.width = titleLabel.bounds.size.width;
        titleRect.size.height = titleLabel.bounds.size.height;
    }

    CGRect messageRect = CGRectZero;

    if(messageLabel != nil) {
        messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding;
        messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding;
        messageRect.size.width = messageLabel.bounds.size.width;
        messageRect.size.height = messageLabel.bounds.size.height;
    }

    CGFloat longerWidth = MAX(titleRect.size.width, messageRect.size.width);
    CGFloat longerX = MAX(titleRect.origin.x, messageRect.origin.x);

    // Wrapper width uses the longerWidth or the image width, whatever is larger. Same logic applies to the wrapper height.
    CGFloat wrapperWidth = MAX((imageRect.size.width + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding));
    CGFloat wrapperHeight = MAX((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imageRect.size.height + (style.verticalPadding * 2.0)));

    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);

    if(titleLabel != nil) {
        titleLabel.frame = titleRect;
        [wrapperView addSubview:titleLabel];
    }

    if(messageLabel != nil) {
        messageLabel.frame = messageRect;
        [wrapperView addSubview:messageLabel];
    }

    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }

    return wrapperView;
}

#pragma mark - Storage

- (NSMutableArray *)nebase_activeToasts {
    NSMutableArray *nebase_activeToasts = objc_getAssociatedObject(self, &NEBaseToastActiveKey);
    if (nebase_activeToasts == nil) {
        nebase_activeToasts = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &NEBaseToastActiveKey, nebase_activeToasts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return nebase_activeToasts;
}

- (NSMutableArray *)nebase_toastQueue {
    NSMutableArray *nebase_toastQueue = objc_getAssociatedObject(self, &NEBaseToastQueueKey);
    if (nebase_toastQueue == nil) {
        nebase_toastQueue = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &NEBaseToastQueueKey, nebase_toastQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return nebase_toastQueue;
}

#pragma mark - Events

- (void)nebase_toastTimerDidFinish:(NSTimer *)timer {
    [self nebase_hideToast:(UIView *)timer.userInfo];
}

- (void)nebase_handleToastTapped:(UITapGestureRecognizer *)recognizer {
    UIView *toast = recognizer.view;
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(toast, &NEBaseToastTimerKey);
    [timer invalidate];

    [self nebase_hideToast:toast fromTap:YES];
}

#pragma mark - Activity Methods

- (void)ne_baseMakeToastActivity:(id)position {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &NEBaseToastActivityViewKey);
    if (existingActivityView != nil) return;

    NEBaseToastStyle *style = [NEBaseToastManager sharedStyle];

    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, style.activitySize.width, style.activitySize.height)];
    activityView.center = [self nebase_centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = style.backgroundColor;
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = style.cornerRadius;

    if (style.displayShadow) {
        activityView.layer.shadowColor = style.shadowColor.CGColor;
        activityView.layer.shadowOpacity = style.shadowOpacity;
        activityView.layer.shadowRadius = style.shadowRadius;
        activityView.layer.shadowOffset = style.shadowOffset;
    }

    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];

    // associate the activity view with self
    objc_setAssociatedObject (self, &NEBaseToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addSubview:activityView];

    [UIView animateWithDuration:style.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)ne_baseHideToastActivity {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &NEBaseToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:[[NEBaseToastManager sharedStyle] fadeDuration]
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &NEBaseToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

#pragma mark - Helpers

- (CGPoint)nebase_centerPointForPosition:(id)point withToast:(UIView *)toast {
    NEBaseToastStyle *style = [NEBaseToastManager sharedStyle];

    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInsets = self.safeAreaInsets;
    }

    CGFloat topPadding = style.verticalPadding + safeInsets.top;
    CGFloat bottomPadding = style.verticalPadding + safeInsets.bottom;

    if([point isKindOfClass:[NSString class]]) {
        if([point caseInsensitiveCompare:NEBaseToastPositionTop] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2.0, (toast.frame.size.height / 2.0) + topPadding);
        } else if([point caseInsensitiveCompare:NEBaseToastPositionCenter] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }

    // default to bottom
    return CGPointMake(self.bounds.size.width / 2.0, (self.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding);
}

@end

@implementation NEBaseToastStyle

#pragma mark - Constructors

- (instancetype)initWithDefaultStyle {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.titleColor = [UIColor whiteColor];
        self.messageColor = [UIColor whiteColor];
        self.maxWidthPercentage = 0.8;
        self.maxHeightPercentage = 0.8;
        self.horizontalPadding = 10.0;
        self.verticalPadding = 10.0;
        self.cornerRadius = 10.0;
        self.titleFont = [UIFont boldSystemFontOfSize:16.0];
        self.messageFont = [UIFont systemFontOfSize:16.0];
        self.titleAlignment = NSTextAlignmentLeft;
        self.messageAlignment = NSTextAlignmentLeft;
        self.titleNumberOfLines = 0;
        self.messageNumberOfLines = 0;
        self.displayShadow = NO;
        self.shadowOpacity = 0.8;
        self.shadowRadius = 6.0;
        self.shadowOffset = CGSizeMake(4.0, 4.0);
        self.imageSize = CGSizeMake(80.0, 80.0);
        self.activitySize = CGSizeMake(100.0, 100.0);
        self.fadeDuration = 0.2;
    }
    return self;
}

- (void)setMaxWidthPercentage:(CGFloat)maxWidthPercentage {
    _maxWidthPercentage = MAX(MIN(maxWidthPercentage, 1.0), 0.0);
}

- (void)setMaxHeightPercentage:(CGFloat)maxHeightPercentage {
    _maxHeightPercentage = MAX(MIN(maxHeightPercentage, 1.0), 0.0);
}

- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

@end

@interface NEBaseToastManager ()

@property (strong, nonatomic) NEBaseToastStyle *sharedStyle;
@property (assign, nonatomic, getter=isTapToDismissEnabled) BOOL tapToDismissEnabled;
@property (assign, nonatomic, getter=isQueueEnabled) BOOL queueEnabled;
@property (assign, nonatomic) NSTimeInterval defaultDuration;
@property (strong, nonatomic) id defaultPosition;

@end

@implementation NEBaseToastManager

#pragma mark - Constructors

+ (instancetype)sharedManager {
    static NEBaseToastManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sharedStyle = [[NEBaseToastStyle alloc] initWithDefaultStyle];
        self.tapToDismissEnabled = YES;
        self.queueEnabled = NO;
        self.defaultDuration = 3.0;
        self.defaultPosition = NEBaseToastPositionBottom;
    }
    return self;
}

#pragma mark - Singleton Methods

+ (void)setSharedStyle:(NEBaseToastStyle *)sharedStyle {
    [[self sharedManager] setSharedStyle:sharedStyle];
}

+ (NEBaseToastStyle *)sharedStyle {
    return [[self sharedManager] sharedStyle];
}

+ (void)setTapToDismissEnabled:(BOOL)tapToDismissEnabled {
    [[self sharedManager] setTapToDismissEnabled:tapToDismissEnabled];
}

+ (BOOL)isTapToDismissEnabled {
    return [[self sharedManager] isTapToDismissEnabled];
}

+ (void)setQueueEnabled:(BOOL)queueEnabled {
    [[self sharedManager] setQueueEnabled:queueEnabled];
}

+ (BOOL)isQueueEnabled {
    return [[self sharedManager] isQueueEnabled];
}

+ (void)setDefaultDuration:(NSTimeInterval)duration {
    [[self sharedManager] setDefaultDuration:duration];
}

+ (NSTimeInterval)defaultDuration {
    return [[self sharedManager] defaultDuration];
}

+ (void)setDefaultPosition:(id)position {
    if ([position isKindOfClass:[NSString class]] || [position isKindOfClass:[NSValue class]]) {
        [[self sharedManager] setDefaultPosition:position];
    }
}

+ (id)defaultPosition {
    return [[self sharedManager] defaultPosition];
}

@end
