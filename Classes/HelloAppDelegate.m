//
//  HelloAppDelegate.m
//  Hello
//
//  Created by Ian McKellar on 8/19/11.
//  Copyright 2011 Rdio Inc. All rights reserved.
//

#import "HelloAppDelegate.h"
#import "ConsumerCredentials.h"

@implementation HelloAppDelegate

@synthesize window, viewController, rdio;

+(Rdio *)rdioInstance
{
	return [(id)[[UIApplication sharedApplication] delegate] rdio];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	rdio = [[Rdio alloc] initWithConsumerKey:CONSUMER_KEY andSecret:CONSUMER_SECRET delegate:viewController];
	[[rdio player] setDelegate:viewController];
	
	// Add the view controller's view to the window and display.
	[self.window addSubview:viewController.view];
	[self.window makeKeyAndVisible];
	
	NSLog(@"app launched, rdio=%@, player=%@", rdio, rdio.player);
    
    return YES;
}




- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
