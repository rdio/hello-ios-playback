#import <UIKit/UIKit.h>
#import "Rdio/Rdio.h"

@interface HelloViewController : UIViewController<RdioDelegate,RDPlayerDelegate>

@property (retain) RDPlayer *player;

@end
