//
//  SDAWVPluginAccelerometer.m
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 10/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAWVPluginAccelerometer.h"

// defaults to 100 msec
#define kAccelerometerInterval 100
// max rate of 40 msec
#define kMinAccelerometerInterval 40
// min rate of 1/sec
#define kMaxAccelerometerInterval 1000

@implementation SDAWVPluginAccelerometer

#pragma mark Plugin API

- (void)start:(NSArray *)arguments options:(NSDictionary *)options
{
	NSTimeInterval frequency = kAccelerometerInterval;

	if ([options objectForKey:@"frequency"])
	{
		frequency = [(NSString *)[options objectForKey:@"frequency"] intValue];
		// Special case : returns 0 if int conversion fails
		if(frequency == 0)
		{
			frequency = kAccelerometerInterval;
		}
		else if(frequency < kMinAccelerometerInterval)
		{
			frequency = kMinAccelerometerInterval;
		}
		else if(frequency > kMaxAccelerometerInterval)
		{
			frequency = kMaxAccelerometerInterval;
		}
	}
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	// Accelerometer expects fractional seconds, but we have msecs
	accelerometer.updateInterval = frequency / 1000;
    accelerometer.delegate = self;
}

- (void)stop:(NSArray *)arguments options:(NSDictionary *)options
{
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    if (accelerometer.delegate == self)
    {
        accelerometer.delegate = nil;
    }
}

- (void)cleanup
{
    [self stop:nil options:nil];
}

#pragma mark UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    [self call:@"_onAccelUpdate" args:[NSArray arrayWithObjects:
                                       [NSNumber numberWithDouble:acceleration.x],
                                       [NSNumber numberWithDouble:acceleration.y],
                                       [NSNumber numberWithDouble:acceleration.z],
                                       nil]];
}

#pragma mark NSObject

- (void)dealloc
{
    [self stop:nil options:nil];
    [super dealloc];
}

@end
