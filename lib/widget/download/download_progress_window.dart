import 'package:brisk/constants/download_command.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/util/readability_util.dart';
import 'package:brisk/widget/base/closable_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/download_progress.dart';

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
    final size = MediaQuery.of(context).size;
    final downloadProgress = provider.downloads[widget.downloadId]!;
    return ClosableWindow(
      width: size.width * 0.7,
      height: showDetails ? resolveWindowHeight(size) + 260 : resolveWindowHeight(size),
      content: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('File Name :  ',
                  style: TextStyle(color: Colors.white)),
              SizedBox(
                width: 670,
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
              const Text('URL : ', style: TextStyle(color: Colors.white)),
              SizedBox(
                width: 670,
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
              const Text('Size : ', style: TextStyle(color: Colors.white)),
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
              const Text('Progress : ', style: TextStyle(color: Colors.white)),
              Selector<DownloadRequestProvider, double>(
                selector: (_, provider) =>
                    provider.downloads[widget.downloadId]!.downloadProgress,
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
                builder: (context, transferRate, child) => Text(transferRate,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          statusTextPadding(size),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Status : ', style: TextStyle(color: Colors.white)),
              Selector<DownloadRequestProvider, String>(
                selector: (_, provider) =>
                    provider.downloads[widget.downloadId]!.status,
                builder: (context, status, child) =>
                    Text(status, style: const TextStyle(color: Colors.white)),
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
                selector: (_, provider) =>
                    provider.downloads[widget.downloadId]!.estimatedRemaining,
                builder: (context, estimatedRemaining, child) => Text(
                    estimatedRemaining,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
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
          SizedBox(height: resolveButtonMargin(size)),
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
                          showDetailAvailable
                              ? Colors.blueGrey
                              : Colors.grey)),
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
                  )),
              const SizedBox(width: 50),
              TextButton(
                style: const ButtonStyle(
                    // backgroundColor: MaterialStatePropertyAll(
                    //           Color.fromRGBO(56, 159, 140, 1)),
                  backgroundColor: MaterialStatePropertyAll(Colors.blueGrey),
                    fixedSize:  MaterialStatePropertyAll(
                        Size.fromWidth(90))),
                onPressed: () {
                  provider.executeDownloadCommand(widget.downloadId, DownloadCommand.cancel);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 50),
              Selector<DownloadRequestProvider, bool>(
                  selector: (_, provider) =>
                      provider.downloads[widget.downloadId]!.pauseButtonEnabled,
                  builder: (context, buttonEnabled, child) => TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                buttonEnabled
                                    ? Colors.redAccent
                                    : Colors.grey),
                            fixedSize: const MaterialStatePropertyAll(
                                Size.fromWidth(90))),
                        onPressed: buttonEnabled
                            ? () => provider.executeDownloadCommand(
                                widget.downloadId, DownloadCommand.pause)
                            : null,
                        child: const Text(
                          'Pause',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
              const SizedBox(width: 50),
              Selector<DownloadRequestProvider, bool>(
                  selector: (_, provider) =>
                      provider.downloads[widget.downloadId]!.startButtonEnabled,
                  builder: (context, buttonEnabled, child) => TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              buttonEnabled
                                  // ? const Color.fromRGBO(56, 159, 140, 1)
                              ? Colors.green
                                  : Colors.grey),
                          fixedSize: const MaterialStatePropertyAll(
                              Size.fromWidth(90))),
                      onPressed: buttonEnabled
                          ? () => provider.executeDownloadCommand(
                              widget.downloadId, DownloadCommand.start)
                          : null,
                      child: const Text('Start',
                          style: TextStyle(color: Colors.white)))),
            ],
          ),
          showDetails ? const SizedBox(height: 37) : Container(),
          Visibility(
            visible: showDetails,
            child: Container(
              height: resolveDetailsHeight(size),
              width: 620,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87, width: 2),
                color: const Color.fromRGBO(45, 45, 45, 1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Selector<DownloadRequestProvider, List<DownloadProgress>>(
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
                                  Text("(${(index + 1).toString()})  ", style: const TextStyle(color: Colors.white),),
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
                                    .writeProgress,
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

  double resolveDetailsHeight(Size size) {
    double height = size.height * 0.30;
    if (size.height < 990) {
      height = size.height * 0.27;
    }
    if (size.height < 850) {
      height = size.height * 0.24;
    }
    if (size.height < 750) {
      height = size.height * 0.19;
    }
    if (size.height < 710) {
      height = size.height * 0.16;
    }
    if (size.height < 680) {
      height = size.height * 0.1;
    }
    if (size.height < 650) {
      height = size.height * 0.06;
    }
    if (size.height < 640) {
      setState(() => showDetails = false);
    }
    return height;
  }

  double resolveStatusTextPadding(Size size) {
    double padding = 8;
    if (size.height < 480) {
      padding = 3;
    }
    if (size.height < 450) {
      padding = 1;
    }
    if (size.height < 420) {
      padding = 0;
    }
    return padding;
  }

  double resolveWindowHeight(Size size) {
    double height = size.height * 0.53;
    if (size.height < 800) {
      height = size.height * 0.7;
    }
    if (size.height < 700) {
      height = size.height * 0.85;
    } else {
      setState(() => showDetailAvailable = true);
    }
    if (size.height < 630) {
      setState(() => showDetailAvailable = false);
    }
    if (size.height < 600) {
      height = size.height * 0.9;
    }
    if (size.height < 550) {
      height = size.height * 0.99;
    }
    if (size.height < 500) {
      height = size.height;
    }
    return height;
  }

  double resolveButtonMargin(Size size) {
    double margin = 65;
    if (size.height < 850) {
      margin = 50;
    }
    if (size.height < 600) {
      margin = 30;
    }
    if (size.height < 500) {
      margin = 15;
    }
    if (size.height < 400) {
      margin = 10;
    }
    if (size.height < 370) {
      margin = 5;
    }
    if (size.height < 350) {
      margin = 2;
    }
    return margin;
  }

  Widget statusTextPadding(Size size) {
    return SizedBox(height: resolveStatusTextPadding(size));
  }
}
