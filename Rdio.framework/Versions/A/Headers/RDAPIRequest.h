/**
 *  @file RDAPIRequest.h
 *  Rdio Web Service API Requests
 *  Copyright 2011-2013 Rdio Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////

@class RD_OAConsumer;
@class RD_OAToken;

/**
 * A request to the Rdio Web Service API. See Rdio::callAPIMethod:withParameters:delegate:
 */
@interface RDAPIRequest : NSObject {
  void (^success_)(id result);
  void (^failure_)(NSError *error);
  BOOL expectJSON_;
  NSDictionary *params_;
  NSURL *url_;
  RD_OAConsumer *consumer_;
  RD_OAToken *token_;
  int numRetries_;
}

/**
 * Cancels the Rdio API request
 */
 - (void)cancel;

/**
 * The parameter dictionary passed to the request. Includes a "method" value
 * indicating which web service API was called. Note that all keys and values
 * in the `parameters` dictionary will be instances of NSString.
 *
 * For example, if you make an API call with the `count` parameter set to 20, `[parameters objectForKey:@"count"]`
 * would return `@"20"`, not `@20`.
 */
@property (nonatomic, readonly) NSDictionary *parameters;
@end

////////////////////////////////////////////////////////////////////////////////
