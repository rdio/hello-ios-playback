//
//  HelloAppDelegate.m
//  Hello
//
//  Created by Ian McKellar on 8/19/11.
//  Copyright 2011 Rdio Inc. All rights reserved.
//

#import "HelloAppDelegate.h"
#import "ConsumerCredentials.h"

static HelloAppDelegate *launchedDelegate;

@implementation HelloAppDelegate

@synthesize window, viewController, rdio;

+ (Rdio *)rdioInstance
{
    return launchedDelegate.rdio;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    launchedDelegate = self;

    rdio = [[Rdio alloc] initWithConsumerKey:CONSUMER_KEY andSecret:CONSUMER_SECRET delegate:nil];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[HelloViewController alloc] init];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)dealloc
{
    if (launchedDelegate == self) {
        launchedDelegate = nil;
    }

    rdio.delegate = nil;
    rdio.player.delegate = nil;
}


@end
