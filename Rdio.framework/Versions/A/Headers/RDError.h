//
//  RDError.h
//  Rdio
//
//  Created by Kevin Nelson on 4/11/13.
//
//

#import <Foundation/Foundation.h>


////////////////////////////////////////////////////////////////////////////////

/**
 * Rdio Error Domain
 */
static NSString* const RDErrorDomain = @"RDErrorDomain";

/**
 * Rdio Error codes
 */
typedef enum {
  RDErrorUnknown,
  RDErrorNetwork,
  RDErrorPlayback,
  RDErrorAuth,
  RDErrorWebService,
  RDErrorAdSupportedLimitation
} RDErrorCode;



static NSString* const RDAdSupportedPlaybackErrorDomain = @"RDAdSupportedPlaybackErrorDomain";

/**
 * Rdio AdSupported Playback control errors
 */
typedef enum {
  RDAdSupportedPlaybackErrorSkipLimitReached, /**< An error caused by calling `next` without any skips left */
  RDAdSupportedPlaybackErrorRewind, /**< An error caused by calling `previous`, `playAndRestart:YES`, or seeking earlier within a track */
  RDAdSupportedPlaybackErrorSkipToIndex, /**< An error caused by calling `skipToIndex:` */
  RDAdSupportedPlaybackErrorAdvertisement, /**< An error caused by calling any playback control other than `togglePause` during ad playback */
} RDAdSupportedPlaybackErrorCode;
