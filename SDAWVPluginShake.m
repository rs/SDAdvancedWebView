//
//  SDAWVPluginShake.m
//  Dailymotion
//
//  Created by Olivier Poitrey on 11/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAWVPluginShake.h"


@implementation SDAWVPluginShake

- (void)notifyShakeEvent
{
    [delegate.webView stringByEvaluatingJavaScriptFromString:
     @"(function(){"
      "var event = document.createEvent('Events');"
      "event.initEvent('shake', true);"
      "document.dispatchEvent(event);"
      "})();"];
}

@end
