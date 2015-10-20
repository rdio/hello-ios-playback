//
//  RDAdSupportedStationManager.h
//  Rdio
//
//  Created by Kevin Nelson on 2/17/15.
//
//

#import <Foundation/Foundation.h>

@interface RDStationManager : NSObject

/**
 * The original source that was converted into a station.
 */
@property (nonatomic, readonly) NSString *originalSourceKey;

/**
 * The resolved source key of the station.
 * This field is generated based on the `originalSource` passed in
 * to create the manager.
 */
@property (nonatomic, readonly) NSString *resolvedSourceKey;


/**
 * The number of skips left before you have to wait.
 */
@property (nonatomic, readonly) NSInteger skipsLeft;

#pragma mark - Product Access
/**
 * These fields are set by the `productAccess` dictionary on the
 * `currentUser` passed into the manager creation method.
 */

/**
 * Whether or not the user+product combo requires advertising to be played.
 */
@property (nonatomic, assign, readonly) BOOL requiresAds;

/**
 * Whether or not the stations generated must be DMCA-compliant.
 */
@property (nonatomic, assign, readonly) BOOL requiresDMCA;

/**
 * Whether or not the station manager should enforce skip limits
 */
@property (nonatomic, assign, readonly) BOOL limitSkips;

/**
 * The maximum bitrate allowed for this type of user.
 */
@property (nonatomic, assign, readonly) NSInteger maxBitrate;

@property (nonatomic, readonly) NSArray *stationTracks;

@end
