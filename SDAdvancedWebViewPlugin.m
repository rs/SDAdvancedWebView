//
//  SDAdvancedWebViewPlugin.m
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 10/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAdvancedWebViewPlugin.h"

@implementation SDAdvancedWebViewPlugin
@synthesize delegate;

+ (void)installPluginForWebview:(UIWebView *)aWebView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:NSStringFromClass(self) ofType:@"js"];
    if (path)
    {
        NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        [aWebView stringByEvaluatingJavaScriptFromString:script];
    }
}

- (NSString *)call:(NSString *)methodName args:(NSArray *)arguments
{
    NSMutableArray *jsArguments = [NSMutableArray arrayWithCapacity:arguments.count];
    if (arguments)
    {
        for (id arg in arguments)
        {
            if ([arg isKindOfClass:NSString.class])
            {
                [jsArguments addObject:[NSString stringWithFormat:@"\"%@\"",
                                        [arg stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];
            }
            else if ([arg isKindOfClass:NSNumber.class])
            {
                [jsArguments addObject:[arg stringValue]];
            }
            else
            {
                [jsArguments addObject:@"null"];
            }
        }
    }

    NSString *pluginName = [[NSStringFromClass(self.class) stringByReplacingOccurrencesOfString:@"SDAWVPlugin" withString:@""] lowercaseString];
    NSString *script = [NSString stringWithFormat:@"SDAdvancedWebViewObjects.%@.%@(%@)", pluginName, methodName, [jsArguments componentsJoinedByString:@", "]];
    NSString *result = [delegate.webView stringByEvaluatingJavaScriptFromString:script];
    #if DEBUG==1
    NSLog(@"ObjC->JS method: %@ result: %@", script, result);
    #endif
    return result;
}

- (void)cleanup
{
}

- (void)dealloc
{
    [self cleanup];
    [super dealloc];
}


@end
