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
  RDErrorWebService
} RDErrorCode;
