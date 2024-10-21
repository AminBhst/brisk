## Change Log

### :rocket: Introducing Download Engine V2

Brisk's download engine has been fully redesigned to consistently deliver the highest possible download speeds
throughout the entire download process.
<p>The new engine comes with two major features:

- **Dynamic Connection Spawn:** The download now starts with a single connection and as
  it progresses, new connections are added on the fly and without interfering with each other. This ensures that a higher
  number of connections are used only when necessary, significantly improving the download speed of small-to-medium
  sized files.

<p>

- **Dynamic Connection Reuse:** After a connection has finished receiving its designated byte range, it will be
  reassigned
  to a new one. In other words, completed connections now help other busy connections by receiving parts of their byte
  range.
  This feature allows for having the total number of connections as active as possible to ensure the that download speed
  is always at its peak.

## :sparkles: Improved UX

- **Right-Click on Download Rows:** Right-clicking a download now opens the context menu, replacing the three-dots icon
  button for better accessibility.

<p>

- **Double Taps:** Double-tapping a download now does two actions depending on the state of the download; If the file is
  currently being downloaded, double-tapping opens the download progress window. Otherwise, the download info dialog will be opened.

<p>


- **Automatic CheckBox Selection:** Clicking download rows now automatically triggers their checkbox.

<p>

- **Open File Location:** The `Open File Location` button now also highlights the target file in the File Explorer (Windows Only)

## :art: New Default Theme

To reflect the major improvements of Brisk's new release, a new default dark-mode theme has been added
named `Celestial Dark`. The old theme is still available and can be selected via `Settings -> User Interface -> Active Theme -> Signature Blue`

## :hammer_and_wrench: Bug Fixes and Improvements

- Fixed browser-integration occasionally not working
- Fixed failing to extract download links from a selected text area in the browser if that area contained invalid URLs.
- Upgraded Flutter to version 3.22.0

## :pencil: Note

Due to the massive engine changes of this major release, the unfinished downloads of older versions of Brisk
cannot be continued with the new 2.0.0 version. This version uses a different path for its database so you can delete the old `Brisk`
directory inside your documents directory if you no longer need the older Brisk versions.

## :heart: Credits
Special thanks to [AliML111](https://github.com/AliML111) for his work on the projects' GitHub Actions.