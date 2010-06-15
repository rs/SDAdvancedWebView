//
//  SDAWVPluginShake.m
//  Dailymotion
//
//  Created by Olivier Poitrey on 11/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAWVPluginShake.h"

static BOOL AccelerationIsShaking(UIAcceleration *last, UIAcceleration *current, double threshold)
{
    double deltaX = fabs(last.x - current.x),
           deltaY = fabs(last.y - current.y),
           deltaZ = fabs(last.z - current.z);

    return (deltaX > threshold && deltaY > threshold) ||
           (deltaX > threshold && deltaZ > threshold) ||
           (deltaY > threshold && deltaZ > threshold);
}

@interface SDAWVPluginShake ()
@property (nonatomic, retain) UIAcceleration *lastAcceleration;
@end

@implementation SDAWVPluginShake
@synthesize lastAcceleration;

#pragma mark Plugin API

- (void)start:(NSArray *)arguments options:(NSDictionary *)options
{
    [UIAccelerometer sharedAccelerometer].delegate = self;
    [UIAccelerometer sharedAccelerometer].updateInterval = 1.0 / 15;
}

- (void)stop:(NSArray *)arguments options:(NSDictionary *)options
{
    if ([UIAccelerometer sharedAccelerometer].delegate == self)
    {
        [UIAccelerometer sharedAccelerometer].delegate = nil;
    }
}

- (void)cleanup
{
    [self stop:nil options:nil];
}

#pragma mark UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if (self.lastAcceleration)
    {
        if (!histeresisExcited && AccelerationIsShaking(self.lastAcceleration, acceleration, 0.7))
        {
            histeresisExcited = YES;

            // Shake detected, notify webview
            [delegate.webView stringByEvaluatingJavaScriptFromString:@"SDAdvancedWebViewObjects.shake._notifyShakeDetected()"];
        }
        else if (histeresisExcited && !AccelerationIsShaking(self.lastAcceleration, acceleration, 0.2))
        {
            histeresisExcited = NO;
        }
    }

    self.lastAcceleration = acceleration;
}

#pragma mark NSObject

- (void)dealloc
{
    [self stop:nil options:nil];
    [super dealloc];
}

@end
