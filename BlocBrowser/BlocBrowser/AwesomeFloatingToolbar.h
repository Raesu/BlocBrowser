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
- (void)floatingToolBar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title;
- (void)floatingToolBar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
- (void)floatingToolBar:(AwesomeFloatingToolbar *)toolbar didTryToPinchWithScale:(CGFloat)scale;
- (void)floatingToolBar:(AwesomeFloatingToolbar *)toolbar didLongPressWithState:(UIGestureRecognizerState)state;
@end

@interface AwesomeFloatingToolbar : UIView

@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;

- (instancetype)initWithFourTitles:(NSArray *)titles;
- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@end
