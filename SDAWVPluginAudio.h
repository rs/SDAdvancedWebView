//
//  SDAWVPluginAudio.h
//  Dailymotion
//
//  Created by Olivier Poitrey on 14/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SDAdvancedWebViewPlugin.h"

@interface SDAWVPluginAudio : SDAdvancedWebViewPlugin <AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
    NSURLConnection *connection;
    NSMutableData *audioData;
}

@property (nonatomic, retain) AVAudioPlayer *player;

- (void)load:(NSArray *)arguments options:(NSDictionary *)options;
- (void)play:(NSArray *)arguments options:(NSDictionary *)options;
- (void)pause:(NSArray *)arguments options:(NSDictionary *)options;
- (void)stop:(NSArray *)arguments options:(NSDictionary *)options;

@end
