/**
 *  @file RDPlayerQueue.h
 *  Rdio Player Queue Interface
 *  Copyright 2014 Rdio Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface RDPlayerQueue : NSObject

/**
 * Add a list of source keys to the end of the existing play queue
 *
 * Supported source keys include tracks, albums, playlists, and artist stations.
 *
 * @param sourceKeys A source key, such as "t1232" or an array of source keys
 */
- (void)add:(id)sourceKeys;

/**
 * Remove a source key from the existing play queue
 *
 * @param index The index of the source in the queue to be removed.
 */
- (void)removeAtIndex:(int)index;

/**
 * Removes all items from the play queue.
 *
 * If you are using the shared-playstate, use this method with extreme caution,
 * as users may find it malicious if your app wipes out their queue.
 */
- (void)removeAll;

/**
 * Move a source key within the existing play queue
 *
 * @param from The index of the source in the queue to be moved.
 * @param to The new index for the moved source.
 */
- (void)moveFromIndex:(int)from toIndex:(int)to;

/**
 * Returns the source key at the specified index within the existing play queue
 *
 * @param index The index of the source in the queue to be returned.
 * @return The key of the source at the requested index.
 */
- (NSString*)itemAtIndex:(int)index;

/**
 * Returns the length of the existing play queue
 *
 * @return The length of the existing play queue
 */
- (NSUInteger)length;

@end
