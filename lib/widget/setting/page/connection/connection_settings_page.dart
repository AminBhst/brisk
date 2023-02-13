import 'package:brisk/widget/setting/page/connection/connection_number_group.dart';
import 'package:brisk/widget/setting/page/connection/connection_retry_group.dart';
import 'package:flutter/material.dart';

class ConnectionSettingsPage extends StatelessWidget {
  const ConnectionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            ConnectionRetryGroup(),
            ConnectionNumberGroup(),
          ],
        ),
      ),
    );
  }
}
