//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Ryan Summe on 6/14/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AwesomeFloatingToolbar;
@protocol AwesomeFloatingToolbarDelegate <NSObject>

@optional
- (void)floatingToolBar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
- (void)floatingToolBarDidTryToPinchWithScale:(UIPinchGestureRecognizer*)recognizer;
- (void)floatingToolBar:(AwesomeFloatingToolbar *)toolbar didLongPressWithState:(UIGestureRecognizerState)state;
- (void)backPressed;
- (void)forwardPressed;
- (void)stopPressed;
- (void)refreshPressed;
@end

@interface AwesomeFloatingToolbar : UIView

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

@property (nonatomic, strong) UIButton *forwardButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIButton *stopButton;

- (instancetype)initWithFourTitles;
- (void) setEnabled:(BOOL)enabled forButtonWithIndex:(NSUInteger)index;

@end
