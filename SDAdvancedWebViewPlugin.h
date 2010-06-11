//
//  SDAdvancedWebViewPlugin.h
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 10/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDAdvancedWebViewController.h"

@interface SDAdvancedWebViewPlugin : NSObject
{
    SDAdvancedWebViewController *delegate;
}

@property (nonatomic, assign) SDAdvancedWebViewController *delegate;

+ (void)installPluginForWebview:(UIWebView *)aWebView;
- (void)cleanup;

@end
