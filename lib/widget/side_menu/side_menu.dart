import 'package:brisk/constants/download_status.dart';
import 'package:brisk/constants/file_type.dart';
import 'package:brisk/provider/pluto_grid_state_manager_provider.dart';
import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/widget/setting/settings_window.dart';
import 'package:brisk/widget/side_menu/side_menu_expansion_tile.dart';
import 'package:brisk/widget/side_menu/side_menu_item.dart';
import 'package:brisk/widget/side_menu/side_menu_list_tile_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.2,
      height: double.infinity,
      color: const Color.fromRGBO(55, 64, 81, 1),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left : 10, top: 30),
              child: SvgPicture.asset(
                "assets/icons/logo.svg",
                height: 25,
                width: 25,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 20),
            SideMenuExpansionTile(
              title: 'Downloads',
              icon: const Icon(
                Icons.download_rounded,
                color: Colors.white,
              ),
              onTap: PlutoGridStateManagerProvider.removeFilters,
              children: [
                SideMenuListTileItem(
                  text: 'Music',
                  icon: SvgPicture.asset(
                    'assets/icons/music.svg',
                    color: Colors.cyanAccent,
                  ),
                  onTap: () => setGridFileTypeFilter(DLFileType.music),
                ),
                SideMenuListTileItem(
                  text: 'Videos',
                  icon: SvgPicture.asset(
                    'assets/icons/video.svg',
                    color: Colors.pinkAccent,
                  ),
                  onTap: () => setGridFileTypeFilter(DLFileType.video),
                ),
                SideMenuListTileItem(
                  text: 'Documents',
                  icon: SvgPicture.asset(
                    'assets/icons/document.svg',
                    color: Colors.orangeAccent,
                  ),
                  onTap: () => setGridFileTypeFilter(DLFileType.documents),
                ),
                SideMenuListTileItem(
                  text: 'Programs',
                  icon: SvgPicture.asset(
                    'assets/icons/program.svg',
                    // color: Color.fromRGBO(65, 21, 48, 1),
                    color : const Color.fromRGBO(245, 139, 84, 1),
                  ),
                  size: 30,
                  onTap: () => setGridFileTypeFilter(DLFileType.program),
                ),
                SideMenuListTileItem(
                  text: 'Archive',
                  icon: SvgPicture.asset(
                    'assets/icons/archive.svg',
                    color: Colors.lightBlue,
                  ),
                  size: 32,
                  onTap: () => setGridFileTypeFilter(DLFileType.compressed),
                )
              ],
            ),
            SideMenuItem(
              onTap: setUnfinishedGridFilter,
              leading: SvgPicture.asset(
                'assets/icons/unfinished.svg',
                color: Colors.white,
              ),
              // trailing: Consumer<DownloadRequestProvider>(
              //   builder: (context, provider, child) {
              //     return NumberBadge(
              //       color: Colors.red,
              //       number: provider.numberOfUnfinishedDownloads.toString(),
              //     );
              //   },
              // ),
              trailing: null,
              // builder: (context, provider, child) ),
              title: "Unfinished",
            ),
            SideMenuItem(
              onTap: setFinishedFilter,
              leading: const Icon(
                Icons.download_done_rounded,
                color: Colors.white,
              ),
              trailing: null,
              // trailing: Consumer<DownloadRequestProvider>(
              //   builder: (context, provider, child) {
              //     return NumberBadge(
              //       color: Colors.green,
              //       number: provider.numberOfCompletedDownloads.toString(),
              //     );
              //   },
              // ),
              title: "Finished",
            ),
            // const SideMenuExpansionTile(
            //   icon: Icon(Icons.queue, color: Colors.white),
            //   title: 'Queues',
            //   onTap: null,
            //   children: [],
            // ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(50),
              child: IconButton(
                iconSize: 30,
                  onPressed: () => onSettingPressed(context),
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void onSettingPressed(BuildContext context) {
    Provider.of<SettingsProvider>(context, listen: false).selectedTabId = 0;
    showDialog(
      context: context,
      builder: (context) => const SettingsWindow(),
      barrierDismissible: false,
    );
  }

  void setGridFileTypeFilter(DLFileType fileType) {
    PlutoGridStateManagerProvider.setFilter("file_type", fileType.name);
  }

  void setUnfinishedGridFilter() {
    PlutoGridStateManagerProvider.setFilter("status", DownloadStatus.complete,
        negate: true);
  }

  void setFinishedFilter() {
    PlutoGridStateManagerProvider.setFilter("status", DownloadStatus.complete);
  }

  bool minimizedSideMenu(Size size) => size.width < 1300;
}
