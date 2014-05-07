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
    double _currentTrackDuration;
}

@end

@implementation HelloViewController

- (RDPlayer *)player {
    if (_player == nil) {
        Rdio *sharedRdio = [HelloAppDelegate rdioInstance];
        if (sharedRdio.player == nil) {
            [sharedRdio initPlayerWithDelegate:self];
        }
        _player = sharedRdio.player;
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
    CGRect playFrame = CGRectMake(105, 20, 110, 40);
    [_playButton setFrame:playFrame];
    [_playButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_playButton];
    [_playButton release];

    // Login button
    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    CGRect loginFrame = CGRectMake(20, 70, appFrame.size.width - 40, 40);
    [_loginButton setFrame:loginFrame];
    [_loginButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_loginButton];
    [_loginButton release];

    // Powered by Rdio label
    CGRect labelFrame = CGRectMake(20, 110, appFrame.size.width - 40, 40);
    UILabel *rdioLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [rdioLabel setText:@"Powered by Rdio®"];
    [rdioLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [rdioLabel setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:rdioLabel];
    [rdioLabel release];

    // Previous track button
    UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [prevButton setTitle:@"Prev" forState:UIControlStateNormal];
    CGRect prevFrame = CGRectMake(20, 20, 77, 40);
    [prevButton setFrame:prevFrame];
    [prevButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [prevButton addTarget:self action:@selector(previousClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:prevButton];
    [prevButton release];

    // Next track button
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    CGRect nextFrame = CGRectMake(223, 20, 77, 40);
    [nextButton setFrame:nextFrame];
    [nextButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [nextButton addTarget:self action:@selector(nextClicked) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:nextButton];
    [nextButton release];

    // Left level label
    CGRect leftLevelLabelFrame = CGRectMake(20, 151, 15, 21);
    UILabel *leftLevelLabel = [[UILabel alloc] initWithFrame:leftLevelLabelFrame];
    [leftLevelLabel setText:@"L"];
    [view addSubview:leftLevelLabel];
    [leftLevelLabel release];

    // Left level
    CGRect leftSliderFrame = CGRectMake(65, 151, 191, 28);
    _leftLevelMonitor = [[UISlider alloc] initWithFrame:leftSliderFrame];
    [_leftLevelMonitor setValue:0.0];
    [view addSubview:_leftLevelMonitor];
    [_leftLevelMonitor release];

    // Right level label
    CGRect rightLevelLabelFrame = CGRectMake(20, 191, 15, 21);
    UILabel *rightLevelLabel = [[UILabel alloc] initWithFrame:rightLevelLabelFrame];
    [rightLevelLabel setText:@"R"];
    [view addSubview:rightLevelLabel];
    [rightLevelLabel release];

    // Right level
    CGRect rightSliderFrame = CGRectMake(65, 191, 191, 28);
    _rightLevelMonitor = [[UISlider alloc] initWithFrame:rightSliderFrame];
    [_rightLevelMonitor setValue:0.0];
    [view addSubview:_rightLevelMonitor];
    [_rightLevelMonitor release];

    // Current artist label
    CGRect currentArtistFrame = CGRectMake(20, 258, 280, 25);
    _currentArtistLabel = [[UILabel alloc] initWithFrame:currentArtistFrame];
    [view addSubview:_currentArtistLabel];
    [_currentArtistLabel release];

    // Current track title
    CGRect currentTrackFrame = CGRectMake(20, 316, 280, 25);
    _currentTrackLabel = [[UILabel alloc] initWithFrame:currentTrackFrame];
    [view addSubview:_currentTrackLabel];
    [_currentTrackLabel release];

    // Position label
    CGRect posLabelFrame = CGRectMake(20, 287, 37, 21);
    _positionLabel = [[UILabel alloc] initWithFrame:posLabelFrame];
    [view addSubview:_positionLabel];
    [_positionLabel release];

    // Duration label
    CGRect durLabelFrame = CGRectMake(264, 287, 37, 21);
    _durationLabel = [[UILabel alloc] initWithFrame:durLabelFrame];
    [view addSubview:_durationLabel];
    [_durationLabel release];

    // Position slider
    CGRect posSliderFrame = CGRectMake(65, 287, 191, 28);
    _positionSlider = [[UISlider alloc] initWithFrame:posSliderFrame];
    [_positionSlider addTarget:self action:@selector(seekStarted) forControlEvents:UIControlEventTouchDown];
    [_positionSlider addTarget:self action:@selector(seekFinished) forControlEvents:UIControlEventTouchUpInside];
    [_positionSlider addTarget:self action:@selector(seekFinished) forControlEvents:UIControlEventTouchUpOutside];
    [view addSubview:_positionSlider];
    [_positionSlider release];

    Rdio *sharedRdio = [HelloAppDelegate rdioInstance];
    sharedRdio.delegate = self;

    self.view = view;
    [view release];
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
        _positionSlider.value = seconds / _currentTrackDuration;
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
            _currentTrackDuration = [duration doubleValue];
            _durationLabel.text = [self formattedTimeForInterval:_currentTrackDuration];
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
        [self.player playSources:keys];
        [self startObservers];
    } else {
        [self.player togglePause];
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

    NSTimeInterval position = _positionSlider.value * _currentTrackDuration;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.player seekToPosition:position];
    });
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
