import 'package:bobocomp/components/club_detailPage.dart';
import 'package:bobocomp/modules/club_module.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bobocomp/helper/ui_helper.dart';
import 'package:provider/provider.dart';

class RecentSearchWidget extends StatelessWidget {
  final double currentSearchPercent;

  const RecentSearchWidget({Key key, this.currentSearchPercent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return currentSearchPercent != 0
        ? Positioned(
            top: realH(
                -(75.0 + 494.0) + (75 + 75.0 + 494.0) * currentSearchPercent),
            left: realW((standardWidth - 320) / 2),
            width: realW(320),
            height: realH(494),
            child: Opacity(
              opacity: currentSearchPercent,
              child: Consumer<ClubModule>(builder: (context, _clubModule, _) {
                return Align(
                    alignment: Alignment.topCenter,
                    child: StreamBuilder(
                        stream: _clubModule.searchedClubs,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.data == null) {
                            return Container();
                          } else {
                            List<DocumentSnapshot> _docs =
                                snapshot.data.documents;
                            return ListView.builder(
                              itemCount: _docs == null ? 0 : _docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: ListTile(
                                    title: Text(_docs[index].data['name']),
                                    onTap: () {
                                      String _id = _docs[index].documentID;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ClubDetailPage(clubId: _id)));
                                    },
                                  ),
                                );
                              },
                            );
                          }
                        }));
              }),
            ),
          )
        : const Padding(
            padding: const EdgeInsets.all(0),
          );
  }
}
