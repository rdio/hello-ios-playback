#import <UIKit/UIKit.h>
#import "Rdio/Rdio.h"

@interface HelloViewController : UIViewController<RdioDelegate,RDPlayerDelegate>

@property (readonly, nonatomic, weak) RDPlayer *player;

@end