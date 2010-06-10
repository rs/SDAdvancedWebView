//
//  SDAdvancedWebViewCommand.m
//  SDAdvancedWebView
//
//  Inspired from Shazron Abdullah's PhoneGap's InvokedUrlCommand class
//  Created by Olivier Poitrey on 10/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAdvancedWebViewCommand.h"

@implementation SDAdvancedWebViewCommand
@synthesize command, pluginClass, pluginSelector, arguments, options;

- (id)initWithURL:(NSURL *)url
{
    if ((self = [super init]))
    {
        self.command = url.host;

        NSString *path = [url.path substringFromIndex:1]; // remove the leading slash
        NSMutableArray *args = [NSMutableArray array];
        for (NSString *arg in [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]])
        {
            [args addObject:[arg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        self.arguments = args;

        NSMutableDictionary *opts = [NSMutableDictionary dictionary];
        for (NSString *component in [url.query componentsSeparatedByString:@"&"])
        {
            NSArray *key_value = [component componentsSeparatedByString:@"="];
            NSString *name = [(NSString *)[key_value objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSObject *value;
            if (key_value.count == 2)
            {
                value = [(NSString *)[key_value objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            else
            {
                value = [NSNull null];
            }
            [opts setObject:value forKey:name];
        }
        self.options = opts;

        NSArray* components = [url.host componentsSeparatedByString:@"."];
        if (components.count == 2)
        {
            self.pluginClass = NSClassFromString([NSString stringWithFormat:@"SDAWVPlugin%@", [components objectAtIndex:0]]);
            self.pluginSelector = NSSelectorFromString([NSString stringWithFormat:@"%@:options:", [components objectAtIndex:1]]);
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@(%@, %@)", command, [arguments componentsJoinedByString:@", "], options];
}

- (void)dealloc
{
    [command release], arguments = nil;
    [arguments release], arguments = nil;
    [options release], options = nil;
    [super dealloc];
}


@end
