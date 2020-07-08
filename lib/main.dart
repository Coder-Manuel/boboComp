import 'package:bobocomp/authentication.dart';
import 'package:bobocomp/components/companies_register.dart.dart';
import 'package:bobocomp/modules/club_module.dart';
import 'package:bobocomp/root_page.dart';
//import 'package:bobo_ui/taxi/lib/screens/home.dart';
//import 'package:bobo_ui/taxi/lib/states/app_state.dart';
import 'package:bobocomp/ui/company_ui.dart';
import 'package:bobocomp/ui/ticket_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bobocomp/settings/settings_page.dart';
// import 'package:bobo_ui/crew/views/home_screen.dart';
import 'package:bobocomp/crew/views/chatrooms.dart';
import 'package:bobocomp/taxi/screens/home.dart';
import 'package:bobocomp/crew/helper/helperfunctions.dart';
import 'taxi/states/app_state.dart';
import 'package:bobocomp/crew/crew.dart';

//void main() {
//  WidgetsFlutterBinding.ensureInitialized();
//  return runApp
//    (
//
//      MultiProvider(
//                        providers: [
//                                     ChangeNotifierProvider.value(value: AppState(),)
//                                   ],
//                         child: MyApp(),
//
//
//      )
//  );
//}
void main() {
  return runApp(MultiProvider(
    providers: [ChangeNotifierProvider.value(value: new AppState())],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bobo App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Color(0xFF707070),
      ),
      home: MultiProvider(providers: [
        ChangeNotifierProvider<ClubModule>(
          create: (context) => ClubModule(),
        ),
        ChangeNotifierProvider.value(
          value: AppState(),
        )
        // ChangeNotifierProvider<CompanyModule>(builder: (context)=> CompanyModule(),),
        // ChangeNotifierProvider<EventModule>(builder: (context)=> EventModule(),),
        // ChangeNotifierProvider<TicketManagerModule>(builder: (context)=> TicketManagerModule(),),
      ], child: RootPage()),
      // home: ChangeNotifierProvider<ClubModule>(
      //   builder: (context)=> ClubModule(),
      //   child: Consumer<ClubModule>(
      //     builder: (context, clubModule, _){
      //       return GoogleMapPage();
      //     },
      //   ),
      // ),
      routes: <String, WidgetBuilder>{
        //'/taxi':(BuildContext context) => MyHomePage(title: 'BOBO Taxi'),
        '/club': (BuildContext context) => ClubsPage(),
        '/taxi': (BuildContext context) => MyTaxiPage(),
        '/crew': (BuildContext context) => MyCrew(),
        '/company': (BuildContext context) => CompanyUi(),
        '/logout': (BuildContext context) => RootPage(),
        '/tickets': (BuildContext context) => TicketPage(),
        '/payment': (BuildContext context) => PaymentPage(),
        '/reservation': (BuildContext context) => ReservationPage(),
        '/settings': (BuildContext context) => SettingsPage(),
      },
    );
  }
}

class ClubsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text("ClubsPage"),
      ),
    );
  }
}

class EventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RegisterCompany();
  }
}

// class CrewPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: Center(child: Text("crew"),),
//     );
//   }
// }
class TaxiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text("taxi"),
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text("payment"),
      ),
    );
  }
}

class ReservationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text("reservation"),
      ),
    );
  }
}
// class SettingsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: Center(child: Text("settings"),),
//     );
//   }
// }
