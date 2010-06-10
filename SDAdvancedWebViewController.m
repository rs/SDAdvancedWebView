    //
//  SDAdvancedWebViewController.m
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 07/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAdvancedWebViewController.h"

@interface SDAdvancedWebViewController ()
@property (nonatomic, retain) NSURL *externalUrl;
@end

@implementation SDAdvancedWebViewController
@synthesize delegate, externalUrl;
@dynamic webView;

#pragma mark SDAdvancedWebViewController (private)

- (int)orientationToDegree:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait: return 0;
        case UIInterfaceOrientationPortraitUpsideDown: return 180;
        case UIInterfaceOrientationLandscapeLeft: return 90;
        case UIInterfaceOrientationLandscapeRight: return -90;
        default: return 0;
    }
}

#pragma mark SDAdvancedWebViewController (accessors)

- (UIWebView *)webView
{
    if (!webView && ![self isViewLoaded])
    {
        // force the loading of the view in order to generate the webview
        self.view;
    }
    return [[webView retain] autorelease];
}

- (void)setWebView:(UIWebView *)newWebView
{
    if (webView != newWebView)
    {
        [webView release];
        webView = [newWebView retain];

        if (!webView.delegate)
        {
            webView.delegate = self;
        }

        if (!webView.superview)
        {
            webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            webView.frame = self.view.bounds;
            [self.view addSubview:webView];
        }
    }
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!webView)
    {
        self.webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
    }
}

- (void)viewDidUnload
{
    // Force release loaded page elements by loading empty page (iPad have a bug with media player not released for instance)
    [webView loadHTMLString:@"" baseURL:nil];
    self.webView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder]; // Necessary to capture shake events
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // UIWebView doesn't propagate orientation change event by default as mobile safari does.
    NSString *script = [NSString stringWithFormat:
                        @"(function(){"
                         "navigator.orientation = %d;"
                         "var event = document.createEvent('Events');"
                         "event.initEvent('orientationchange', true);"
                         "document.dispatchEvent(event);"
                         "})();", [self orientationToDegree:toInterfaceOrientation]];
	[self.webView stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        NSString *script = @"(function(){"
                            "var event = document.createEvent('Events');"
                            "event.initEvent('shake', true);"
                            "document.dispatchEvent(event);"
                            "})();";
        [self.webView stringByEvaluatingJavaScriptFromString:script];
    }

    if ([super respondsToSelector:@selector(motionEnded:withEvent:)])
    {
        [super motionEnded:motion withEvent:event];
    }
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    // UIWebView doesn't have the proper interface orientation info set as it is done in Mobile Safari
    // As we can't change the standard window.orientation property, we choose to store the info in navigator.orientation os PhoneGap does
    // See code willRotateToInterfaceOrientation:duration: for orientationchange event handling
    NSString *script = [NSString stringWithFormat:@"navigator.orientation = %d;", [self orientationToDegree:[[UIDevice currentDevice] orientation]]];
    [aWebView stringByEvaluatingJavaScriptFromString:script];


    if ([delegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [delegate webViewDidStartLoad:aWebView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    if ([delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [delegate webViewDidFinishLoad:aWebView];
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [delegate webView:aWebView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        if (![delegate webView:aWebView shouldStartLoadWithRequest:request navigationType:navigationType])
        {
            return NO;
        }
    }

    NSURL *url = request.URL;

    // Handles special URLs like URLs to AppStore or other kinds of schemes like tel: appname: etc...
    // The user is asked if he accept to leave the app in order to open those external resources
    if ((![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"] && ![url.scheme isEqualToString:@"about"])
        || [url.host isEqualToString:@"phobos.apple.com"]
        || [url.host isEqualToString:@"itunes.apple.com"]
        || [url.host isEqualToString:@"maps.google.com"])
    {
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            self.externalUrl = url;

            NSString *targetName;
            if ([url.host isEqualToString:@"phobos.apple.com"] || [url.host isEqualToString:@"itunes.apple.com"])
            {
                if (([url.path rangeOfString:@"/app/"]).location == NSNotFound)
                {
                    targetName = @"iTunes";
                }
                else
                {
                    targetName = @"App Store";
                }
            }
            else if ([url.host isEqualToString:@"maps.google.com"])
            {
                targetName = NSLocalizedString(@"Maps", @"Do you want to open <the iPhone application name for Maps>");
            }
            else if ([url.scheme isEqualToString:@"mailto"])
            {
                targetName = NSLocalizedString(@"Mail", @"Do you want to open <the iPhone application name for Mail>");
            }
            else if ([url.scheme isEqualToString:@"sms"])
            {
                targetName = NSLocalizedString(@"Text", @"Do you want to open <the iPhone application name for Text>");
            }
            else
            {
                targetName = NSLocalizedString(@"another application", @"Do you want to open <another application>");
            }

            [[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"You are about to leave %@", nil),
                                                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"]]
                                         message:[NSString stringWithFormat:NSLocalizedString(@"Do you want to open %@?", nil), targetName]
                                        delegate:self
                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                               otherButtonTitles:NSLocalizedString(@"Open", nil), nil] autorelease] show];
        }
        return NO;
    }

    return YES;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= alertView.firstOtherButtonIndex)
    {
        [[UIApplication sharedApplication] openURL:externalUrl];
    }
}

#pragma mark NSObject

- (void)dealloc
{
    // Force release loaded page elements by loading empty page (iPad have a bug with media player not released for instance)
    [webView loadHTMLString:@"" baseURL:nil];
    [webView release], webView = nil;
    [externalUrl release], externalUrl = nil;
    [super dealloc];
}


@end
