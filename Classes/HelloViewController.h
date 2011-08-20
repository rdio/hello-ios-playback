#import <UIKit/UIKit.h>
#import "Rdio/Rdio.h"

@interface HelloViewController : UIViewController<RdioDelegate,RDPlayerDelegate> {
	UIButton *playButton;
	UIButton *loginButton;	
}

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

- (IBAction) playClicked:(id) button;
- (IBAction) loginClicked:(id) button;

@end
