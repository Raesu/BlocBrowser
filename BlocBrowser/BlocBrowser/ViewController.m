//
//  ViewController.m
//  BlocBrowser
//
//  Created by Ryan Summe on 6/11/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "AwesomeFloatingToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, AwesomeFloatingToolbarDelegate>
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UITextField *textField;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)loadView {
    UIView *mainView = [[UIView alloc] init];
    
    self.webView = [WKWebView new];
    [self.webView setNavigationDelegate:self];
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL or Google Search", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles];
    self.awesomeToolbar.delegate = self;
    
    for (UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    // Now, assign the frames
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    NSString *urlString = self.textField.text;
    
    if (urlString) {
        if ([urlString containsString:@" "]) {
            urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            urlString = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [self.webView loadRequest:request];
        } else {
            NSURL *url = [NSURL URLWithString:urlString];
            if (!url.scheme) url = [NSURL URLWithString:[NSString stringWithString:[NSString stringWithFormat:@"http://%@",urlString]]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [self.webView loadRequest:request];
        }
    }
    return NO;
}

#pragma mark - WKNavigationDelegate

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitle];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    [self updateButtonsAndTitle];
}

#pragma mark - Miscellaneous

- (void)updateButtonsAndTitle {
    NSString *webPageTitle = [self.webView.title copy];
    if ([webPageTitle length]) {
        self.title = webPageTitle;
    } else self.title = self.webView.URL.absoluteString;
    
    self.webView.isLoading ? [self.activityIndicator startAnimating] : [self.activityIndicator stopAnimating];
    
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithIndex:0];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithIndex:1];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] forButtonWithIndex:2];
    [self.awesomeToolbar setEnabled:![self.webView isLoading] && self.webView.URL forButtonWithIndex:3];
    
}

-(void)resetWebView {
    [self.webView removeFromSuperview];
    WKWebView *newWebView = [WKWebView new];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

#pragma mark AwesomeFloatingToolbarDelegate

- (void)floatingToolBar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqualToString:kWebBrowserBackString]) {
        [self.webView goBack];
    } else if ([title isEqualToString:kWebBrowserForwardString]) {
        [self.webView goForward];
    } else if ([title isEqualToString:kWebBrowserStopString]) {
        [self.webView stopLoading];
    } else if ([title isEqualToString:kWebBrowserRefreshString]) {
        [self.webView reload];
    }
}

- (void)floatingToolBar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}

- (void)floatingToolBarDidTryToPinchWithScale:(UIPinchGestureRecognizer*)recognizer {
    // use the scale to adjust the toolbar size
    // this line seems to scale just the text
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    
    // CGContextScaleCTM(toolbar.frame, scale, scale);
    // I can't figure out how to use transform (no parameters) and exploration
    // into it led me to CGAffineTransform which then led me to CGContextScaleCTM
    // I can't figure out what "context" to put as the first argument
}

- (void)forwardPressed {
    [self.awesomeToolbar.forwardButton setAlpha:1];
    [self.webView goForward];
    [self.awesomeToolbar.forwardButton setAlpha:0.25];
}

- (void)backPressed {
    [self.webView goBack];
}

- (void)refreshPressed {
    // tried to get the refresh button to react to the button press but it happens too quickly
    // the updateButtonsAndTitle function manages it anyway
    
    [self.awesomeToolbar.refreshButton setAlpha:1];
    [self.webView reload];
    [self.awesomeToolbar.refreshButton setAlpha:0.25];
}

- (void)stopPressed {
    [self.webView stopLoading];
}

@end







