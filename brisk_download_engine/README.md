![GitHub License](https://img.shields.io/github/license/AminBhst/brisk-engine?style=flat-square)
[![Pub](https://img.shields.io/pub/v/brisk_engine.svg?style=flat-square&include_prereleases)](https://pub.dev/packages/brisk_engine)
<a href="https://discord.gg/3mpSsVWF"><img alt="Discord Chat" src="https://img.shields.io/discord/1298990692000989225?color=5865F2&label=discord&style=flat-square"></a>
[![Telegram Channel](https://img.shields.io/badge/Channel-Telegram-blue.svg?logo=telegram&style=flat-square)](https://t.me/ryedev)

<p align="center">
<p align="center">Ultra-fast, highly efficient download engine written in pure dart </pal>

## :gear: About Brisk Engine

Brisk-Engine is the download engine that powers [Brisk Download Manager](https://github.com/AminBhst/brisk), now
available as a separate library.
It is written in pure dart and can be used on all devices without platform-specific dependencies.

## :rocket: Features

- **Dynamic Connection Spawn:** Downloads starts with a single connection and as they progress, new connections are added on the fly and without interfering with one another. This ensures that a higher number of connections are used only when necessary, significantly improving the download speed of small-to-medium sized files.
- **Dynamic Connection Reuse:** After a connection completes receiving its designated byte range, it is immediately reassigned to assist another connection. This means that finished connections actively contribute to the overall download process by handling portions of other busy connections' byte ranges. As a result, the engine maintains as many active connections as possible, ensuring that download speeds remain consistently at their peak.
- **Automatic connection reset:** Hanging connections will be reset automatically.


## Example Usage

```dart

/// Build the download item either by using this method or manually building it
/// using HttpDownloadEngine.requestFileInfo(url). Note that buildDownloadItem(url)
/// automatically uses an isolate to request for file information while requestFileInfo
/// does so in the same isolate.Therefore, it's recommended to use the below method.
final downloadItem = await HttpDownloadEngine.buildDownloadItem(url);

/// Start the engine
DownloadEngine.start(
  downloadItem,
  settings,
  onButtonAvailability: (message) {
  /// Handle button availability. A download should only be paused or resumed
  /// when the buttons are available as notified in this method. Otherwise, it could
  /// lead to a corrupted file.
  },
  onDownloadProgress: (message) {
  /// Updates on the download progress will be notified here
  },
);

/// You can use the UID which is set on the downloadItem to pause/resume the download

/// Pause the download
DownloadEngine.pause(downloadItem.uid);

/// Resume the download
DownloadEngine.resume(downloadItem.uid);

```
