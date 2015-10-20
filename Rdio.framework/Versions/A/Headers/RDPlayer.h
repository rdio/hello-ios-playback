/**
 *  @file RDPlayer.h
 *  Rdio Playback Interface
 *  Copyright 2011-2013 Rdio Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioToolbox.h>
#import "RDPlayerQueue.h"

@class RDStationManager;

////////////////////////////////////////////////////////////////////////////////

/**
 * Playback status
 */
typedef enum {
  RDPlayerStateInitializing, /**< Player is not ready yet */
  RDPlayerStatePaused, /**< Playback is paused */
  RDPlayerStatePlaying, /**< Currently playing */
  RDPlayerStateStopped, /**< Playback is stopped */
  RDPlayerStateBuffering /**< Playback is stalled due to buffering, and will resume when enough data is available */
} RDPlayerState;


typedef enum {
  RDAutoSkipNext = 0,
  RDAutoSkipPrevious
} RDAutoSkipDirection;

////////////////////////////////////////////////////////////////////////////////

/**
 * Player delegate
 */
@protocol RDPlayerDelegate <NSObject>

/**
 * Notification that the current user has started playing with Rdio from 
 * another location, and playback here must stop.
 * @return <code>YES</code> if you handle letting the user know, or <code>NO</code> to have the SDK display a dialog.
 */
-(BOOL)rdioIsPlayingElsewhere;

/**
 * Notification that the player has changed states. See <code>RDPlayerState</code>.
 */
-(void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState;

@optional

/**
 * Notification that the current source has been updated.
 *
 * For example, when the currently playing album completes and the next item in the queue is played,
 * or when a Station Manager updates the tracks available to be displayed.
 */
-(void)rdioPlayerCurrentSourceDidChange;

/**
 * Notification that the specified track did not successfully finish streaming.
 *
 * If this method is not implemented, we will automatically skip to the next track.
 *
 * @return <code>YES</code> if you want to override this behavior.
 */
- (BOOL)rdioPlayerFailedDuringTrack:(NSString *)trackKey withError:(NSError *)error;


/**
 * Notification that the player has fallen back to an Ad-Supported Station for the
 * `originalSource` in the queue.  The RDPlayer maintains this manager, and uses it
 * to implement the appropriate behavior for free users, including playing back ads,
 * and enforcing skip limitations.
 *
 * Strictly speaking, you don't need to keep a reference to this manager, since the player
 * has one already, but you should do so if you'd like to propagate the number of skips
 * left to your UI.
 *
 * You can also get a copy of the updated current source (i.e. if a provided source falls
 * back to a station) via `manager.sourceKey`.
 *
 * The RDPlayer will generate a new manager for each fallback station, so if your end-user
 * is navigating through a variety of station sources, you'll see this method called
 * once per converted source.
 *
 * @param manager The RDAdSupportedStationManager responsible for managing this station.
 * @param originalSource The key of the source that you originally tried to play.
 */
- (void)rdioGeneratedStationWithManager:(RDStationManager *)manager forSource:(NSString *)originalSource;


/**
 * Notification that a call to one of the `skip` playback controls has failed.
 *
 * On sources with an RDAdSupportedStationManager, skipping will probably be restricted
 * to 6 skips per station per hour (as specified by the DMCA), and no rewinds.
 * As such, your calls to the following methods may fail:
 * `next`, `previous`, `skipToIndex:` `playAndRestart:` and `seekToPosition:`.
 *
 * When one of these methods fails due to these sorts of limitations, this method will
 * get called with an NSError in the `RDAdSupportedPlaybackErrorDomain` domain
 * with a code from `RDAdSupportedPlaybackErrorCode` corresponding to the action attempted.
 */
- (void)rdioPlaybackControlFailedWithError:(NSError *)error;


/**
 * If implemented, the SDK will call this when the audio session category
 * should be set. This allows you to set a custom category. The SDK uses
 * <code>kAudioSessionCategory_MediaPlayback</code>.
 *
 * Useful if your application needs to use a session category other than media
 * playback. For example, if your application needs to use play and record.
 *
 */
- (void)rdioPlayerSetAudioCategory;

/**
 * If you implement this, it is expected that <code>AudioSessionSetActive</code>
 * is called with the <code>beActive</code> parameter for audio to work.
 *
 * Useful if your application needs to manage the audio session state.
 */
- (void)rdioPlayerSetAudioSessionActive:(BOOL)beActive;


/**
 * Notification that an advertisement has begun playing
 *
 * @param ad Metadata for the ad such as name, duration, and image
 */
- (void)rdioPlayerDidStartAd:(NSDictionary *)ad;

/**
 * Notification that an advertisement has finished playing
 */
- (void)rdioPlayerDidFinishAd;

@end

////////////////////////////////////////////////////////////////////////////////

@class AudioStreamer;
@class RDUserEventLog;
@class RDSession;

/**
 * Responsible for playback. Handles playing and enqueueing track sources, 
 * advancing to the next track, logging plays with the server, etc.
 *
 * To observe track changes, position changes, etc., use KVO. For example:
 * \code
 *  [player addObserver:self forKeyPath:@"currentTrack" options:NSKeyValueObservingOptionNew context:nil];
 * \endcode
 *
 * All of the properties listed above are implemented in a KVO-compliant fashion,
 * so you should be able to observe their changes without any issues.
 */
@interface RDPlayer : NSObject {
@private
  RDPlayerState state_;
  double position_;
  double duration_;
  double pendingSeek_;

  RDSession *session_;
  
  int currentTrackIndex_;
  NSString *currentTrackKey_;
  AudioStreamer *audioStream_;
  
  int nextTrackIndex_;
  NSString *nextTrack_;
  NSDictionary *nextTrackInfo_;
  AudioStreamer *nextAudioStream_;

  // Unstreamable tracks are automatically skipped. In order to make sure `previous` still
  // works when the previous track is unstreamable, we need to keep track of the skip direction.
  RDAutoSkipDirection autoSkipDirection_;
  
  RDUserEventLog *log_;
  
  RDPlayerQueue *queue_;
  
  BOOL sentPlayEvent_;
  BOOL sentTimedPlayEvent_;
  BOOL sendSkipEvent_;
  BOOL sentSkipEvent_;
  
  BOOL checkingPlayingElsewhere_;
  
  NSTimer *pauseTimer_;
  NSString *playerName_;
  
  UInt8 bufferThreshold_;
  
  NSArray *trackKeys_;
  
  id<RDPlayerDelegate> delegate_;

  BOOL sharingPlaystate_;

  RDStationManager *stationManager_;
}

/**
 * Starts playing a source key, such as "t1232".
 *
 * Supported source keys include tracks, albums, playlists, and stations.
 *
 * Track keys can be found by calling web service API methods.
 * Objects such as Album contain a 'trackKeys' property.
 *
 * @param sourceKey a source key such as "t1232"
 */
-(void)play:(NSString *)sourceKey;

/**
 * Starts playing a source key, such as "a236074".
 *
 * Supported source keys include tracks, albums, playlists, and stations.
 *
 * Track keys can be found by calling web service API methods.
 * Objects such as Album contain a 'trackKeys' property.
 *
 * @param sourceKey a source key such as "a236074"
 * @param index The track index within the source to start playback.  This index is 0-based, so the first track is at index 0.
 */
-(void)play:(NSString *)sourceKey withIndex:(int)index;

/**
 * Starts playing the `index`th source from the current Queue.
 * All of the indexes in `RDPlayer` are 0-based: Using an index of 0 will play the first item in the queue.
 *
 * @param index The index of the source in the Queue to be played.
 */
- (void)playFromQueue:(int)index;

/**
 * Starts playing a source from the current Queue at a specified track index.
 *
 * Both the queueIndex and sourceIndex are 0-based.
 *
 * @param queueIndex The index of the source in the Queue to be played.
 * @param sourceIndex The index of the track within the source to be played.
 */
- (void)playFromQueue:(int)queueIndex startingAtIndex:(int)sourceIndex;

/**
 * Play the next track in the \ref RDPlayer::trackKeys "trackKeys" array.
 */
-(void)next;


/**
 * Skip to the next source in the queue.  If the queue is empty
 * and autoplay is enabled, this method will skip to the autoplay station.
 * If autoplay is disabled and the queue is empty, this method will
 * call `stop`.
 */
- (void)nextSource;

/**
 * Play the previous track in the \ref RDPlayer::trackKeys "trackKeys" array.
 */
-(void)previous;

/**
 * Play the track at a specific index in the \ref RDPlayer::trackKeys "trackKeys" array.
 *
 * @param index the index of the desired track
 * @return NO if the index is out of range
 */
-(BOOL)skipToIndex:(NSUInteger)index;

/**
 * Continues playing the current track
 *
 * This is the same as calling RDPlayer::playAndRestart:NO
 */
- (void)play;

/**
 * Continues playing the current track with an option to restart the track if
 * it's already playing
 *
 * If the player is already playing, setting shouldRestart to YES will restart
 * the track from the begining.
 *
 * @param shouldRestart if the player should restart the currently playing track
 */
- (void)playAndRestart:(BOOL)shouldRestart;

/**
 * Toggles paused state.
 */
- (void)togglePause;

/**
 * Stops playback and releases resources.
 */
- (void)stop;

/**
 * Seeks to the given position.
 * @param positionInSeconds position to seek to, in seconds
 */
- (void)seekToPosition:(double)positionInSeconds;

/**
  * Stops playback, releases resources and resets the current track queue.
  */
- (void)resetQueue;

/**
 * Analagous to AVPlayer's method of the same name.
 * See https://developer.apple.com/library/mac/#documentation/AVFoundation/Reference/AVPlayer_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40009530-CH1-SW7 for details.
 *
 * @param interval The interval of invocation of the block during normal playback, according to progress of the current time of the player.
 * @param queue A serial queue onto which block should be enqueued.
 * @param block
 * The block to be invoked periodically.
 * The block takes a single parameter:
 *   time
 *     The time at which the block is invoked.
 */
- (id)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime time) )block;

/**
 * Analagous to AVPlayer's method of the same name.
 *
 * Remove a time observer added by addPeriodicTimeObserverForInterval.
 *
 * @param observer The opaque object returned by addPeriodicTimeObserverForInterval.
 */
- (void)removeTimeObserver:(id)observer;

/**
 * Similar to -addPeriodicTimeObserverForInterval:, this method calls back the passed in block with updated audio power levels.
 *
 * @param interval The interval of invocation of the block during normal playback, according to progress of the current time of the player.
 * @param queue A serial queue onto which block should be enqueued.
 * @param block
 * The block to be invoked periodically.
 * The block takes two parameters:
 *   left
 *     The left channel's SPL in dB
 *   right
 *     The right channel's SPL in dB
 */
- (id)addPeriodicLevelObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(Float32 left, Float32 right))block;

/**
 * Remove a level observer added by addPeriodicLevelObserverForInterval.
 *
 * @param observer The opaque object returned by addPeriodicLevelObserverForInterval.
 */
- (void)removeLevelObserver:(id)observer;

/**
 * Become master player.  Only supported for Shared State Player.
 *
 */
- (void)becomeMasterPlayer;

/**
 * Current playback queue.
 */
@property (nonatomic, readonly) RDPlayerQueue *queue;

/**
 * Metadata for the current source such as the track and artist name.
 *
 * If the queued source was a track, this will be the same as \ref RDPlayer::currentTrack
 */
@property (nonatomic, readonly) NSDictionary *currentSource;

/**
 * Station manager for the current playing source, or nil if the source is not a station
 */
@property (nonatomic, readonly) RDStationManager *stationManager;

/**
 * Current playback state.
 */
@property (nonatomic, readonly) RDPlayerState state;

/**
 * Current position in seconds.
 */
@property (nonatomic, readonly) double position;

/**
 * Duration of the current track, in seconds.
 */
@property (nonatomic, readonly) double duration;

/**
 * Key of the current track.
 */
@property (nonatomic, readonly) NSString *currentTrackKey;

/**
 * Metadata for the current track such as the track and artist name.
 */
@property (nonatomic, readonly) NSDictionary *currentTrack;

/**
 * Index of the current playing track within the \ref RDPlayer::trackKeys "trackKeys" array.
 */
@property (nonatomic, readonly) int currentTrackIndex;

/**
 * List of track keys in the currently playing source.
 */
@property (nonatomic, readonly) NSArray *trackKeys;

/**
 * Delegate used to receive player state changes.
 */
@property (nonatomic, strong) id<RDPlayerDelegate> delegate;

/**
 * The number of buffers that need to be filled in order to resume playback once
 * the player pauses to buffer in low-connectivity situations.
 *
 * Defaults to 128.  Set lower to buffer less (audio resumes quicker), or higher
 * to buffer more (audio resumes slower, but is less likely to stop again), or to
 * 0 to resume playback on the next completed packet.
 *
 * Setting this value propagates changes to the audio streaming engine immediately.
 */
@property (nonatomic, assign) UInt8 bufferThreshold;

/**
 * Player Name.
 */
@property (nonatomic, assign) NSString *playerName;

@end

