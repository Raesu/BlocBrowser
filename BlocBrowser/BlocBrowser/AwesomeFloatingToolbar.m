//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Ryan Summe on 6/14/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype)initWithFourTitles {
    self = [super init];
    
    if (self) {
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/225.0 blue:203/225.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        self.backButton = [UIButton new];
        [self.backButton setTitle:kWebBrowserBackString forState:UIControlStateNormal];
        [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.backButton addTarget:self.delegate action:@selector(backPressed) forControlEvents:UIControlEventTouchDown];
        [self.backButton setBackgroundColor:self.colors[1]];
        [self.backButton setAlpha:0.25];
        [self addSubview:self.backButton];
        
        self.forwardButton = [UIButton new];
        [self.forwardButton setTitle:kWebBrowserForwardString forState:UIControlStateNormal];
        [self.forwardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.forwardButton addTarget:self.delegate action:@selector(forwardPressed) forControlEvents:UIControlEventTouchDown];
        [self.forwardButton setBackgroundColor:self.colors[0]];
        [self.forwardButton setAlpha:0.25];
        [self addSubview:self.forwardButton];
        
        self.stopButton = [UIButton new];
        [self.stopButton setTitle:kWebBrowserStopString forState:UIControlStateNormal];
        [self.stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.stopButton addTarget:self.delegate action:@selector(stopPressed) forControlEvents:UIControlEventTouchDown];
        [self.stopButton setBackgroundColor:self.colors[3]];
        [self.stopButton setAlpha:0.25];
        [self addSubview:self.stopButton];
        
        self.refreshButton = [UIButton new];
        [self.refreshButton setTitle:kWebBrowserRefreshString forState:UIControlStateNormal];
        [self.refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.refreshButton addTarget:self.delegate action:@selector(refreshPressed) forControlEvents:UIControlEventTouchDown];
        [self.refreshButton setBackgroundColor:self.colors[2]];
        [self.refreshButton setAlpha:0.25];
        [self addSubview:self.refreshButton];
        
        self.buttons = [[NSArray alloc] initWithObjects:self.backButton, self.forwardButton, self.stopButton, self.refreshButton, nil];

    }

    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
    [self addGestureRecognizer:self.panGesture];
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
    [self addGestureRecognizer:self.pinchGesture];
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
    [self addGestureRecognizer:self.longPressGesture];
    
    return self;
}

- (void)layoutSubviews {
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentLabelIndex = [self.buttons indexOfObject:thisButton];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds)/2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds)/2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // This isn't assignable?
        // currentLabelIndex < 2 ? labelY = 0 : labelY = labelHeight;
        
        if (currentLabelIndex < 2) {
            labelY = 0;
        } else labelY = CGRectGetHeight(self.bounds)/2;
        
        if (currentLabelIndex % 2 == 0) {
            labelX = 0;
        } else labelX = CGRectGetWidth(self.bounds)/2;
        
        thisButton.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}

#pragma mark Button Enabling

- (void)setEnabled:(BOOL)enabled forButtonWithIndex:(NSUInteger)index {

    UIButton *button = [self.buttons objectAtIndex:index];
    [button setUserInteractionEnabled:enabled];
    button.alpha = enabled ? 1.0 : 0.25;
}


#pragma mark Touch Handling

- (UILabel *)labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UILabel class]]) {
        return (UILabel *)subview;
    } else return nil;
}

- (void)panFired:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self];
    
    if ([self.delegate respondsToSelector:@selector(floatingToolBar:didTryToPanWithOffset:)]) {
        [self.delegate floatingToolBar:self didTryToPanWithOffset:translation];
    }
    
    [recognizer setTranslation:CGPointZero inView:self];
}

- (void)pinchFired:(UIPinchGestureRecognizer *)recognizer {

    if ([self.delegate respondsToSelector:@selector(floatingToolBarDidTryToPinchWithScale:)]) {
        [self.delegate floatingToolBarDidTryToPinchWithScale:recognizer];
    }

}

- (void)longPressFired:(UILongPressGestureRecognizer *)recognizer {
    // added state checker so that multiple color shifts don't occur
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        UIColor *tempColor = [[self.buttons objectAtIndex:0] backgroundColor];
        [[self.buttons objectAtIndex:0] setBackgroundColor:[[self.buttons objectAtIndex:1] backgroundColor]];
        [[self.buttons objectAtIndex:1] setBackgroundColor:[[self.buttons objectAtIndex:2] backgroundColor]];
        [[self.buttons objectAtIndex:2] setBackgroundColor:[[self.buttons objectAtIndex:3] backgroundColor]];
        [[self.buttons objectAtIndex:3] setBackgroundColor:tempColor];
    }
}


@end
