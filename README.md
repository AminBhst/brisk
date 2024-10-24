[![license](https://img.shields.io/github/license/AminBhst/brisk?style=flat-square)](https://github.com/AminBhst/brisk/blob/main/LICENSE)
[![release](https://img.shields.io/github/v/release/AminBhst/brisk?style=flat-square)](https://github.com/AminBhst/brisk/releases)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/AminBhst/brisk/total?style=flat-square)
<a href="https://discord.gg/g8fwgZ84"><img alt="Discord Chat" src="https://img.shields.io/discord/1298990692000989225?color=5865F2&label=discord&style=flat-square"></a>

<p align="center">
<img width="100" src="assets/icons/logo.png" alt="Brisk">
<p align="center">Ultra-fast, modern download manager for desktop</pal>
</p>

## :package: Installation

Installation files for Windows and Linux are available at [Github Releases](https://github.com/AminBhst/brisk/releases/).

If you encountered a "Windows Protected your PC" error, click `more info -> run anyway`

For Linux, make sure to read the [Linux Prerequisites](#key-linux-prerequisites).

Brisk is also available on the [Arch AUR](https://aur.archlinux.org/packages/brisk-bin)

MacOS builds are unfortunately not available. If you're interested in this project and would like to contribute by providing MacOS builds for each release, please open an issue to let me know.

## :rocket: Key Features

- [Powerful Download Engine](#gear-brisks-download-engine)
- [Browser Integration](#globe_with_meridians-browser-integration)
- Download Queues
- Hotkey (ctrl+alt+A) to quickly add a download URL from the clipboard

## :gear: Brisk's Download Engine
Brisk is powered by a high-performance engine that delivers the highest possible download speed across the entire duration of the download.

The key features of the engine include:
- **Dynamic Connection Spawn:** Downloads starts with a single connection and as they progress, new connections are added on the fly and without interfering with one another. This ensures that a higher number of connections are used only when necessary, significantly improving the download speed of small-to-medium sized files.
- **Dynamic Connection Reuse:** After a connection completes receiving its designated byte range, it is immediately reassigned to assist another connection. This means that finished connections actively contribute to the overall download process by handling portions of other busy connections' byte ranges. As a result, the engine maintains as many active connections as possible, ensuring that download speeds remain consistently at their peak.
- **Automatic connection reset:** Hanging connections will be reset automatically.

## :globe_with_meridians: Browser Integration
Brisk supports [Browser Integration](https://github.com/AminBhst/brisk-browser-extension) that allows for capturing downloads from the browser and adding them directly into the app.

#### Chrome / Edge / Opera
[link-chrome]: https://github.com/AminBhst/brisk-browser-extension/releases/latest 'Version published on Chrome Web Store'

[<img src="https://raw.githubusercontent.com/alrra/browser-logos/90fdf03c/src/chrome/chrome.svg" width="48" alt="Chrome" valign="middle">][link-chrome] [<img src="https://raw.githubusercontent.com/alrra/browser-logos/90fdf03c/src/edge/edge.svg" width="48" alt="Edge" valign="middle">][link-chrome] [<img src="https://raw.githubusercontent.com/alrra/browser-logos/90fdf03c/src/opera/opera.svg" width="48" alt="Opera" valign="middle">][link-chrome]

#### Firefox
[link-firefox]: https://addons.mozilla.org/en-US/firefox/addon/brisk/

[<img src="https://raw.githubusercontent.com/alrra/browser-logos/90fdf03c/src/firefox/firefox.svg" width="48" alt="Firefox" valign="middle">][link-firefox]

## :film_projector: Demo With Browser Integration


https://github.com/user-attachments/assets/2e978dae-084a-4181-9576-15b5b61e84ae


## :key: Linux Prerequisites

  - **keybinder-3**
     - Debian/Ubuntu : ```libkeybinder-3.0-0```
     - Fedora/RHEL/CentOS : ```keybinder3```
     - Arch Linux : ```libkeybinder3```

  - **appindicator3-0.1**
     - Debian/Ubuntu : ```libayatana-appindicator3-dev```
     - Fedora/RHEL/CentOS : ```libayatana-appindicator-gtk3```
     - Arch Linux : ```libappindicator-gtk3```


## :hammer_and_wrench: Build From Source

Download the Flutter SDK v2.22.0 and set the path variable

```bash
flutter build macos|windows|linux
```

## :heart: Credits and Contributors
Contributions are welcome and appreciated.

### :trophy: Special thanks to:
- [AliML111](https://github.com/AliML111)
- [Zorin FOSS](https://github.com/ZorinFoss)
- [Norman Wang](https://github.com/Norman-w)
