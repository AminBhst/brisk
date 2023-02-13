import 'package:flutter/material.dart';

class SideMenuExpansionTile extends StatelessWidget {
  final List<Widget> children;
  final String title;
  final Widget icon;
  final VoidCallback? onTap;

  const SideMenuExpansionTile({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.2,
      child: ExpansionTile(
        backgroundColor: Colors.blueGrey,
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
          onTap: onTap,
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
                    child: icon,
                  ),
                ),
                minimizedSideMenu(size)
                    ? Container()
                    : Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                    )
              ],
            ),
          ),
        ),
        children: children,
      ),
    );
  }

  bool minimizedSideMenu(Size size) => size.width < 1300;
}
