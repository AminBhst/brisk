import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SettingsGroup(
              height: 500,
              title: "Developer",
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    SizedBox(width: 5),
                    Icon(Icons.person, color: Colors.white70, size: 30),
                    SizedBox(width: 30),
                    Text(
                      "Amin Beheshti",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    SizedBox(width: 5),
                    Icon(
                      Icons.email,
                      color: Colors.white70,
                      size: 30,
                    ),
                    SizedBox(width: 30),
                    Text(
                      "amin.bhst@gmail.com",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 3),
                    SvgPicture.asset(
                      "assets/icons/github.svg",
                      height: 35,
                      width: 35,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 30),
                    InkWell(
                        onTap: () => launchUrlString("https://github.com/AminBhst"),
                        child: const Text(
                          "AminBhst",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 3),
                    SvgPicture.asset(
                      "assets/icons/github.svg",
                      height: 35,
                      width: 35,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: 30),
                    InkWell(
                        onTap: () => launchUrlString("https://github.com/AminBhst/Brisk"),
                        child: const Text(
                          "AminBhst/Brisk",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
