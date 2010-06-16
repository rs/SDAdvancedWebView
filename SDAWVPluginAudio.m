//
//  SDAWVPluginAudio.m
//  Dailymotion
//
//  Created by Olivier Poitrey on 14/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAWVPluginAudio.h"

#define kMaxAudioFileBytes 1024*1024

@interface SDAWVPluginAudio ()
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *audioData;
@end

@implementation SDAWVPluginAudio
@synthesize player, connection, audioData;

#pragma mark Audio Download

- (void)cancelCurrentDownload
{
    if (connection)
    {
        [connection cancel];
        self.connection = nil;
        self.audioData = nil;
    }
}

- (void)downloadAudioData:(NSURL *)audioURL
{
    [self cancelCurrentDownload];
    self.connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:audioURL] delegate:self];
    if (connection)
    {
        self.audioData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [audioData appendData:data];
    if (audioData.length > kMaxAudioFileBytes)
    {
        [self cancelCurrentDownload];
        [self call:@"_onErrorCallback" args:nil];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    [self call:@"_onSuccessCallback" args:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.audioData = nil;
    [self call:@"_onErrorCallback" args:nil];
}

#pragma mark Public Methods

- (void)load:(NSArray *)arguments options:(NSDictionary *)options
{
    NSURL *audioURL = nil;
    if ([options objectForKey:@"url"])
    {
        audioURL = [NSURL URLWithString:[options objectForKey:@"url"]
                          relativeToURL:delegate.webView.request.URL];
    }

    if (player)
    {
        if ([player.url isEqual:audioURL])
        {
            [player play];
            [self call:@"_onPlayingStateChange" args:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil]];
            return;
        }
        else
        {
            [self stop:nil options:nil];
        }
    }

    if (!audioURL)
    {
        return;
    }

    [self downloadAudioData:audioURL];
}

- (void)play:(NSArray *)arguments options:(NSDictionary *)options
{
    NSInteger numberOfLoops = 0;
    if (arguments.count >= 1)
    {
        numberOfLoops = [[arguments objectAtIndex:0] intValue];
    }

    if (!player)
    {
        if (!audioData)
        {
            return;
        }

        self.player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        self.audioData = nil;
        player.delegate = self;
    }

    player.numberOfLoops = numberOfLoops;
    if ([player play])
    {
        [self call:@"_onPlayingStateChange" args:[NSArray arrayWithObjects:[NSNumber numberWithBool:YES], nil]];
    }
}

- (void)pause:(NSArray *)arguments options:(NSDictionary *)options
{
    [player pause];
}

- (void)stop:(NSArray *)arguments options:(NSDictionary *)options
{
    if (player)
    {
        [player stop];
        player.delegate = nil;
        self.player = nil;
    }
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self call:@"_onPlayingStateChange" args:[NSArray arrayWithObjects:[NSNumber numberWithBool:NO], nil]];
}

#pragma mark SDAdvancedWebViewPlugin

- (void)cleanup
{
    [self stop:nil options:nil];
}

#pragma mark NSObject

- (void)dealloc
{
    [self stop:nil options:nil];
    [connection release], connection = nil;
    [audioData release], audioData = nil;
    [super dealloc];
}


@end
