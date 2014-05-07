#import "HelloViewController.h"

#import <CoreMedia/CoreMedia.h>

#import "HelloAppDelegate.h"

#include "math.h"

@interface HelloViewController() {
    UIButton *_playButton;
    UIButton *_loginButton;
    BOOL _loggedIn;
    BOOL _playing;
    BOOL _paused;
    BOOL _seeking;
    RDPlayer* _player;

    UISlider *_leftLevelMonitor;
    UISlider *_rightLevelMonitor;

    UISlider *_positionSlider;
    UILabel *_positionLabel;
    UILabel *_durationLabel;

    UILabel *_currentTrackLabel;
    UILabel *_currentArtistLabel;

    id _timeObserver;
    id _levelObserver;
    double currentTrackDuration;
}


@end

@implementation HelloViewController

@synthesize player;

#pragma mark - Rdio Helper

- (RDPlayer*)getPlayer
{
  if (_player == nil) {
    _player = [HelloAppDelegate rdioInstance].player;
  }
  return _player;
}


#pragma mark - View Lifecycle
- (void)loadView
{
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    [view setBackgroundColor:[UIColor whiteColor]];

    // Play button
    _playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    CGRect playFrame = CGRectMake(20, 20, appFrame.size.width - 40, 40);
    [_playButton setFrame:playFrame];
    [_playButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];

    // Login button
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    CGRect loginFrame = CGRectMake(20, 70, appFrame.size.width - 40, 40);
    [_loginButton setFrame:loginFrame];
    [_loginButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];

    // Powered by Rdio label
    CGRect labelFrame = CGRectMake(20, 120, appFrame.size.width - 40, 40);
    UILabel *rdioLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [rdioLabel setText:@"Powered by Rdio®"];
    [rdioLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [rdioLabel setTextAlignment:NSTextAlignmentCenter];
  
  // Next track button
  
  // Previous track button
  
  // Left level
  
  // Right level
  
  // Current track title
  
  // Current artist
  
  // Position label
  
  // Duration label
  
  // Position slider
  

    [view addSubview:_playButton];
    [view addSubview:_loginButton];
    [view addSubview:rdioLabel];

    [_playButton release];
    [_loginButton release];

    [rdioLabel release];

    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    Rdio *sharedRdio = [HelloAppDelegate rdioInstance];
    sharedRdio.delegate = self;
    [sharedRdio initPlayerWithDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.player addObserver:self forKeyPath:@"currentTrack" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
    [self startObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.player removeObserver:self forKeyPath:@"currentTrack"];
    [self.player removeObserver:self forKeyPath:@"duration"];
    [self stopObservers];

    [super viewDidDisappear:animated];
}


#pragma mark - Screen Rotation
- (BOOL)shouldAutorotate
{
  return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskAll;
}

#pragma mark - Periodic observers
- (void)startObservers
{
    if (!_levelObserver) {
        _levelObserver = [[self.player addPeriodicLevelObserverForInterval:CMTimeMake(1, 100)
                                                                     queue:dispatch_get_main_queue()
                                                                usingBlock:^(Float32 left, Float32 right) {
                                                                    [self setMonitorValuesForLeft:left andRight:right];
                                                                }] retain];
    }

    if (!_timeObserver) {
        _timeObserver = [[self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 100)
                                                                   queue:dispatch_get_main_queue()
                                                              usingBlock:^(CMTime time) {
                                                                  Float64 seconds = CMTimeGetSeconds(time);
                                                                  if (!isnan(seconds) && !isinf(seconds)) {
                                                                      [self positionUpdated:seconds];
                                                                  }
                                                              }] retain];
    }
}

- (void)stopObservers
{
    if (_levelObserver) {
        [self.player removeLevelObserver:_levelObserver];
        [_levelObserver release];
        _levelObserver = nil;
    }

    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
        [_timeObserver release];
        _timeObserver = nil;
    }
}

#pragma mark - Observation Handlers
- (void)setMonitorValuesForLeft:(Float32)left andRight:(Float32)right
{
    double leftLinear = pow(10, (0.05 * left));
    double rightLinear = pow(10, (0.05 * right));

    _leftLevelMonitor.value = leftLinear;
    _rightLevelMonitor.value = rightLinear;
}

- (void)positionUpdated:(Float64)seconds
{
    if (!_seeking) {
        _positionLabel.text = [self formattedTimeForInterval:seconds];
        _positionSlider.value = seconds / currentTrackDuration;
    }
}

- (NSString *)formattedTimeForInterval:(NSTimeInterval)interval
{
    NSInteger min = (NSInteger) interval / 60;
    NSInteger sec = (NSInteger) interval % 60;

    return [NSString stringWithFormat:@"%d:%02d", min, sec];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self.player isEqual:object]) {  // should always be true
        if ([@"currentTrack" isEqualToString:keyPath]) {
            NSString *trackKey = [change valueForKey:NSKeyValueChangeNewKey];

            if (trackKey && [trackKey isKindOfClass:[NSString class]]) {
                RDAPIRequestDelegate *trackDelegate = [RDAPIRequestDelegate delegateToTarget:self
                                                                                loadedAction:@selector(updateCurrentTrackRequest:didLoadData:)
                                                                                failedAction:@selector(updateCurrentTrackRequest:didFail:)];
                [[HelloAppDelegate rdioInstance] callAPIMethod:@"get"
                                                withParameters:@{@"keys": trackKey, @"extras":@"-*,name,artist"}
                                                      delegate:trackDelegate];
            } else {
                [_currentTrackLabel setText:@""];
                [_currentArtistLabel setText:@""];
            }
        } else if ([@"duration" isEqualToString:keyPath]) {
            NSNumber *duration = [change valueForKey:NSKeyValueChangeNewKey];
            currentTrackDuration = [duration doubleValue];
            _durationLabel.text = [self formattedTimeForInterval:currentTrackDuration];
        }
    }
}

- (void)updateCurrentTrackRequest:(RDAPIRequest *)request didLoadData:(NSDictionary *)data
{
    NSString *trackKey = [request.parameters objectForKey:@"keys"];
    NSDictionary *metadata = [data objectForKey:trackKey];
    [_currentTrackLabel setText:[metadata objectForKey:@"name"]];
    [_currentArtistLabel setText:[metadata objectForKey:@"artist"]];
}

- (void)updateCurrentTrackRequest:(RDAPIRequest *)request didFail:(NSError *)error
{
    NSLog(@"error: %@", error);
}


#pragma mark - UI event and state handling

- (void)playClicked
{
    if (!_playing) {
        NSArray* keys = [@"t15907959,t1992210,t7418766,t8816323" componentsSeparatedByString:@","];
        [[self getPlayer] playSources:keys];
        [self startObservers];
    } else {
        [[self getPlayer] togglePause];
        [self stopObservers];
    }
}

- (void)loginClicked
{
    if (_loggedIn) {
        [[HelloAppDelegate rdioInstance] logout];
    } else {
        [[HelloAppDelegate rdioInstance] authorizeFromController:self];
    }
}

- (void)setLoggedIn:(BOOL)logged_in
{
    _loggedIn = logged_in;
    if (logged_in) {
        [_loginButton setTitle:@"Log Out" forState: UIControlStateNormal];
    } else {
        [_loginButton setTitle:@"Log In" forState: UIControlStateNormal];
    }
}

- (void)nextClicked
{
    [self.player next];
}

- (void)previousClicked
{
    [self.player previous];
}

- (void)seekStarted {
    if (!_playing) return;
    _seeking = YES;
}

- (IBAction)seekFinished {
    if (!_playing) return;

    _seeking = NO;

    NSTimeInterval position = _positionSlider.value * currentTrackDuration;
    [self.player seekToPosition:position];
}


#pragma mark - RdioDelegate

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken
{
    [self setLoggedIn:YES];
}

- (void)rdioAuthorizationFailed:(NSError *)error
{
    NSLog(@"Rdio authorization failed with error: %@", error);
    [self setLoggedIn:NO];
}

- (void)rdioAuthorizationCancelled
{
    [self setLoggedIn:NO];
}

- (void)rdioDidLogout
{
    [self setLoggedIn:NO];
}


#pragma mark - RDPlayerDelegate

- (BOOL)rdioIsPlayingElsewhere
{
    // let the Rdio framework tell the user.
    return NO;
}

- (void)rdioPlayerChangedFromState:(RDPlayerState)fromState toState:(RDPlayerState)state
{
    _playing = (state != RDPlayerStateInitializing && state != RDPlayerStateStopped);
    _paused = (state == RDPlayerStatePaused);
    if (_paused || !_playing) {
        [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        [_playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (BOOL)rdioPlayerFailedDuringTrack:(NSString *)trackKey withError:(NSError *)error
{
    NSLog(@"Rdio failed to play track %@\n%@", trackKey, error);
    return NO;
}

- (void)rdioPlayerQueueDidChange
{
    NSLog(@"Rdio queue changed to %@", [self.player trackKeys]);
}

@end
