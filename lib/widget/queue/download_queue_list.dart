import 'package:brisk/widget/queue/queue_details_window.dart';
import 'package:flutter/material.dart';

class DownloadQueueList extends StatelessWidget {
  const DownloadQueueList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: size.height - 70,
        width: size.width * 0.8,
        color: Color.fromRGBO(40, 46, 58, 1),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: ListTile(
                // onTap: () => onDetailsTap(context),
                leading: Icon(Icons.queue_rounded, color: Colors.white38,),
                title: Text("Main", style: TextStyle(color: Colors.white)),
                subtitle: Text("5 Downloads in queue",
                    style: TextStyle(color: Colors.grey)),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon:
                            Icon(Icons.more_vert_rounded, color: Colors.white),
                        onPressed: () => onDetailsTap(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onDetailsTap(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QueueDetailsWindow(),
    );
  }
}
