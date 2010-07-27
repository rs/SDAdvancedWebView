//
//  SDAdvancedWebViewController.h
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 07/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDAdvancedWebViewPlugin;
@class SDAdvancedWebViewControllerDelegate;
@protocol SDAdvancedWebViewControllerDelegate <NSObject>
@optional
- (void)advancedWebViewController:(SDAdvancedWebViewControllerDelegate *)advancedWebViewController didOpenExternalUrl:(NSURL *)externalUrl;
- (void)advancedWebViewController:(SDAdvancedWebViewControllerDelegate *)advancedWebViewController didCancelExternalUrl:(NSURL *)externalUrl;
@end

@interface SDAdvancedWebViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
{
    @private
    UIWebView *webView;
    id<SDAdvancedWebViewControllerDelegate> delegate;
    id<UIWebViewDelegate> webViewDelegate;
    NSMutableDictionary *loadedPlugins;
    NSURL *invokeURL;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, assign) IBOutlet id<SDAdvancedWebViewControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet id<UIWebViewDelegate> webViewDelegate;

- (SDAdvancedWebViewPlugin *)pluginWithName:(NSString *)pluginName load:(BOOL)load;
- (BOOL)shouldAutorotateToInterfaceOrientationDefault:(UIInterfaceOrientation)interfaceOrientation;

@end
