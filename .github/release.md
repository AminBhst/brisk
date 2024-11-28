# Change Log

## :rocket: File Rules Feature
You can define an unlimited number of file rules for two functionalities:
- **Browser Extension Capture Skip**:
Rules that will define which files should be excluded from being captured by brisk via browser extension

- **File Save Location Rules**:
Rules that will define in which locations should files be saved.

Rules are defined by a condition and a value.

Conditions:
FileSizeGreaterThan, FileSizeLessThan, FileNameContains, FileExtensionIs, FileTypeIs, DownloadUrlContains

Example of File Rules:

Browser Extension Capture Skip Rule: 

- **Condition:** FileSizeLessThan **Value:** 1 MB 

Based on the above condition, files that are less than 1MB in size, will not be captured by the browser extension.
For "File Save Location Rules", you can also define rules and files that follow such rules will be saved in a defined location.
You can find these options in [**Settings --> File --> Rules**] and [**Settings --> Extension --> Rules**]

## :arrows_counterclockwise: Automatic Update Feature
Brisk is now shipped with an automatic update feature which allows for automatically downloading and installing the latest version without the need for manual installation, as well as displaying the change log related to the downloaded version.

## :pencil: Note
- Unfortunately, due to the added complexity of packaging the brisk_auto_update module for .rpm and .deb, support for these packages are dropped from this version forward.
- On linux, make sure to extract Brisk's binaries in a location which does not require elevated permissions in order for the automatic update to work properly.
