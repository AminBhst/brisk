import 'package:brisk/download_engine/download_command.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../download_engine/message/download_progress_message.dart';

class DownloadProgressWindow extends StatefulWidget {
  final int downloadId;

  DownloadProgressWindow(this.downloadId);

  @override
  State<DownloadProgressWindow> createState() => _DownloadProgressWindowState();
}

class _DownloadProgressWindowState extends State<DownloadProgressWindow> {
  bool showDetails = false;
  bool showDetailAvailable = true;

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<DownloadRequestProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context)
        .activeTheme
        .downloadProgressWindowTheme;
    final size = MediaQuery.of(context).size;
    final downloadProgress = provider.downloads[widget.downloadId]!;
    return ClosableWindow(
      width: resolveWindowWidth(size),
      backgroundColor: theme.windowBackgroundColor,
      height: showDetails
          ? resolveWindowHeight(size) + 280
          : resolveWindowHeight(size),
      content: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: theme.infoContainerBackgroundColor,
                border: Border.all(
                  color: theme.infoContainerBorderColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('File Name :  ',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(
                        width: resolveTextWidth(size),
                        child: Text(
                          downloadProgress.downloadItem.fileName,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                  // const SizedBox(height: 8),
                  statusTextPadding(size),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('URL : ',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(
                        width: resolveTextWidth(size),
                        child: Text(
                          downloadProgress.downloadItem.downloadUrl,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  statusTextPadding(size),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Size : ',
                          style: TextStyle(color: Colors.white)),
                      Text(
                          convertByteToReadableStr(
                              downloadProgress.downloadItem.contentLength),
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  statusTextPadding(size),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Progress : ',
                          style: TextStyle(color: Colors.white)),
                      Selector<DownloadRequestProvider, double>(
                        selector: (_, provider) => provider
                            .downloads[widget.downloadId]!.downloadProgress,
                        builder: (context, progress, child) => Text(
                            progress == 1
                                ? '${(progress * 100).toStringAsFixed(0)}%'
                                : '${(progress * 100).toStringAsFixed(2)}%',
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  statusTextPadding(size),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Transfer Rate : ',
                          style: TextStyle(color: Colors.white)),
                      Selector<DownloadRequestProvider, String>(
                        selector: (_, provider) =>
                            provider.downloads[widget.downloadId]!.transferRate,
                        builder: (context, transferRate, child) => Text(
                            transferRate,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  statusTextPadding(size),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Status : ',
                          style: TextStyle(color: Colors.white)),
                      Selector<DownloadRequestProvider, String>(
                        selector: (_, provider) => provider
                            .downloads[widget.downloadId]!.downloadItem.status,
                        builder: (context, status, child) => Text(status,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  statusTextPadding(size),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Estimated Time Remaining : ',
                          style: TextStyle(color: Colors.white)),
                      Selector<DownloadRequestProvider, String>(
                        selector: (_, provider) => provider
                            .downloads[widget.downloadId]!.estimatedRemaining,
                        builder: (context, estimatedRemaining, child) => Text(
                            estimatedRemaining,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: size.height < 450 ? 10 : 30),
          SizedBox(
            width: size.width * 0.7 - 10,
            height: 20,
            child: Selector<DownloadRequestProvider, double>(
              selector: (_, provider) =>
                  provider.downloads[widget.downloadId]!.downloadProgress,
              builder: (context, progress, child) {
                return LinearProgressIndicator(
                  // color: const Color.fromRGBO(99, 130, 239, 1),
                  color: Colors.lightGreen,
                  backgroundColor: Colors.white,
                  value: progress,
                );
              },
            ),
          ),
          SizedBox(height: resolveButtonsYMargin(size)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: showDetailAvailable
                    ? () => setState(() => showDetails = !showDetails)
                    : null,
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        showDetailAvailable ? Colors.blueGrey : Colors.grey)),
                child: Row(
                  children: [
                    Text(
                      showDetails ? "Hide Details" : "Show Details",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Icon(
                      showDetails
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              SizedBox(width: resolveButtonsXMargin(size)),
              Selector<DownloadRequestProvider, ButtonAvailability>(
                selector: (_, provider) =>
                    provider.downloads[widget.downloadId]!.buttonAvailability,
                builder: (context, buttonEnabled, child) => TextButton(
                  style: ButtonStyle(
                    // backgroundColor: MaterialStatePropertyAll(
                    //           Color.fromRGBO(56, 159, 140, 1)),
                    backgroundColor: MaterialStatePropertyAll(
                      (buttonEnabled.pauseButtonEnabled ||
                              buttonEnabled.startButtonEnabled)
                          ? Colors.blueGrey
                          : Colors.grey,
                    ),
                    fixedSize: MaterialStatePropertyAll(Size.fromWidth(100)),
                  ),
                  onPressed: buttonEnabled.pauseButtonEnabled ||
                          buttonEnabled.startButtonEnabled
                      ? () {
                          provider.executeDownloadCommand(
                            widget.downloadId,
                            DownloadCommand.cancel,
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              // SizedBox(width: resolveButtonsXMargin(size)),
              SizedBox(width: resolveButtonsXMargin(size)),
              Selector<DownloadRequestProvider, ButtonAvailability>(
                selector: (_, provider) =>
                    provider.downloads[widget.downloadId]!.buttonAvailability,
                builder: (context, buttonEnabled, child) =>
                    pauseOrResumeButton(provider, buttonEnabled),
              ),
            ],
          ),
          showDetails ? const SizedBox(height: 37) : Container(),
          Visibility(
            visible: showDetails,
            child: Container(
              height: resolveDetailsHeight(size),
              width: 620,
              decoration: BoxDecoration(
                border: Border.all(
                    color: theme.detailsContainerBorderColor, width: 2),
                color: theme.detailsContainerBackgroundColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Selector<DownloadRequestProvider,
                  List<DownloadProgressMessage>>(
                selector: (_, provider) =>
                    provider.downloads[widget.downloadId]!.connectionProgresses,
                builder: (_, progresses, __) {
                  return ListView.builder(
                    itemCount: progresses.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Selector<DownloadRequestProvider, String>(
                            selector: (_, provider) => provider
                                .downloads[widget.downloadId]!
                                .connectionProgresses[index]
                                .detailsStatus,
                            builder: (context, transferRate, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "(${(index + 1).toString()})  ",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    transferRate,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 13),
                          Column(
                            children: [
                              Selector<DownloadRequestProvider, double>(
                                selector: (_, provider) => provider
                                    .downloads[widget.downloadId]!
                                    .connectionProgresses[index]
                                    .downloadProgress,
                                builder: (context, progress, child) {
                                  return SizedBox(
                                    height: 10,
                                    width: 450,
                                    child: LinearProgressIndicator(
                                      color: Colors.lightGreen,
                                      backgroundColor: Colors.white,
                                      value: progress,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 2),
                              Selector<DownloadRequestProvider, double>(
                                selector: (_, provider) => provider
                                    .downloads[widget.downloadId]!
                                    .connectionProgresses[index]
                                    .totalRequestWriteProgress,
                                builder: (context, progress, child) {
                                  return SizedBox(
                                    height: 3,
                                    width: 450,
                                    child: LinearProgressIndicator(
                                      color: Colors.indigo,
                                      backgroundColor: Colors.white,
                                      value: progress,
                                    ),
                                  );
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget pauseOrResumeButton(
    DownloadRequestProvider provider,
    ButtonAvailability buttonAvailability,
  ) {
    if (buttonAvailability.pauseButtonEnabled) {
      return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
          fixedSize: const MaterialStatePropertyAll(Size.fromWidth(100)),
        ),
        onPressed: () => provider.executeDownloadCommand(
          widget.downloadId,
          DownloadCommand.pause,
        ),
        child: const Text(
          'Pause',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else if (buttonAvailability.startButtonEnabled) {
      return TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.green),
            fixedSize: const MaterialStatePropertyAll(Size.fromWidth(100))),
        onPressed: () => provider.executeDownloadCommand(
            widget.downloadId, DownloadCommand.start),
        child: const Text('Start', style: TextStyle(color: Colors.white)),
      );
    } else {
      return TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.grey),
            fixedSize: const MaterialStatePropertyAll(Size.fromWidth(100))),
        onPressed: null,
        child: const Text('Wait', style: TextStyle(color: Colors.white)),
      );
    }
  }

  double resolveButtonsXMargin(Size size) {
    double margin = 70;
    if (size.width < 835) {
      margin = 20;
    }
    if (size.width < 706) {
      margin = 10;
    }
    if (size.width < 663) {
      margin = 5;
    }
    return margin;
  }

  double resolveTextWidth(Size size) {
    double width = 670;
    if (size.width < 1175) {
      width = size.width * 0.7 - 100;
    }
    return width;
  }

  double resolveDetailsHeight(Size size) {
    double height = resolveWindowHeight(size) - 190;
    if (size.height <= 830) {
      height = size.height * 0.29;
    }
    if (size.height <= 805) {
      height = size.height * 0.26;
    }
    if (size.height <= 772) {
      height = size.height * 0.24;
    }
    if (size.height <= 752) {
      height = size.height * 0.22;
    }
    if (size.height <= 732) {
      height -= 20;
    }
    if (size.height <= 707) {
      height -= 20;
    }
    if (size.height <= 680) {
      height -= 20;
    }
    if (size.height <= 655) {
      height -= 30;
    }
    if (size.height < 620) {
      setState(() {
        showDetails = false;
        showDetailAvailable = false;
      });
    } else {
      setState(() {
        showDetailAvailable = true;
      });
    }
    return height;
  }

  double resolveStatusTextPadding(Size size) {
    double padding = 8;
    if (size.height < 524) {
      padding = 3;
    }
    if (size.height < 495) {
      padding = 1;
    }
    if (size.height < 482) {
      padding = 0;
    }
    return padding;
  }

  double resolveWindowWidth(Size size) {
    double width = size.width * 0.7;
    if (size.width > 1202) {
      width = 840;
    }
    return width;
  }

  double resolveWindowHeight(Size size) {
    print(size.height);
    if (size.height >= 650) {
      return 450;
    }
    return 450;
  }

  double resolveButtonsYMargin(Size size) {
    if (size.height < 535) {
      return 20;
    }
    if (size.height < 525) {
      return 10;
    }
    return 30;
  }

  Widget statusTextPadding(Size size) {
    return SizedBox(height: resolveStatusTextPadding(size));
  }
}
