import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/setting/base/settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool telegramHover = false;
  bool discordHover = false;
  bool githubHover = false;
  bool donationHover = false;

  @override
  Widget build(BuildContext context) {
    final theme =
        Provider
            .of<ThemeProvider>(context)
            .activeTheme
            .settingTheme
            .pageTheme;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
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
            height: 450,
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
              const SizedBox(height: 20),
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     const SizedBox(width: 3),
              //     SvgPicture.asset(
              //       "assets/icons/github.svg",
              //       height: 35,
              //       width: 35,
              //       colorFilter: ColorFilter.mode(
              //         theme.widgetColor.aboutIconColor,
              //         BlendMode.srcIn,
              //       ),
              //     ),
              //     const SizedBox(width: 30),
              //     InkWell(
              //         onTap: () =>
              //             launchUrlString("https://github.com/AminBhst"),
              //         child: Text(
              //           "AminBhst",
              //           style: TextStyle(
              //             color: theme.titleTextColor,
              //           ),
              //         )),
              //   ],
              // ),
              // const SizedBox(height: 30),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 3),
                  Icon(
                    Icons.attach_money_rounded,
                    color: theme.widgetColor.aboutIconColor,
                    size: 35,
                  ),
                  const SizedBox(width: 30),
                  InkWell(
                    onTap: () =>
                        launchUrlString(
                            "https://github.com/AminBhst/brisk?tab=readme-ov-file#money_with_wings-donations"),
                    onHover: (val) => setState(() => donationHover = val),
                    child: Text(
                      "Donate",
                      style: TextStyle(
                          color: donationHover
                              ? Colors.blue
                              : theme.titleTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                        launchUrlString("https://github.com/AminBhst/Brisk"),
                    onHover: (val) => setState(() => githubHover = val),
                    child: Text(
                      "AminBhst/Brisk",
                      style: TextStyle(
                          color: githubHover
                              ? Colors.blue
                              : theme.titleTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 3),
                  SvgPicture.asset(
                    "assets/icons/discord.svg",
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
                        launchUrlString("https://discord.gg/hGBDWNDHG3"),
                    onHover: (val) => setState(() => discordHover = val),
                    child: Text(
                      "Discord Server",
                      style: TextStyle(
                          color: discordHover
                              ? Colors.blue
                              : theme.titleTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 3),
                  SvgPicture.asset(
                    "assets/icons/telegram.svg",
                    height: 35,
                    width: 35,
                    colorFilter: ColorFilter.mode(
                      theme.widgetColor.aboutIconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 30),
                  InkWell(
                    onTap: () => launchUrlString("https://t.me/ryedev"),
                    onHover: (val) => setState(() => telegramHover = val),
                    child: Text(
                      "Telegram Channel",
                      style: TextStyle(
                          color: telegramHover
                              ? Colors.blue
                              : theme.titleTextColor),
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
