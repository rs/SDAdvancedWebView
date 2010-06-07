//
//  SDAdvancedWebViewController.h
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 07/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDAdvancedWebViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
{
    id<UIWebViewDelegate> delegate;
    NSURL *externalUrl;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, assign) id<UIWebViewDelegate> delegate;

@end
