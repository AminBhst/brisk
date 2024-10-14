import 'package:brisk/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideMenuExpansionTile extends StatefulWidget {
  final List<Widget> children;
  final String title;
  final Widget icon;
  final VoidCallback? onTap;
  final active;

  const SideMenuExpansionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.onTap,
    this.active = false,
  });

  @override
  State<SideMenuExpansionTile> createState() => _SideMenuExpansionTileState();
}

class _SideMenuExpansionTileState extends State<SideMenuExpansionTile> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sideMenuTheme =
        Provider.of<ThemeProvider>(context).activeTheme.sideMenuTheme;
    return Container(
      width: 150,
      color:
          widget.active ? sideMenuTheme.activeTabBackgroundColor : Colors.transparent,
      child: ExpansionTile(
        shape: Border.all(color: Colors.transparent),
        backgroundColor: sideMenuTheme.expansionTileExpandedColor,
        // title: ListTile(
        //   onTap: onTap,
        //   leading: Padding(
        //     padding: EdgeInsets.only(left: minimizedSideMenu(size) ? 83.0 : 4),
        //     child: SizedBox(
        //       width: 20,
        //       height: 20,
        //       child: icon,
        //     ),
        //   ),
        //   title: minimizedSideMenu(size)
        //       ? null
        //       : Text(
        //           title,
        //           style: const TextStyle(
        //             color: Colors.white,
        //             fontSize: 18,
        //           ),
        //         ),
        // ),
        title: InkWell(
          onTap: widget.onTap,
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: minimizedSideMenu(size)
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: minimizedSideMenu(size) ? 30 : 20),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: widget.icon,
                  ),
                ),
                minimizedSideMenu(size)
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      )
              ],
            ),
          ),
        ),
        children: widget.children,
      ),
    );
  }

  bool minimizedSideMenu(Size size) => true;
  // bool minimizedSideMenu(Size size) => size.width < 1300;
}
