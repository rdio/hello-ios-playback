A more advanced Playback example for iOS
========================================

This example builds on the simple version in `master` to illustrate some more
of the SDK's features.

Instead of just being a simple Hello World that plays back audio, this version
contains playback controls and UI features that you might expect to find in a
normal music playing application.

This version includes:

- Transport controls:
  - Play
  - Pause
  - Previous track (or restart, if you're well into the current track)
  - Next track
  - Stop
  - Seek via the position bar
- Playback metadata
  - Artist
  - Track
  - Album
  - The source used to play back the track (which might be the album, a
    playlist, a station, or the track itself)
  - Track duration
  - Current position in the track
- Audio VU meters

As with the `master` branch, you'll still need to head over to
https://rdio.com/developers/ to get a `client_id` and `client_secret` to put
into `Hello/ClientCredentials.h`.  But, if you already did that on the `master`
branch, you should be able to check out this branch and run it without having
to update that file.
