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
        [delegate.webView stringByEvaluatingJavaScriptFromString:@"SDAdvancedWebViewObjects.audio._onErrorCallback()"];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    [delegate.webView stringByEvaluatingJavaScriptFromString:@"SDAdvancedWebViewObjects.audio._onSuccessCallback()"];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.audioData = nil;
    [delegate.webView stringByEvaluatingJavaScriptFromString:@"SDAdvancedWebViewObjects.audio._onErrorCallback()"];
}

#pragma mark Public Methods

- (void)load:(NSArray *)arguments options:(NSDictionary *)options
{
    NSURL *audioURL = nil;
    if (arguments.count >= 1)
    {
        audioURL = [NSURL URLWithString:[arguments objectAtIndex:0]
                          relativeToURL:delegate.webView.request.URL];
    }

    if (player)
    {
        if ([player.url isEqual:audioURL])
        {
            [player play];
            [delegate.webView stringByEvaluatingJavaScriptFromString:@"SDAdvancedWebViewObjects.audio._onPlayingStateChange(true)"];
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
        [delegate.webView stringByEvaluatingJavaScriptFromString:@"SDAdvancedWebViewObjects.audio._onPlayingStateChange(true)"];
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
    [delegate.webView stringByEvaluatingJavaScriptFromString:@"SDAdvancedWebViewObjects.audio._onPlayingStateChange(false)"];
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
