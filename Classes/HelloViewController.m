#import "HelloViewController.h"
#import "HelloAppDelegate.h"

@interface HelloViewController() {
    UIButton *_playButton;
    UIButton *_loginButton;
    BOOL _loggedIn;
    BOOL _playing;
    BOOL _paused;
    RDPlayer* _player;
}

@end

@implementation HelloViewController

@synthesize player;

#pragma mark - View Lifecycle
- (void)loadView
{
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    [view setBackgroundColor:[UIColor whiteColor]];

    // Play Button
    _playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    CGRect playFrame = CGRectMake(20, 20, appFrame.size.width - 40, 40);
    [_playButton setFrame:playFrame];
    [_playButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_playButton addTarget:self action:@selector(playClicked) forControlEvents:UIControlEventTouchUpInside];

    _loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    CGRect loginFrame = CGRectMake(20, 70, appFrame.size.width - 40, 40);
    [_loginButton setFrame:loginFrame];
    [_loginButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];

    CGRect labelFrame = CGRectMake(20, 120, appFrame.size.width - 40, 40);
    UILabel *rdioLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [rdioLabel setText:@"Powered by Rdio®"];
    [rdioLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [rdioLabel setTextAlignment:NSTextAlignmentCenter];

    [view addSubview:_playButton];
    [view addSubview:_loginButton];
    [view addSubview:rdioLabel];

    [rdioLabel release];

    self.view = view;
    [view release];
}

- (void)dealloc
{
    [_playButton release];
    [_loginButton release];

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    Rdio *sharedRdio = [HelloAppDelegate rdioInstance];
    sharedRdio.delegate = self;
    sharedRdio.player.delegate = self;
}

#pragma mark - Rdio Helper

- (RDPlayer*)getPlayer
{
  if (_player == nil) {
    _player = [HelloAppDelegate rdioInstance].player;
  }
  return _player;
}

#pragma mark - UI event and state handling

- (void)playClicked
{
    if (!_playing) {
        NSArray* keys = [@"t2742133,t1992210,t7418766,t8816323" componentsSeparatedByString:@","];
        [[self getPlayer] playSources:keys];
    } else {
        [[self getPlayer] togglePause];
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


#pragma mark - RdioDelegate

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken
{
    [self setLoggedIn:YES];
}

- (void)rdioAuthorizationFailed:(NSString *)error
{
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

@end
