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
    BOOL _seeking;

    BOOL _loggedIn;

    double _currentDuration;
    double _currentPosition;

    BOOL _observingPlayer;
    id _positionObserver;
    id _levelObserver;
}

@end

@implementation ViewController

@synthesize loginButton = _loginButton;
@synthesize playPauseButton = _playPauseButton;

@synthesize seekSlider = _seekSlider;
@synthesize positionLabel = _positionLabel;
@synthesize durationLabel = _durationLabel;

@synthesize leftAudioLevelSlider = _leftAudioLevelSlider;
@synthesize rightAudioLevelSlider = _rightAudioLevelSlider;

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    _rdio = [AppDelegate sharedRdio];
    [_rdio setDelegate:self];

    _player = [_rdio preparePlayerWithDelegate:self];

    [_positionLabel setText:@""];
    [_durationLabel setText:@""];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (_playing) {
        [self startObservers];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self stopObservers];
}


#pragma mark - Rdio Login control
- (IBAction)loginTapped:(id)sender
{
    NSLog(@"Login button tapped");

    if (_loggedIn) {
        [_rdio logout];
    } else {
        [_rdio authorizeFromController:self];
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


#pragma mark - Playback controls
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

- (IBAction)nextButtonTapped:(id)sender
{
    if (_playing) {
        [_player next];
    }
}

- (IBAction)previousButtonTapped:(id)sender
{
    // The `previous` method automatically goes to the previous track,
    // so to make this more like a "normal" music player, check the current
    // position, and restart the current track if it's not near the beginning.

    if (_playing) {
        if (_player.position > 3.0) {
            [_player seekToPosition:0.0];
        } else {
            [_player previous];
        }
    }

}

- (IBAction)stopButtonTapped:(id)sender
{
    if (_playing) {
        [_player stop];
    }
}

#pragma mark - KVO & Block observation
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([_player isEqual:object]) {  // should always be true
        if ([@"currentTrack" isEqualToString:keyPath]) {

            __block NSString *trackKey = [change valueForKey:NSKeyValueChangeNewKey];

            if (trackKey && [trackKey isKindOfClass:[NSString class]]) {

                NSDictionary *currentSourceInfo = _player.currentSource;
                NSString *sourceType = [currentSourceInfo objectForKey:@"type"];
                NSDictionary *currentTrackInfo;
                if ([@"t" isEqualToString:sourceType]) {
                    currentTrackInfo = currentSourceInfo;
                } else {
                    NSArray *tracksArray = [currentSourceInfo objectForKey:@"tracks"];
                    if (tracksArray) {
                        // tracksArray should exist, but if it doesn't, fail gracefully instead of crashing
                        currentTrackInfo = [tracksArray objectAtIndex:_player.currentTrackIndex];
                    }
                }

                //_artistLabel

            } else {
                //[_trackLabel setText:@""];
                //[_artistLabel setText:@""];
            }
        } else if ([@"duration" isEqualToString:keyPath]) {
            NSNumber *duration = [change valueForKey:NSKeyValueChangeNewKey];
            _currentDuration = [duration doubleValue];
            _durationLabel.text = [self formattedTimeForInterval:_currentDuration];
        }
    }
}

- (void)startObservers
{
    if (!_observingPlayer) {
        _observingPlayer = YES;

        [_player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
        [_player addObserver:self forKeyPath:@"currentTrack" options:NSKeyValueObservingOptionNew context:nil];

        __weak __typeof(self)weakSelf = self;
        if (!_positionObserver) {
            _positionObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 100)
                                                                      queue:dispatch_get_main_queue()
                                                                 usingBlock:^(CMTime time) {
                                                                     __strong __typeof(weakSelf)strongSelf = weakSelf;
                                                                     Float64 seconds = CMTimeGetSeconds(time);
                                                                     if (!isnan(seconds) && !isinf(seconds)) {
                                                                         [strongSelf positionUpdated:seconds];
                                                                     }
                                                                 }];
        }

        if (!_levelObserver) {
            _levelObserver = [_player addPeriodicLevelObserverForInterval:CMTimeMake(1, 100)
                                                                    queue:dispatch_get_main_queue()
                                                               usingBlock:^(Float32 left, Float32 right) {
                                                                   __strong __typeof(weakSelf)strongSelf = weakSelf;
                                                                   [strongSelf setMonitorValuesForLeft:left andRight:right];
                                                               }];
        }
    }

}

- (void)stopObservers
{
    if (_observingPlayer) {
        [_player removeObserver:self forKeyPath:@"duration"];
        [_player removeObserver:self forKeyPath:@"currentTrack"];

        if (_positionObserver) {
            [_player removeTimeObserver:_positionObserver];
            _positionObserver = nil;
        }

        if (_levelObserver) {
            [_player removeLevelObserver:_levelObserver];
            _levelObserver = nil;
        }

        _observingPlayer = NO;
    }
}


#pragma mark - Playback UI
- (NSString *)formattedTimeForInterval:(NSTimeInterval)interval
{
    NSInteger min = (NSInteger) interval / 60;
    NSInteger sec = (NSInteger) interval % 60;

    return [NSString stringWithFormat:@"%d:%02d", (int)min, (int)sec];
}

- (void)positionUpdated:(Float64)seconds
{
    if (!_seeking) {
        _positionLabel.text = [self formattedTimeForInterval:seconds];
        _seekSlider.value = seconds / _currentDuration;
    }
}

- (void)setMonitorValuesForLeft:(Float32)left andRight:(Float32)right
{
    // Playback levels come in as a linear signal between 0.0 and 1.0
    // this math converts it to a logarithmic (decibel) scale.
    double leftLinear = pow(10, (0.05 * left));
    double rightLinear = pow(10, (0.05 * right));

    _leftAudioLevelSlider.value = leftLinear;
    _rightAudioLevelSlider.value = rightLinear;
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
        [self stopObservers];
    } else {
        [_playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [self startObservers];
    }
}




@end
