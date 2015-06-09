//
//  AppDelegate.m
//  Hello
//
//  Created by Kevin Nelson on 6/9/15.
//  Copyright (c) 2015 Rdio. All rights reserved.
//

#import "AppDelegate.h"

#import "ClientCredentials.h"

@interface AppDelegate ()

@end

static Rdio * _rdioInstance;

@implementation AppDelegate

+ (Rdio *)sharedRdio
{
    if (_rdioInstance == nil) {
        _rdioInstance = [[Rdio alloc] initWithClientId:@""CLIENT_ID
                                             andSecret:@""CLIENT_SECRET
                                              delegate:nil];
    }
    return _rdioInstance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    Rdio *r = [AppDelegate sharedRdio]; // initialize Rdio on launch
    // even though it's not used here.

    return YES;
}

@end
