//
//  SDAdvancedWebViewPlugin.m
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 10/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAdvancedWebViewPlugin.h"

@implementation SDAdvancedWebViewPlugin
@synthesize delegate;

+ (void)installPluginForWebview:(UIWebView *)aWebView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:NSStringFromClass(self) ofType:@"js"];
    if (path)
    {
        NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [aWebView stringByEvaluatingJavaScriptFromString:script];
    }
}

- (void)cleanup
{
}

- (void)dealloc
{
    [self cleanup];
    [super dealloc];
}


@end
