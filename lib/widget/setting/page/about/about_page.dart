import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider.of<ThemeProvider>(context).activeTheme.settingTheme.pageTheme;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SettingsGroup(title: "Info", height: 100, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 5),
                  Icon(
                    Icons.info_outline,
                    color: theme.widgetColor.aboutIconColor,
                    size: 30,
                  ),
                  const SizedBox(width: 30),
                  Text(
                    "Version: ${SettingsCache.currentVersion}",
                    style: TextStyle(color: theme.titleTextColor),
                  ),
                ],
              )
            ]),
            SettingsGroup(
              height: 300,
              title: "Developer",
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 5),
                    Icon(
                      Icons.person,
                      color: theme.widgetColor.aboutIconColor,
                      size: 30,
                    ),
                    const SizedBox(width: 30),
                    Text(
                      "Amin Beheshti",
                      style: TextStyle(color: theme.titleTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 5),
                    Icon(
                      Icons.email,
                      color: theme.widgetColor.aboutIconColor,
                      size: 30,
                    ),
                    const SizedBox(width: 30),
                    Text(
                      "amin.bhst@gmail.com",
                      style: TextStyle(color: theme.titleTextColor),
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
                      colorFilter: ColorFilter.mode(
                        theme.widgetColor.aboutIconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 30),
                    InkWell(
                        onTap: () =>
                            launchUrlString("https://github.com/AminBhst"),
                        child: Text(
                          "AminBhst",
                          style: TextStyle(
                            color: theme.titleTextColor,
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
                      colorFilter: ColorFilter.mode(
                        theme.widgetColor.aboutIconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 30),
                    InkWell(
                        onTap: () => launchUrlString(
                            "https://github.com/AminBhst/Brisk"),
                        child: Text(
                          "AminBhst/Brisk",
                          style: TextStyle(
                            color: theme.titleTextColor,
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
