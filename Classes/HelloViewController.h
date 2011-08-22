#import <UIKit/UIKit.h>
#import "Rdio/Rdio.h"

@interface HelloViewController : UIViewController<RdioDelegate,RDPlayerDelegate> {
    UIButton *playButton;
    UIButton *loginButton;
    BOOL loggedIn;
    BOOL playing;
    BOOL paused;
    RDPlayer* player;
}

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (retain) RDPlayer *player;

- (IBAction) playClicked:(id) button;
- (IBAction) loginClicked:(id) button;

@end
