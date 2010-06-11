//
//  SDAWVPluginOrientation.m
//  Dailymotion
//
//  Created by Olivier Poitrey on 10/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAWVPluginOrientation.h"

@implementation SDAWVPluginOrientation

#pragma mark Private Methods

- (int)degreeWithOrientation:(SDAWVContentOrientation)interfaceOrientation
{
    switch (interfaceOrientation)
    {
        case SDAWVContentOrientationPortrait: return 0;
        case SDAWVContentOrientationPortraitUpsideDown: return 180;
        case SDAWVContentOrientationLandscapeLeft: return 90;
        case SDAWVContentOrientationLandscapeRight: return -90;
        default: return 0;
    }
}

- (SDAWVContentOrientation)orientationWithDegree:(int)degree
{
    switch (degree)
    {
        case 0: return SDAWVContentOrientationPortrait;
        case 180: return SDAWVContentOrientationPortraitUpsideDown;
        case 90: return SDAWVContentOrientationLandscapeLeft;
        case -90: return SDAWVContentOrientationLandscapeRight;
        default: return SDAWVContentOrientationUnknown;
    }
}

#pragma mark Plugin API

- (void)setContentOrientation:(NSArray *)arguments options:(NSDictionary *)options
{
    if (arguments.count == 0)
    {
        return;
    }

    if([[arguments objectAtIndex:0] isEqualToString:@""])
    {
        forcedContentOrientation = SDAWVContentOrientationUnknown;
    }
    else
    {
        forcedContentOrientation = [self orientationWithDegree:[[arguments objectAtIndex:0] intValue]];
    }

    if (delegate.interfaceOrientation != forcedContentOrientation)
    {
        [delegate retain];
        UIViewController *parent = [delegate parentViewController];
        [delegate dismissModalViewControllerAnimated:NO];
        [parent presentModalViewController:delegate animated:NO];
        [delegate release];
    }
}

- (void)cleanup
{
    forcedContentOrientation = SDAWVContentOrientationUnknown;
}

#pragma mark Handlers

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (forcedContentOrientation != SDAWVContentOrientationUnknown)
    {
        return forcedContentOrientation == interfaceOrientation;
    }
    else
    {
        NSString *script = [NSString stringWithFormat:@"SDAdvancedWebViewObjects.orientation.shouldAutorotateToContentOrientation(%d)",
                            [self degreeWithOrientation:interfaceOrientation]];
        return [[delegate.webView stringByEvaluatingJavaScriptFromString:script] isEqualToString:@"true"];
    }
}

- (void)notifyCurrentOrientation
{
    // UIWebView doesn't have the proper interface orientation info set as it is done in Mobile Safari
    // As we can't change the standard window.orientation property, we choose to store the info in navigator.orientation
    // as PhoneGap does
    NSString *script = [NSString stringWithFormat:@"SDAdvancedWebViewObjects.orientation._notifyCurrentOrientation(%d)",
                        [self degreeWithOrientation:delegate.interfaceOrientation]];
	[delegate.webView stringByEvaluatingJavaScriptFromString:script];
}

@end
