

import 'package:bobocomp/components/add_reservation_ui.dart';
import 'package:bobocomp/modals/club_modal.dart';
import 'package:bobocomp/modules/club_module.dart';
import 'package:bobocomp/modules/event_module.dart';
import 'package:bobocomp/modules/reservation_module.dart';
import 'package:bobocomp/modules/user_module.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClubDetailPage extends StatelessWidget {
  final String clubId;

  ClubDetailPage({
    this.clubId
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => ClubModule()),
        ChangeNotifierProvider(builder: (context) => UserModule()),
        ChangeNotifierProvider(builder: (context) => ReservationModule()),
      ],  
      child: Scaffold(
        body: SingleChildScrollView(
                  child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // club Name and Image
              clubLabel(context),
              ClubDetailBody(clubId:clubId),
            ],
          ),
        ),
      ),
    );
  }

  Widget clubLabel(BuildContext context) {
    return Consumer<ClubModule>(
      builder: (context, clubModule, _){
      ClubModal _club = clubModule.getClub(clubId);
      return Container(
        height: MediaQuery.of(context).size.height*.3,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          // fit: StackFit.expand,
          children: <Widget>[
            // Club image
            Container(width: double.infinity, child: _club.image != null ? Image.network(_club.image , fit: BoxFit.cover,): null),

            // Club name
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(30))
                ),
                child: Text(
                  _club.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      }
    );
  }
}

class ClubDetailBody extends StatefulWidget {

  final String clubId;

  ClubDetailBody({
    this.clubId
  });


  @override
  _ClubDetailBodyState createState() => _ClubDetailBodyState();
}

class _ClubDetailBodyState extends State<ClubDetailBody> with SingleTickerProviderStateMixin {
  

  TabController _tabController;

  TextStyle tabTitleStyle(){
    return TextStyle(
      color: Colors.black
    );
  }

    @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height*.7,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: <Widget>[
              Tab(child: Text("Reservation", style: tabTitleStyle(),),),
              Tab(child: Text("Events", style: tabTitleStyle(),),),
              Tab(child: Text("Gallery", style: tabTitleStyle(),),),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                // Add Reservation Tab
                AddReservationUI(clubId: widget.clubId),

                // Events Tab
                ClubEvents(clubId: widget.clubId,),

                // Gallery
                ClubGallery(widget.clubId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ClubGallery extends StatelessWidget {
  final String clubId;
  ClubGallery(this.clubId);

  List<String> _gallery;


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context) => ClubModule(),
      child: Consumer<ClubModule>(
        builder: (context, clubModule, _){
          ClubModal _club = clubModule.getClub(clubId);
          _club.gallery == null ? _gallery = <String>[] : _gallery = _club.gallery;
            
          return GridView.builder(
            gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: _gallery.length,
            itemBuilder: (BuildContext context, int index){
              return SizedBox(
                  height: 140,
                  width: 140,
                  child: Card(
                    child: _gallery[index] == null ? 
                    Container() : 
                    InkWell(
                      child: Image.network(_gallery[index],  fit: BoxFit.cover,),
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (context){
                            PageController _pageController = PageController(
                              initialPage: index
                            );
                            return SimpleDialog(
                              backgroundColor: Colors.transparent,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: Icon(Icons.close, size: 33, color: Colors.white,),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                                
                                Container(
                                  color: Colors.transparent,
                                  height: MediaQuery.of(context).size.height - 100,
                                  width: MediaQuery.of(context).size.width,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: _gallery.length,
                                    itemBuilder: (BuildContext context, int index){
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            color: Colors.transparent,
                                            child: Image.network(_gallery[index], fit: BoxFit.scaleDown,),
                                          ),
                                          SizedBox(height: 15,),
                                          Text(
                                            '${index+1}/${_gallery.length}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontStyle: FontStyle.italic
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ),
                               
                              ],
                            );
                          }
                        );
                      },
                    )
                        
                    
                  ),
                );
            },
          );
       }
      ),
    );
  }
}


class ClubEvents extends StatefulWidget {
  ClubEvents({this.clubId});
  final String clubId;

  @override
  _ClubEventsState createState() => _ClubEventsState();
}

class _ClubEventsState extends State<ClubEvents> {
  List _events = [];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: EventModule(),
      child: Consumer<EventModule>(
        builder: (context, _eventsModule, _){
          _eventsModule.currenClubEvents(widget.clubId).then((value){
            setState(() {
              _events = value;
            });
          });
          return ListView.builder(
            itemCount: _events.length,
            itemBuilder: (BuildContext context, int index){
              return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(_events[index].title),
                    Image.network( _events[index].image.toString(), height: 200, width: MediaQuery.of(context).size.width - 30, fit: BoxFit.fitWidth,),
                    SizedBox(height: 5,),
                    Text(_events[index].description),
                    SizedBox(height: 15,),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}