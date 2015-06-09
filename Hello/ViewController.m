//
//  ViewController.m
//  Hello
//
//  Created by Kevin Nelson on 6/9/15.
//  Copyright (c) 2015 Rdio. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"

@interface ViewController () {
    Rdio *_rdio;
    RDPlayer *_player;

    BOOL _playing;
    BOOL _paused;
    BOOL _loggedIn;
}

@end

@implementation ViewController

@synthesize loginButton = _loginButton;
@synthesize playPauseButton = _playPauseButton;

- (void)viewDidLoad {
    [super viewDidLoad];

    _rdio = [AppDelegate sharedRdio];
    [_rdio setDelegate:self];

    _player = [_rdio preparePlayerWithDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginTapped:(id)sender
{
    NSLog(@"Login button tapped");

    if (_loggedIn) {
        [_rdio logout];
    } else {
        [_rdio authorizeFromController:self];
    }
}

- (IBAction)playPauseTapped:(id)sender
{
    NSLog(@"Play/pause button tapped!");
    if (!_playing) {
        // Nothing's been "played" yet, so queue up and play something
        NSArray *keys = [@"t15907959,t1992210,t7418766,t8816323" componentsSeparatedByString:@","];
        [_player.queue add:keys];
        [_player playFromQueue:0];
    } else {
        // Otherwise, just toggle play/pause
        [_player togglePause];
    }
}

- (void)setLoggedIn:(BOOL)loggedIn
{
    _loggedIn = loggedIn;

    NSString *buttonTitle;
    if (_loggedIn) {
        buttonTitle = @"Disconnect Rdio";
    } else {
        buttonTitle = @"Connect to Rdio";
    }
    [_loginButton setTitle:buttonTitle forState:UIControlStateNormal];

    // Re-initialize the player on login changes
    _player = [_rdio preparePlayerWithDelegate:self];
}


#pragma mark - RdioDelegate
- (void)rdioDidAuthorizeUser:(NSDictionary *)user
{
    NSLog(@"authorized user %@", user);
    [self setLoggedIn:YES];
}

- (void)rdioAuthorizationFailed:(NSError *)error
{
    NSLog(@"authorization failed: %@", error);
    [self setLoggedIn:NO];
}

- (void)rdioAuthorizationCancelled
{
    NSLog(@"The user cancelled authorization");
    [self setLoggedIn:NO];
}

-(void)rdioDidLogout
{
    NSLog(@"Logged out");
    [self setLoggedIn:NO];
}


#pragma mark - RDPlayerDelegate
-(BOOL)rdioIsPlayingElsewhere
{
    return NO;
}

-(void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState
{
    NSLog(@"Rdio Player changed from state %u to state %u", oldState, newState);

    // Your internal state machine logic may differ, but for the sake of simplicity,
    // this Hello app considers Playing, Paused, and Buffering all as "playing" states.
    _playing = (newState != RDPlayerStateInitializing && newState != RDPlayerStateStopped);
    _paused = (newState == RDPlayerStatePaused);

    if (_paused || !_playing) {
        [_playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        [_playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}




@end
