import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_it.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
    Locale('it'),
    Locale('zh')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @addUrl.
  ///
  /// In en, this message translates to:
  /// **'Add URL'**
  String get addUrl;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add To Queue'**
  String get addToQueue;

  /// No description provided for @addDownload.
  ///
  /// In en, this message translates to:
  /// **'Add Download'**
  String get addDownload;

  /// No description provided for @customSavePath.
  ///
  /// In en, this message translates to:
  /// **'Custom Save Path'**
  String get customSavePath;

  /// No description provided for @checkForUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for Update'**
  String get checkForUpdate;

  /// No description provided for @getExtension.
  ///
  /// In en, this message translates to:
  /// **'Get Extension'**
  String get getExtension;

  /// No description provided for @allDownloads.
  ///
  /// In en, this message translates to:
  /// **'All Downloads'**
  String get allDownloads;

  /// No description provided for @unfinishedDownloads.
  ///
  /// In en, this message translates to:
  /// **'Unfinished Downloads'**
  String get unfinishedDownloads;

  /// No description provided for @finishedDownloads.
  ///
  /// In en, this message translates to:
  /// **'Finished Downloads'**
  String get finishedDownloads;

  /// No description provided for @downloadQueues.
  ///
  /// In en, this message translates to:
  /// **'Download Queues'**
  String get downloadQueues;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time Left'**
  String get timeLeft;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @finishDate.
  ///
  /// In en, this message translates to:
  /// **'Finish Date'**
  String get finishDate;

  /// No description provided for @add_a_download_url.
  ///
  /// In en, this message translates to:
  /// **'Add a Download URL'**
  String get add_a_download_url;

  /// No description provided for @updateDownloadUrl.
  ///
  /// In en, this message translates to:
  /// **'Update Download URL'**
  String get updateDownloadUrl;

  /// No description provided for @btn_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btn_cancel;

  /// No description provided for @btn_addUrl.
  ///
  /// In en, this message translates to:
  /// **'Add URL'**
  String get btn_addUrl;

  /// No description provided for @btn_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btn_add;

  /// No description provided for @btn_updateUrl.
  ///
  /// In en, this message translates to:
  /// **'Update URL'**
  String get btn_updateUrl;

  /// No description provided for @err_invalidUrl_title.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get err_invalidUrl_title;

  /// No description provided for @err_invalidUrl_description.
  ///
  /// In en, this message translates to:
  /// **'The URL you\'ve entered appears to be invalid.\nPlease check the format and try again.'**
  String get err_invalidUrl_description;

  /// No description provided for @err_invalidUrl_descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Make sure the URL:\n\t • Starts with https:// or http://\n\t • Contains a valid domain name\n\t • Contains no invalid characters'**
  String get err_invalidUrl_descriptionHint;

  /// No description provided for @addNewDownload.
  ///
  /// In en, this message translates to:
  /// **'Add New Download'**
  String get addNewDownload;

  /// No description provided for @downloadInfo.
  ///
  /// In en, this message translates to:
  /// **'Download Info'**
  String get downloadInfo;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @saveAs.
  ///
  /// In en, this message translates to:
  /// **'Save As'**
  String get saveAs;

  /// No description provided for @pauseCapable.
  ///
  /// In en, this message translates to:
  /// **'Pause Capable'**
  String get pauseCapable;

  /// No description provided for @btn_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get btn_download;

  /// No description provided for @btn_addToList.
  ///
  /// In en, this message translates to:
  /// **'Add To List'**
  String get btn_addToList;

  /// No description provided for @btn_openFile.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get btn_openFile;

  /// No description provided for @btn_openFileLocation.
  ///
  /// In en, this message translates to:
  /// **'Open File Location'**
  String get btn_openFileLocation;

  /// No description provided for @of_.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get of_;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// No description provided for @activeConnections.
  ///
  /// In en, this message translates to:
  /// **'Active Connections'**
  String get activeConnections;

  /// No description provided for @btn_showConnectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Show Connection Details'**
  String get btn_showConnectionDetails;

  /// No description provided for @btn_hideConnectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide Connection Details'**
  String get btn_hideConnectionDetails;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @btn_resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get btn_resume;

  /// No description provided for @btn_pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get btn_pause;

  /// No description provided for @btn_wait.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get btn_wait;

  /// No description provided for @status_paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get status_paused;

  /// No description provided for @status_downloadingFile.
  ///
  /// In en, this message translates to:
  /// **'Downloading File'**
  String get status_downloadingFile;

  /// No description provided for @status_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get status_connecting;

  /// No description provided for @status_resetting.
  ///
  /// In en, this message translates to:
  /// **'Resetting'**
  String get status_resetting;

  /// No description provided for @status_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get status_complete;

  /// No description provided for @status_assemblingFile.
  ///
  /// In en, this message translates to:
  /// **'Assembling File'**
  String get status_assemblingFile;

  /// No description provided for @status_validatingFiles.
  ///
  /// In en, this message translates to:
  /// **'Validating Files'**
  String get status_validatingFiles;

  /// No description provided for @status_downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download Failed'**
  String get status_downloadFailed;

  /// No description provided for @duplicateDownload_title.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Download'**
  String get duplicateDownload_title;

  /// No description provided for @duplicateDownload_description.
  ///
  /// In en, this message translates to:
  /// **'This download already exists!\nPlease choose an action.'**
  String get duplicateDownload_description;

  /// No description provided for @btn_addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get btn_addNew;

  /// No description provided for @popupMenu_showProgress.
  ///
  /// In en, this message translates to:
  /// **'Show Progress'**
  String get popupMenu_showProgress;

  /// No description provided for @popupMenu_properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get popupMenu_properties;

  /// No description provided for @err_failedToRetrieveFileInfo_title.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve file info'**
  String get err_failedToRetrieveFileInfo_title;

  /// No description provided for @err_failedToRetrieveFileInfo_description.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong when trying to retrieve file information from this URL.'**
  String get err_failedToRetrieveFileInfo_description;

  /// No description provided for @err_failedToRetrieveFileInfo_descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'In some cases, retrying a few times may solve the issue. Otherwise, make sure the resource you\'re to reach is valid.'**
  String get err_failedToRetrieveFileInfo_descriptionHint;

  /// No description provided for @retrievingFileInformation.
  ///
  /// In en, this message translates to:
  /// **'Retrieving file information...'**
  String get retrievingFileInformation;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_menu_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_menu_general;

  /// No description provided for @settings_menu_file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get settings_menu_file;

  /// No description provided for @settings_menu_connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get settings_menu_connection;

  /// No description provided for @settings_menu_extension.
  ///
  /// In en, this message translates to:
  /// **'Extension'**
  String get settings_menu_extension;

  /// No description provided for @settings_menu_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_menu_about;

  /// No description provided for @settings_menu_bugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get settings_menu_bugReport;

  /// No description provided for @settings_notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get settings_notification;

  /// No description provided for @settings_notification_onDownloadCompletion.
  ///
  /// In en, this message translates to:
  /// **'Notification on download completion'**
  String get settings_notification_onDownloadCompletion;

  /// No description provided for @settings_notification_onDownloadFailure.
  ///
  /// In en, this message translates to:
  /// **'Notification on download failure'**
  String get settings_notification_onDownloadFailure;

  /// No description provided for @settings_userInterface.
  ///
  /// In en, this message translates to:
  /// **'User Interface'**
  String get settings_userInterface;

  /// No description provided for @settings_userInterface_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_userInterface_theme;

  /// No description provided for @settings_behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get settings_behavior;

  /// No description provided for @settings_behavior_launchAtStartup.
  ///
  /// In en, this message translates to:
  /// **'Launch At Startup'**
  String get settings_behavior_launchAtStartup;

  /// No description provided for @settings_behavior_showProgressOnNewDownload.
  ///
  /// In en, this message translates to:
  /// **'Show progress window when a new download starts'**
  String get settings_behavior_showProgressOnNewDownload;

  /// No description provided for @settings_behavior_appClosureBehavior.
  ///
  /// In en, this message translates to:
  /// **'App Closure Behavior'**
  String get settings_behavior_appClosureBehavior;

  /// No description provided for @settings_behavior_appClosureBehavior_alwaysAsk.
  ///
  /// In en, this message translates to:
  /// **'Always Ask'**
  String get settings_behavior_appClosureBehavior_alwaysAsk;

  /// No description provided for @settings_behavior_appClosureBehavior_exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get settings_behavior_appClosureBehavior_exit;

  /// No description provided for @settings_behavior_appClosureBehavior_minimizeToTray.
  ///
  /// In en, this message translates to:
  /// **'Minimize To Tray'**
  String get settings_behavior_appClosureBehavior_minimizeToTray;

  /// No description provided for @settings_behavior_duplicateDownloadAction.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Download Action'**
  String get settings_behavior_duplicateDownloadAction;

  /// No description provided for @settings_behavior_duplicateDownloadAction_alwaysAsk.
  ///
  /// In en, this message translates to:
  /// **'Always Ask'**
  String get settings_behavior_duplicateDownloadAction_alwaysAsk;

  /// No description provided for @settings_behavior_duplicateDownloadAction_skipDownload.
  ///
  /// In en, this message translates to:
  /// **'Skip Download'**
  String get settings_behavior_duplicateDownloadAction_skipDownload;

  /// No description provided for @settings_behavior_duplicateDownloadAction_updateUrl.
  ///
  /// In en, this message translates to:
  /// **'Update URL'**
  String get settings_behavior_duplicateDownloadAction_updateUrl;

  /// No description provided for @settings_behavior_duplicateDownloadAction_addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get settings_behavior_duplicateDownloadAction_addNew;

  /// No description provided for @settings_logging.
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get settings_logging;

  /// No description provided for @settings_logging_enableDownloadEngineLogging.
  ///
  /// In en, this message translates to:
  /// **'Enable Download Engine Logging'**
  String get settings_logging_enableDownloadEngineLogging;

  /// No description provided for @settings_paths.
  ///
  /// In en, this message translates to:
  /// **'Paths'**
  String get settings_paths;

  /// No description provided for @settings_paths_tempFilesPath.
  ///
  /// In en, this message translates to:
  /// **'Temp Files Path'**
  String get settings_paths_tempFilesPath;

  /// No description provided for @settings_paths_savePath.
  ///
  /// In en, this message translates to:
  /// **'Save Path'**
  String get settings_paths_savePath;

  /// No description provided for @settings_rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get settings_rules;

  /// No description provided for @settings_rules_extensionSkipCaptureRules.
  ///
  /// In en, this message translates to:
  /// **'Extension Skip Capture Rules'**
  String get settings_rules_extensionSkipCaptureRules;

  /// No description provided for @settings_rules_extensionSkipCaptureRules_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Defines conditions which determine when a file should not be captures via browser extension'**
  String get settings_rules_extensionSkipCaptureRules_tooltip;

  /// No description provided for @settings_rules_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Rules'**
  String get settings_rules_edit;

  /// No description provided for @settings_rules_fileSavePathRules.
  ///
  /// In en, this message translates to:
  /// **'File Save Path Rules'**
  String get settings_rules_fileSavePathRules;

  /// No description provided for @settings_rules_fileSavePathRules_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Defines conditions which determine when a file should be saved in the specified location'**
  String get settings_rules_fileSavePathRules_tooltip;

  /// No description provided for @settings_fileCategory.
  ///
  /// In en, this message translates to:
  /// **'File Category'**
  String get settings_fileCategory;

  /// No description provided for @settings_fileCategory_video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get settings_fileCategory_video;

  /// No description provided for @settings_fileCategory_music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settings_fileCategory_music;

  /// No description provided for @settings_fileCategory_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get settings_fileCategory_archive;

  /// No description provided for @settings_fileCategory_program.
  ///
  /// In en, this message translates to:
  /// **'Program'**
  String get settings_fileCategory_program;

  /// No description provided for @settings_fileCategory_document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get settings_fileCategory_document;

  /// No description provided for @settings_connectionRetry.
  ///
  /// In en, this message translates to:
  /// **'Connection Retry'**
  String get settings_connectionRetry;

  /// No description provided for @settings_connectionRetry_maxConnectionRetryCount.
  ///
  /// In en, this message translates to:
  /// **'Max Connection Retry Count'**
  String get settings_connectionRetry_maxConnectionRetryCount;

  /// No description provided for @settings_connectionRetry_connectionRetryTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection Retry Timeout'**
  String get settings_connectionRetry_connectionRetryTimeout;

  /// No description provided for @infinite.
  ///
  /// In en, this message translates to:
  /// **'infinite'**
  String get infinite;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @settings_proxy.
  ///
  /// In en, this message translates to:
  /// **'Proxy'**
  String get settings_proxy;

  /// No description provided for @settings_proxy_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settings_proxy_enabled;

  /// No description provided for @settings_proxy_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get settings_proxy_address;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @settings_downloadConnections.
  ///
  /// In en, this message translates to:
  /// **'Download Connections'**
  String get settings_downloadConnections;

  /// No description provided for @settings_downloadConnections_regularConnNum.
  ///
  /// In en, this message translates to:
  /// **'Number of Regular Download Connections'**
  String get settings_downloadConnections_regularConnNum;

  /// No description provided for @settings_downloadConnections_videoStreamConnNum.
  ///
  /// In en, this message translates to:
  /// **'Number of Video Stream Download Connections'**
  String get settings_downloadConnections_videoStreamConnNum;

  /// No description provided for @settings_browserExtension.
  ///
  /// In en, this message translates to:
  /// **'Browser Extension'**
  String get settings_browserExtension;

  /// No description provided for @settings_downloadBrowserExtension.
  ///
  /// In en, this message translates to:
  /// **'Download Browser Extension'**
  String get settings_downloadBrowserExtension;

  /// No description provided for @settings_downloadBrowserExtension_installExtension.
  ///
  /// In en, this message translates to:
  /// **'Click to install the browser extension'**
  String get settings_downloadBrowserExtension_installExtension;

  /// No description provided for @settings_downloadBrowserExtension_bringWindowToFront.
  ///
  /// In en, this message translates to:
  /// **'Bring window to front on new download'**
  String get settings_downloadBrowserExtension_bringWindowToFront;

  /// No description provided for @changesRequireRestart.
  ///
  /// In en, this message translates to:
  /// **'Changes require a restart'**
  String get changesRequireRestart;

  /// No description provided for @settings_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settings_info;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_info_donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get settings_info_donate;

  /// No description provided for @settings_info_discordServer.
  ///
  /// In en, this message translates to:
  /// **'Discord Server'**
  String get settings_info_discordServer;

  /// No description provided for @settings_info_telegramChannel.
  ///
  /// In en, this message translates to:
  /// **'Telegram Channel'**
  String get settings_info_telegramChannel;

  /// No description provided for @settings_developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settings_developer;

  /// No description provided for @settings_howToBugReport.
  ///
  /// In en, this message translates to:
  /// **'How To Bug Report'**
  String get settings_howToBugReport;

  /// No description provided for @settings_howToBugReport_clickToOpenIssue.
  ///
  /// In en, this message translates to:
  /// **'Click to open an issue'**
  String get settings_howToBugReport_clickToOpenIssue;

  /// No description provided for @settings_howToBugReport_description.
  ///
  /// In en, this message translates to:
  /// **'In order to report a bug or request a feature, open a new issue in the project GitHub repo and add the proper labels.'**
  String get settings_howToBugReport_description;

  /// No description provided for @btn_saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get btn_saveChanges;

  /// No description provided for @btn_resetDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get btn_resetDefaults;

  /// No description provided for @btn_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btn_save;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @savePath.
  ///
  /// In en, this message translates to:
  /// **'Save Path'**
  String get savePath;

  /// No description provided for @ruleEditor_fileNameContains.
  ///
  /// In en, this message translates to:
  /// **'File name contains'**
  String get ruleEditor_fileNameContains;

  /// No description provided for @ruleEditor_fileSizeGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'File size greater than'**
  String get ruleEditor_fileSizeGreaterThan;

  /// No description provided for @ruleEditor_fileSizeLessThan.
  ///
  /// In en, this message translates to:
  /// **'File size less than'**
  String get ruleEditor_fileSizeLessThan;

  /// No description provided for @ruleEditor_fileExtensionIs.
  ///
  /// In en, this message translates to:
  /// **'File extension is'**
  String get ruleEditor_fileExtensionIs;

  /// No description provided for @ruleEditor_downloadUrlContains.
  ///
  /// In en, this message translates to:
  /// **'Download URL contains'**
  String get ruleEditor_downloadUrlContains;

  /// No description provided for @err_invalidPath_title.
  ///
  /// In en, this message translates to:
  /// **'Invalid Path'**
  String get err_invalidPath_title;

  /// No description provided for @err_invalidPath_tempPath_description.
  ///
  /// In en, this message translates to:
  /// **'The path you\'ve selected for the temp path appears to be invalid!'**
  String get err_invalidPath_tempPath_description;

  /// No description provided for @err_invalidPath_savePath_description.
  ///
  /// In en, this message translates to:
  /// **'The path you\'ve selected for the save path appears to be invalid!'**
  String get err_invalidPath_savePath_description;

  /// No description provided for @err_invalidPath_descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Please make sure that all folders in the path exist'**
  String get err_invalidPath_descriptionHint;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @err_emptyValue.
  ///
  /// In en, this message translates to:
  /// **'Empty Value!'**
  String get err_emptyValue;

  /// No description provided for @err_unsupportedCharacter.
  ///
  /// In en, this message translates to:
  /// **'Unsupported Character'**
  String get err_unsupportedCharacter;

  /// No description provided for @err_invalidSavePath.
  ///
  /// In en, this message translates to:
  /// **'Invalid Save Path!'**
  String get err_invalidSavePath;

  /// No description provided for @availableDownloads.
  ///
  /// In en, this message translates to:
  /// **'Available Downloads'**
  String get availableDownloads;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fa', 'it', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fa': return AppLocalizationsFa();
    case 'it': return AppLocalizationsIt();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
