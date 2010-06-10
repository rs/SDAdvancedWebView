//
//  SDAdvancedWebViewPlugin.h
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 10/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDAdvancedWebViewPlugin : NSObject
{
    UIWebView *webView;
}

@property (nonatomic, retain) UIWebView *webView;

+ (void)installPluginForWebview:(UIWebView *)aWebView;
- (id)initWithWebView:(UIWebView *)aWebView;

@end
