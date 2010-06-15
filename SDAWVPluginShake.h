//
//  SDAWVPluginShake.h
//  Dailymotion
//
//  Created by Olivier Poitrey on 11/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAdvancedWebViewPlugin.h"

@interface SDAWVPluginShake : SDAdvancedWebViewPlugin <UIAccelerometerDelegate>
{
    BOOL histeresisExcited;
    UIAcceleration *lastAcceleration;
}

- (void)start:(NSArray *)arguments options:(NSDictionary *)options;
- (void)stop:(NSArray *)arguments options:(NSDictionary *)options;

@end
