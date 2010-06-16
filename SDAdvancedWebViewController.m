//
//  SDAdvancedWebViewController.m
//  SDAdvancedWebView
//
//  Created by Olivier Poitrey on 07/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import "SDAdvancedWebViewController.h"
#import "SDAdvancedWebViewCommand.h"
#import "SDAdvancedWebViewPlugin.h"

// Plugins
#import "SDAWVPluginAccelerometer.h"
#import "SDAWVPluginOrientation.h"
#import "SDAWVPluginShake.h"
#import "SDAWVPluginAudio.h"

@interface SDAdvancedWebViewController ()
@property (nonatomic, retain) NSMutableDictionary *loadedPlugins;
@property (nonatomic, retain) NSURL *invokeURL;
@end

@implementation SDAdvancedWebViewController
@synthesize delegate, webViewDelegate, loadedPlugins, invokeURL;
@dynamic webView;

#pragma mark Public Methods

- (SDAdvancedWebViewPlugin *)pluginWithName:(NSString *)pluginName load:(BOOL)load
{
    SDAdvancedWebViewPlugin *plugin = [loadedPlugins objectForKey:pluginName];
    if (!plugin && load)
    {
        Class pluginClass = NSClassFromString([NSString stringWithFormat:@"SDAWVPlugin%@", pluginName]);
        plugin = [[pluginClass alloc] init];
        plugin.delegate = self;
        if (!loadedPlugins)
        {
            self.loadedPlugins = [NSMutableDictionary dictionary];
        }
        [loadedPlugins setObject:plugin forKey:pluginName];
        [plugin release];
    }
    return plugin;
}

#pragma mark SDAdvancedWebViewController (accessors)

- (UIWebView *)webView
{
    if (!webView && ![self isViewLoaded])
    {
        // force the loading of the view in order to generate the webview
        [self view];
    }
    return [[webView retain] autorelease];
}

- (void)setWebView:(UIWebView *)newWebView
{
    if (webView != newWebView)
    {
        if (newWebView)
        {
            if (!newWebView.delegate)
            {
                newWebView.delegate = self;
            }

            if (!newWebView.superview)
            {
                newWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                newWebView.frame = self.view.bounds;
                [self.view addSubview:newWebView];
            }
        }
        else
        {
            if (webView.delegate == self)
            {
                webView.delegate = nil; // Prevents BAD_EXEC if self is released before webView
            }

            // Force release loaded page elements by loading about:blank special page
            // (iPad have a bug with media player continuing playback even once webview is released)
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        }

        [webView release];
        webView = [newWebView retain];
    }
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!webView)
    {
        self.webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    SDAWVPluginOrientation *orientationPlugin = (SDAWVPluginOrientation *)[self pluginWithName:@"Orientation" load:NO];
    if (orientationPlugin)
    {
        return [orientationPlugin shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
    else
    {
        // Web content not loaded yet, applying some defaults
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            // On iPhone, upside down orientation is not advised
            return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
        }
        else
        {
            // On iPad, all orientations are allowed by default (until web content says something else)
            return YES;
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [(SDAWVPluginOrientation *)[self pluginWithName:@"Orientation" load:NO] notifyCurrentOrientation];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    if ([webViewDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [webViewDelegate webViewDidStartLoad:aWebView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    NSMutableString *script = [NSMutableString string];

    // Load communication center code
    NSString *comcenterPath = [[NSBundle mainBundle] pathForResource:@"SDAdvancedWebViewCommunicationCenter" ofType:@"js"];
    [script appendString:[NSString stringWithContentsOfFile:comcenterPath encoding:NSUTF8StringEncoding error:nil]];

    // Send device information
    UIDevice *device = [UIDevice currentDevice];
    [script appendFormat:@"DeviceInfo = {\"platform\": \"%@\", \"version\": \"%@\", \"uuid\": \"%@\", \"name\": \"%@\"};",
     device.model, device.systemVersion, device.uniqueIdentifier, device.name];

    [aWebView stringByEvaluatingJavaScriptFromString:script];

    // Cleanup the loaded plugins, each pages have to be isolated
    if (loadedPlugins)
    {
        [loadedPlugins.allValues makeObjectsPerformSelector:@selector(cleanup)];
    }

    // Init plugins for the view
    [SDAWVPluginAccelerometer installPluginForWebview:aWebView];
    [SDAWVPluginOrientation installPluginForWebview:aWebView];
    [SDAWVPluginShake installPluginForWebview:aWebView];
    [SDAWVPluginAudio installPluginForWebview:aWebView];

    // Inject the current orientation into the webview
    [(SDAWVPluginOrientation *)[self pluginWithName:@"Orientation" load:YES] notifyCurrentOrientation];

    if ([webViewDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [webViewDelegate webViewDidFinishLoad:aWebView];
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    if ([webViewDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [webViewDelegate webView:aWebView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;

    if ([url.scheme isEqualToString:@"comcenter"])
    {
		// Tell the JS code that we've gotten this command, and we're ready for another
        [aWebView stringByEvaluatingJavaScriptFromString:@"navigator.comcenter.queue.ready = true;"];

        // Try to execute the command
        SDAdvancedWebViewCommand *command = [[SDAdvancedWebViewCommand alloc] initWithURL:url];
        SDAdvancedWebViewPlugin *plugin = [self pluginWithName:command.pluginName load:YES];
        if ([plugin respondsToSelector:command.pluginSelector])
        {
            #if DEBUG==1
            NSLog(@"JS->ObjC command: %@", command);
            #endif
            [plugin performSelector:command.pluginSelector withObject:command.arguments withObject:command.options];
        }
        else
        {
            NSLog(@"Invalid command: %@", command);
        }

        [command release];

        return NO;
    }

    if ([webViewDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        if (![webViewDelegate webView:aWebView shouldStartLoadWithRequest:request navigationType:navigationType])
        {
            return NO;
        }
    }

    // Handles special URLs like URLs to AppStore or other kinds of schemes like tel: appname: etc...
    // The user is asked if he accept to leave the app in order to open those external resources
    if ((![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"] && ![url.scheme isEqualToString:@"about"])
        || [url.host isEqualToString:@"phobos.apple.com"]
        || [url.host isEqualToString:@"itunes.apple.com"]
        || [url.host isEqualToString:@"maps.google.com"])
    {
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            NSString *targetName;
            if ([url.host isEqualToString:@"phobos.apple.com"] || [url.host isEqualToString:@"itunes.apple.com"])
            {
                if (([url.path rangeOfString:@"/app/"]).location == NSNotFound)
                {
                    targetName = @"iTunes";
                }
                else
                {
                    targetName = @"App Store";
                }
            }
            else if ([url.host isEqualToString:@"maps.google.com"])
            {
                targetName = NSLocalizedString(@"Maps", @"Do you want to open <the iPhone application name for Maps>");
            }
            else if ([url.scheme isEqualToString:@"mailto"])
            {
                targetName = NSLocalizedString(@"Mail", @"Do you want to open <the iPhone application name for Mail>");
            }
            else if ([url.scheme isEqualToString:@"sms"])
            {
                targetName = NSLocalizedString(@"Text", @"Do you want to open <the iPhone application name for Text>");
            }
            else
            {
                targetName = NSLocalizedString(@"another application", @"Do you want to open <another application>");
            }

            self.invokeURL = url;
            [[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"You are about to leave %@", nil),
                                                  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"]]
                                         message:[NSString stringWithFormat:NSLocalizedString(@"Do you want to open %@?", nil), targetName]
                                        delegate:self
                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                               otherButtonTitles:NSLocalizedString(@"Open", nil), nil] autorelease] show];
        }
        return NO;
    }

    return YES;
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= alertView.firstOtherButtonIndex)
    {
        [[UIApplication sharedApplication] openURL:invokeURL];

        if ([delegate respondsToSelector:@selector(advancedWebViewController:didOpenExternalUrl:)])
        {
            [delegate performSelector:@selector(advancedWebViewController:didOpenExternalUrl:) withObject:self withObject:invokeURL];
        }
    }
    else if (buttonIndex == alertView.cancelButtonIndex)
    {
        if ([delegate respondsToSelector:@selector(advancedWebViewController:didCancelExternalUrl:)])
        {
            [delegate performSelector:@selector(advancedWebViewController:didCancelExternalUrl:) withObject:self withObject:invokeURL];
        }
    }

    self.invokeURL = nil;
}

#pragma mark NSObject

- (void)dealloc
{
    self.webView = nil;
    [loadedPlugins.allValues makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
    [loadedPlugins release], loadedPlugins = nil;
    [invokeURL release], invokeURL = nil;
    [super dealloc];
}

@end
