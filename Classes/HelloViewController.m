#import "HelloViewController.h"
#import "HelloAppDelegate.h"

@implementation HelloViewController

@synthesize playButton, loginButton;


BOOL loggedIn;
BOOL playing;
BOOL paused;
RDPlayer* player;

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	player = [HelloAppDelegate rdioInstance].player;
}

#pragma mark -
#pragma mark UI event and state handling

- (IBAction) playClicked:(id) button {
	NSLog(@"play clicked");
	RDPlayer* player = [[HelloAppDelegate rdioInstance] player];
	if (!playing) {
		[player playSource:@"t2742133"];
	} else {
		[player togglePause];
	}
}

- (IBAction) loginClicked:(id) button {
	if (loggedIn) {
		NSLog(@"logout");
		[[HelloAppDelegate rdioInstance] logout];
	} else {
		NSLog(@"logging in");
		[[HelloAppDelegate rdioInstance] authorizeFromController:self];
	}
}

- (void) setLoggedIn:(BOOL)logged_in {
	loggedIn = logged_in;
	if (logged_in) {
		[loginButton setTitle:@"Log Out" forState: UIControlStateNormal];
	} else {
		[loginButton setTitle:@"Log In" forState: UIControlStateNormal];
	}
}


#pragma mark -
#pragma mark RdioDelegate

- (void) rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
	[self setLoggedIn:TRUE];
}

- (void) rdioAuthorizationFailed:(NSString *)error {
	[self setLoggedIn:FALSE];
}

- (void) rdioAuthorizationCancelled {
	[self setLoggedIn:FALSE];
}

- (void) rdioDidLogout {
	[self setLoggedIn:FALSE];
}


#pragma mark -
#pragma mark RDPlayerDelegate

- (BOOL) rdioIsPlayingElsewhere {
	// let the Rdio framework tell the user.
	return NO;
}

- (void) rdioPlayerChangedFromState:(RDPlayerState)fromState toState:(RDPlayerState)state {
	playing = (state != RDPlayerStateInitializing &&
			   state != RDPlayerStateStopped);
	paused = (state == RDPlayerStatePaused);
	if (paused || !playing) {
		[playButton setTitle:@"Play" forState:UIControlStateNormal];
	} else {
		[playButton setTitle:@"Pause" forState:UIControlStateNormal];
	}
}


@end
