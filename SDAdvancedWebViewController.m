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
    return (UIWebView *)self.view;
}

- (void)setWebView:(UIWebView *)newWebView
{
    self.view = newWebView;
    if (!newWebView.delegate)
    {
        newWebView.delegate = self;
    }
}

#pragma mark UIViewController

- (void)loadView
{
    self.webView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
                         "var event = document.createEvent('Events');"
                         "event.initEvent('orientationchange', false, false);"
                         "event.orientation = %d;"
                         "document.dispatchEvent(event);"
                         "navigator.orientation = event.orientation;"
                         "})();", [self orientationToDegree:toInterfaceOrientation]];
	[self.webView stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark UIResponder

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        NSString *script = @"(function(){"
                            "var event = document.createEvent('Events');"
                            "event.initEvent('shake', false, false);"
                            "document.dispatchEvent(event);"
                            "})();";
        [self.webView stringByEvaluatingJavaScriptFromString:script];
    }
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // UIWebView doesn't have the proper interface orientation info set as it is done in Mobile Safari
    // As we can't change the standard window.orientation property, we choose to store the info in navigator.orientation os PhoneGap does
    // See code willRotateToInterfaceOrientation:duration: for orientationchange event handling
    NSString *script = [NSString stringWithFormat:@"navigator.orientation = %d;", [self orientationToDegree:[[UIDevice currentDevice] orientation]]];
    [self.webView stringByEvaluatingJavaScriptFromString:script];


    if ([delegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [delegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [delegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [delegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        if (![delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType])
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
    [externalUrl release], externalUrl = nil;
    [super dealloc];
}


@end
