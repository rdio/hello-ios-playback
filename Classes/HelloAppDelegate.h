//
//  HelloAppDelegate.h
//  Hello
//
//  Created by Ian McKellar on 8/19/11.
//  Copyright 2011 Rdio Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>
#import "HelloViewController.h"

@interface HelloAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	HelloViewController *viewController;
	
	Rdio *rdio;
}

+(Rdio *)rdioInstance;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HelloViewController *viewController;

@property (readonly) Rdio *rdio;

@end

