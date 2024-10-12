import 'package:brisk/download_engine/download_status.dart';
import 'package:brisk/constants/file_type.dart';
import 'package:brisk/provider/pluto_grid_util.dart';
import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/util/responsive_util.dart';
import 'package:brisk/widget/setting/settings_window.dart';
import 'package:brisk/widget/side_menu/side_menu_expansion_tile.dart';
import 'package:brisk/widget/side_menu/side_menu_item.dart';
import 'package:brisk/widget/side_menu/side_menu_list_tile_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../provider/queue_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context);
    final sideMenuTheme =
        Provider.of<ThemeProvider>(context).activeTheme.sideMenuTheme;
    final size = MediaQuery.of(context).size;
    return Container(
      width: resolveSideMenuWidth(size),
      height: double.infinity,
      color: sideMenuTheme.backgroundColor,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 30),
              child: SvgPicture.asset(
                "assets/icons/logo.svg",
                height: 25,
                width: 25,
                colorFilter: ColorFilter.mode(
                  sideMenuTheme.briskLogoColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SideMenuExpansionTile(
              title: 'Downloads',
              icon: const Icon(
                Icons.download_rounded,
                color: Colors.white,
              ),
              onTap: () => onDownloadsPressed(queueProvider),
              children: [
                SideMenuListTileItem(
                  text: 'Music',
                  icon: SvgPicture.asset(
                    'assets/icons/music.svg',
                    colorFilter:
                        ColorFilter.mode(Colors.cyanAccent, BlendMode.srcIn),
                  ),
                  onTap: () => setGridFileTypeFilter(DLFileType.music),
                ),
                SideMenuListTileItem(
                  text: 'Videos',
                  icon: SvgPicture.asset(
                    'assets/icons/video.svg',
                    colorFilter:
                        ColorFilter.mode(Colors.pinkAccent, BlendMode.srcIn),
                  ),
                  onTap: () => setGridFileTypeFilter(DLFileType.video),
                ),
                SideMenuListTileItem(
                  text: 'Documents',
                  icon: SvgPicture.asset(
                    'assets/icons/document.svg',
                    colorFilter:
                        ColorFilter.mode(Colors.orangeAccent, BlendMode.srcIn),
                  ),
                  onTap: () => setGridFileTypeFilter(DLFileType.documents),
                ),
                SideMenuListTileItem(
                  text: 'Programs',
                  icon: SvgPicture.asset(
                    'assets/icons/program.svg',
                    colorFilter: ColorFilter.mode(
                        const Color.fromRGBO(245, 139, 84, 1), BlendMode.srcIn),
                  ),
                  size: 30,
                  onTap: () => setGridFileTypeFilter(DLFileType.program),
                ),
                SideMenuListTileItem(
                  text: 'Archive',
                  icon: SvgPicture.asset(
                    'assets/icons/archive.svg',
                    colorFilter:
                        ColorFilter.mode(Colors.lightBlue, BlendMode.srcIn),
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
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              title: "Unfinished",
            ),
            SideMenuItem(
              onTap: setFinishedFilter,
              leading: const Icon(
                Icons.download_done_rounded,
                color: Colors.white,
              ),
              title: "Finished",
            ),
            SideMenuItem(
              onTap: () => onQueueTabPressed(queueProvider),
              leading: Icon(Icons.queue, color: Colors.white),
              title: "Queues",
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
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

  void onDownloadsPressed(QueueProvider queueProvider) {
    PlutoGridUtil.removeFilters();
    PlutoGridUtil.cachedRows.clear();
    queueProvider.setQueueTopMenu(false);
    queueProvider.setSelectedQueue(null);
    queueProvider.setQueueTabSelected(false);
    queueProvider.setDownloadQueueTopMenu(false);
  }

  void onQueueTabPressed(QueueProvider queueProvider) {
    PlutoGridUtil.plutoStateManager?.removeAllRows();
    PlutoGridUtil.cachedRows.clear();
    queueProvider.setQueueTopMenu(true);
    queueProvider.setQueueTabSelected(true);
    queueProvider.setSelectedQueue(null);
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
    PlutoGridUtil.setFilter("file_type", fileType.name);
  }

  void setUnfinishedGridFilter() {
    PlutoGridUtil.setFilter("status", DownloadStatus.assembleComplete,
        negate: true);
  }

  void setFinishedFilter() {
    PlutoGridUtil.setFilter("status", DownloadStatus.assembleComplete);
  }
}
