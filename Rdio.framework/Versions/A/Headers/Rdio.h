/**
 *  @file Rdio.h
 *  Rdio iOS SDK
 *  Copyright 2011-2013 Rdio Inc. All rights reserved.
 */

#import "RDPlayer.h"
#import "RDAPIRequest.h"
#import "RDError.h"
#import "RDPlayerQueue.h"
#import "RDStationManager.h"

@protocol RdioDelegate;
@class RDSession;
@class RDAuthViewController;

////////////////////////////////////////////////////////////////////////////////

/** @mainpage
 * The Rdio iOS SDK lets developers call the web service API, authenticate users,
 * and play full song streams or 30 second samples.
 * <br/><br/>
 * To get started:
 * <ul>
 *  <li>Visit http://www.rdio.com/developers/ to register a developer account and apply for a key</li>
 *  <li>Download the <a href="https://github.com/rdio/rdioquiz-ios">sample app</a></li>
 *  <li>Download the <a href="http://www.rdio.com/media/static/developer/ios/rdio-ios.tar.gz">framework</a></li>
 *  <li>Drag the Rdio framework into your XCode project</li>
 *  <li><b>Add the following frameworks to your project:</b>
 *    <ul>
 *      <li>CoreGraphics</li>
 *      <li>CFNetwork</li>
 *      <li>CoreMedia</li>
 *      <li>SystemConfiguration</li>
 *      <li>AudioToolbox</li>
 *      <li>Security</li>
 *    </ul>
 *  </li>
 *  <li><b>Add <a href="http://developer.apple.com/library/mac/#qa/qa1490/_index.html">-all_load</a> under Other Linker Flags in the project build info</b></li>
 *  <li>Add <a href="https://github.com/AFNetworking/AFNetworking">AFNetworking</a> and <a href="https://github.com/AFNetworking/AFOAuth2Manager">AFOAuth2Manager</a> to your project.  We recommend doing this with <a href="http://cocoapods.org/">CocoaPods</a>, but you should also be able to add the source files directly to your Xcode project.</li>
 *  <li>Try the following code in your app delegate:</li>
 * </ul>
 * \code
 *   #import <Rdio/Rdio.h>
 *   Rdio *rdio = [[Rdio alloc] initWithClientId:@"YOUR CLIENT_ID" andSecret:@"YOUR CLIENT_SECRET" delegate:nil];
 *   [rdio preparePlayerWithDelegate:nil];
 *   [rdio.player play:@"t2742133"];
 * \endcode
 *
 * Please direct feature requests and bug reports to
 * <a href="mailto:developersupport@rd.io">Developer Support</a>,
 * <a href="http://groups.google.com/group/rdio-api">Rdio API Google Group</a>, or
 * <a href="https://github.com/rdio/api/issues">Issue tracking on GitHub</a>.
 */

////////////////////////////////////////////////////////////////////////////////

/**
 * Façade for interacting with the Rdio API.
 * Supports server API calls and track playback for anonymous and authorized users.
 */
@interface Rdio : NSObject {
  RDPlayer *player_;
  RDSession *session_;
  RDAuthViewController *authViewController_;
  UINavigationController *authNavController_;
  UIViewController *currentController_;
  __unsafe_unretained id<RdioDelegate> delegate_;
  BOOL authorizingFromToken_;
}

/**
 * Initializes the Rdio API with your OAuth 1.0 consumer key and secret.
 * Visit http://www.rdio.com/developers/ to register and apply for a key.
 * @param key Your consumer key
 * @param secret Your secret
 * @param delegate Delegate for receiving state changes, or nil
 */
- (id)initWithConsumerKey:(NSString *)key andSecret:(NSString *)secret delegate:(id<RdioDelegate>)delegate;

/**
 * Initializes the Rdio API with your OAuth 2.0 client ID and client secret.
 * 
 * @param clientId Your OAuth 2.0 client ID
 * @param secret Your OAuth 2.0 client secret, or nil if you expect to obtain an access token from some other channel.
 * @param delegate Delegate for receiving state changes, or nil
 */
- (id)initWithClientId:(NSString *)clientId andSecret:(NSString *)clientSecret delegate:(id<RdioDelegate>)delegate;


/**
 * Fetches a playback token and initializes the Rdio player.
 * You'll need to call this method or prepareSharedPlaystatePlayerWithDelegate in order to play music.
 *
 * If initialized before authenticating a user, the player will play 30 second samples.
 * If initialized after, the player will play tracks according to the user's subscription.
 * Authenticating a user after the player has been initialized will automatically
 * reinitialize the player so that it plays all subsequent tracks according to the user's subscription.
 *
 * Note that the automatic re-initialization will not promote a currently-playing (or paused) 30 second
 * sample to a full track, nor will it automatically trigger re-buffering of the track.
 * If it's desirable for your application to automatically restart the currently-playing sample as a full
 * track, you should call `stop` and replay the track manually to ensure that the full version is played.
 * If you don't do this, full track playback will begin at the next track.
 *
 * The instance of RDPlayer returned by this method is also accessible via `rdio.player`.
 * @param delegate An object that implements the RDPlayerDelegate protocol, which will be set as the player's delegate.
 */
- (RDPlayer *)preparePlayerWithDelegate:(id<RDPlayerDelegate>)delegate;

/**
 * Fetches a playback token and initializes the Rdio player.
 * You'll need to call this method or preparePlayerWithDelegate in order to play music.
 * Using this method, the resulting player will respond to Rdio Remote Control events
 * and will share player state with other running instances of Rdio for the same authenticated user.
 *
 * If this method is called without an authenticated user, then the resulting player will be demoted to
 * an isolated player.  Due to the issues around interacting with a user's queue, the isolated player
 * will never automatically be promoted to share playstate upon login.
 *
 * To reiterate, in order to share playstate, you must explicitly call this method _after_ a user has
 * authenticated.
 *
 * If your app allows sample playback prior to authentication and also supports shared-playstate, we
 * recommend that you include the following calls in your `rdioDidAuthorizeUser:accessToken:` delegate
 * implementation:
 *
 * \code{.m}
 * Rdio *rdio = [YourRdioManager sharedRdioInstance];
 * [rdio.player stop];
 * [rdio.player.queue removeAll];
 * [rdio prepareSharedPlaystatePlayerWithDelegate:yourRdioDelegate];
 * \endcode
 *
 * As mentioned in the `removeAll` documentation, make sure that you call that method _before_ preparing
 * the shared-playstate player in order to clean up the local queue without wiping out the shared queue.
 *
 * The instance of RDPlayer returned by this method is also accessible via `rdio.player`.
 * @param delegate An object that implements the RDPlayerDelegate protocol, which will be set as the player's delegate.
 */
- (RDPlayer *)prepareSharedPlaystatePlayerWithDelegate:(id<RDPlayerDelegate>)delegate;

/**
 * Presents a modal login dialog to allow your end user to authenticate their Rdio account.
 * @param currentController Controller from which the login view should be launched
 */
- (void)authorizeFromController:(UIViewController *)currentController;

/**
 * Presents a modal login dialog to allow your end user to authenticate their Rdio account.  Your
 * authentication request will inclue the permissions covered by the `scope` parameter that you
 * pass in.
 * @param currentController Controller from which the login view should be launched
 * @param requestedScope The `scope` of access that you'd like to request through OAuth 2.0.  If you are using OAuth 1.0, this parameter is ignored and this method will behave the same way as `authorizeFromController:`.
 */
- (void)authorizeFromController:(UIViewController *)currentController scope:(NSString *)requestedScope;

/**
 * Presents a modal login dialog to allow your end user to authenticate their Rdio account.  Your
 * authentication request will inclue the permissions covered by the `scope` parameter that you
 * pass in.
 * @param currentController Controller from which the login view should be launched
 * @param requestedScope The `scope` of access that you'd like to request through OAuth 2.0.  If you are using OAuth 1.0, this parameter is ignored and this method will behave the same way as `authorizeFromController:`.
 * @param params A map of key/value pairs which will be appended to the OAuth 2.0 authorization URL
 */
- (void)authorizeFromController:(UIViewController *)currentController scope:(NSString *)requestedScope params:(NSDictionary *)withParams;

/**
 * Attempts to reauthorize using an access token from a previous session.
 * If this process fails, it calls the `rdioAuthorizationFailed:` method of the RdioDelegate passed to `initWithConsumerKey:`
 * (or passed to `initWithClientId:`, if you're using OAuth 2.0).
 * @param accessToken Either an NSString token received from a previous <code>rdioDidAuthorizeUser:withAccessToken:</code> delegate call, or an AFOAuthCredential including the relevant OAuth 2.0 access and refresh token information.
 */
- (void)authorizeUsingAccessToken:(id)accessToken;

/**
 * Logs out the current user.  Calls <code>rdioDidLogout</code> on delegate on completion.  Clients are responsible
 * for clearing any application-persisted state (user data, access token, etc).
 */
- (void)logout;

/**
 * Calls an Rdio Web Service API method with the given parameters.
 * @param method Name of the method to call. See http://www.rdio.com/developers/docs/web-service/methods/ for available methods.
 * @param params A dictionary of parameters as required for the method. Note that all keys and values in the `parameters` dictionary should be instances of NSString.
 * For example, if you're
 * passing the `count` parameter to an API call, you would use `@"count": @"20"`
 * instead of `@"count": @20`.
 * @param success A block object to be executed when the call completes successfully.  The callback block is passed the result of the API call as an NSDictionary, and doesn't return anything.
 * @param failure A block object to be executed with the call fails for one reason or another.  The callback block is passed an NSError argument that is created by the network stack for OAuth 1.0, or bubbled up from AFNetworking for OAuth 2.0.
 */
- (RDAPIRequest *)callAPIMethod:(NSString *)method
                 withParameters:(NSDictionary *)params
                        success:(void (^)(NSDictionary *result))success
                        failure:(void (^)(NSError *error))failure;

/**
 * Delegate used to receive Rdio API state changes.
 */
@property (nonatomic, unsafe_unretained) id<RdioDelegate> delegate;

/**
 * A dictionary describing the current user, or nil if no user is logged in.
 * See http://www.rdio.com/developers/docs/web-service/types/
 */
@property (nonatomic, readonly) NSDictionary *user;

/**
 * The Rdio player object.
 *
 * Note that the player will be nil until you call `preparePlayerWithDelegate:`.
 */
@property (nonatomic, readonly) RDPlayer *player;

@end

////////////////////////////////////////////////////////////////////////////////

/**
 * Delegate used to receive Rdio API state changes.
 */
@protocol RdioDelegate
@optional

/**
 * Called when an authorize request finishes successfully.
 * @param user A dictionary containing information about the user that was authorized. See http://www.rdio.com/developers/docs/web-service/types/
 * @param accessToken A token that can be used to automatically reauthorize the current user in subsequent sessions
 * @deprecated This method is only called when authenticating with an OAuth 1.0a client.  Authenticating with an OAuth 2.0 client will result in `rdioDidAuthorizeUser:` getting called instead.
 */
- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken;

/**
 * Called when an OAuth 2.0 authorization request finishes successfully.
 * @param user A dictionary containing information about the user that was authorized. See http://www.rdio.com/developers/docs/web-service/types/
 */
- (void)rdioDidAuthorizeUser:(NSDictionary *)user;


/**
 * Called if authorization cannot be completed due to network, server, or token problems.
 *
 * If you used `authorizeFromController` to inititate authorization, the user will be notified from the
 * login view before this method is called.
 *
 * If you called `authorizeUsingAccessToken:`, this method will be called without any notification to the end user.
 * In this circumstance, it's up to you to handle any changes this might imply for your UI.
 * @param error An NSError indicating what went wrong.
 */
- (void)rdioAuthorizationFailed:(NSError *)error;

/**
 * Called if the user aborts the authorization process.
 */
- (void)rdioAuthorizationCancelled;

/**
 * Called when logout completes.
 */
-(void)rdioDidLogout;

@end
