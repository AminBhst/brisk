# Changelog

## :rocket: Improvements on downloading video streams
### Soft-Subbing video files
Brisk can now retrieve all available subtitles from streaming websites and soft-sub them into downloaded video files.

This feature requires FFmpeg:
- It's generally recommended to have FFmpeg installed via a proper package manager
- On Windows and Linux, Brisk can automatically download and integrate FFmpeg for you
- You can check FFmpeg integration status and set a custom FFmpeg path in Settings → General → FFmpeg

### Smart Naming for Video Stream Files
The browser extension is now able to automatically assign a proper name for video files from the following websites (extension v1.3.0):
  - aniwatchtv.to
  - hianimez.to
  - aniplaynow.live
  - openani.me

## :hammer_and_wrench: Bug Fixes and Improvements
- Fixed tray menu not dismissing on Windows [#116](https://github.com/BrisklyDev/brisk/issues/116)
- Minor UI bug fixes and improvements
- Fixed an issue where Brisk’s window opened even if the download was skipped due to extension capture rules
- Fixed downloading video streams not working on some websites for Chrome

## :earth_asia: Internationalization
- Added Turkish translations by [Holi](https://github.com/mikropsoft)
