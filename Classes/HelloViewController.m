#import "HelloViewController.h"
#import "HelloAppDelegate.h"

@implementation HelloViewController

@synthesize playButton, loginButton, player;

-(RDPlayer*)getPlayer
{
    if (player == nil) {
        player = [HelloAppDelegate rdioInstance].player;
    }
    return player;
}

#pragma mark -
#pragma mark UI event and state handling

- (IBAction) playClicked:(id) button {
    if (!playing) {
        [[self getPlayer] playSource:@"t2742133"];
    } else {
        [[self getPlayer] togglePause];
    }
}

- (IBAction) loginClicked:(id) button {
    if (loggedIn) {
        [[HelloAppDelegate rdioInstance] logout];
    } else {
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
    [self setLoggedIn:YES];
}

- (void) rdioAuthorizationFailed:(NSString *)error {
    [self setLoggedIn:NO];
}

- (void) rdioAuthorizationCancelled {
    [self setLoggedIn:NO];
}

- (void) rdioDidLogout {
    [self setLoggedIn:NO];
}


#pragma mark -
#pragma mark RDPlayerDelegate

- (BOOL) rdioIsPlayingElsewhere {
    // let the Rdio framework tell the user.
    return NO;
}

- (void) rdioPlayerChangedFromState:(RDPlayerState)fromState toState:(RDPlayerState)state {
    playing = (state != RDPlayerStateInitializing && state != RDPlayerStateStopped);
    paused = (state == RDPlayerStatePaused);
    if (paused || !playing) {
        [playButton setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

@end
