//
//  SDAWVPluginOrientation.h
//  Dailymotion
//
//  Created by Olivier Poitrey on 10/06/10.
//  Copyright 2010 Dailymotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDAdvancedWebViewPlugin.h"

typedef enum
{
    SDAWVContentOrientationUnknown            = 0,
    SDAWVContentOrientationPortrait           = UIInterfaceOrientationPortrait,
    SDAWVContentOrientationPortraitUpsideDown = UIInterfaceOrientationPortraitUpsideDown,
    SDAWVContentOrientationLandscapeLeft      = UIInterfaceOrientationLandscapeLeft,
    SDAWVContentOrientationLandscapeRight     = UIInterfaceOrientationLandscapeRight
} SDAWVContentOrientation;

@interface SDAWVPluginOrientation : SDAdvancedWebViewPlugin
{
    SDAWVContentOrientation forcedContentOrientation;
}

- (void)setContentOrientation:(NSArray *)arguments options:(NSDictionary *)options;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)notifyCurrentOrientation;

@end
