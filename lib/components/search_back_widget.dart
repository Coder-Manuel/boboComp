import 'package:bobocomp/modules/club_module.dart';
import 'package:flutter/material.dart';
import 'package:bobocomp/helper/ui_helper.dart';
import 'package:provider/provider.dart';

class SearchBackWidget extends StatelessWidget {
  final double currentSearchPercent;

  final Function(bool) animateSearch;

  SearchBackWidget({this.currentSearchPercent, this.animateSearch});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: realH(53),
      right: realW(27),
      child: Opacity(
        opacity: currentSearchPercent,
        child: Container(
          width: realW(320),
          height: realH(71),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: realW(17)),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  animateSearch(false);
                },
                child: Transform.scale(
                  scale: currentSearchPercent,
                  child: Icon(
                    Icons.arrow_back,
                    size: realW(34),
                  ),
                ),
              ),
              Consumer<ClubModule>(builder: (context, _clubModule, _) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: realW(30.0)),
                    child: TextField(
                      enabled: currentSearchPercent == 1.0,
                      cursorColor: Color(0xFF707070),
                      decoration: InputDecoration(
                        hintText: "Search here",
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: realW(22)),
                      onChanged: (String _txt) {
                        _clubModule.searchClubs(_txt);
                      },
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
