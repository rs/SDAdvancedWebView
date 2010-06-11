//
//  SDAWVPluginShake.h
//  Dailymotion
//
//  Created by Olivier Poitrey on 11/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAdvancedWebViewPlugin.h"

@interface SDAWVPluginShake : SDAdvancedWebViewPlugin
{
}

- (void)notifyShakeEvent;

@end
