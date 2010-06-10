//
//  SDAWVPluginAccelerometer.h
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 10/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAdvancedWebViewPlugin.h"

@interface SDAWVPluginAccelerometer : SDAdvancedWebViewPlugin <UIAccelerometerDelegate>
{
}

- (void)start:(NSArray *)arguments options:(NSDictionary *)options;
- (void)stop:(NSArray *)arguments options:(NSDictionary *)options;

@end
