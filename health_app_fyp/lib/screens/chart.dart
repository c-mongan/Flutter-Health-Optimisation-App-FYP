import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:health_app_fyp/MoodTracker/moodIcon.dart';
import 'package:health_app_fyp/screens/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:pie_chart/pie_chart.dart';

import '../model/user_model.dart';

class ChartSlider extends StatefulWidget {
  const ChartSlider({Key? key}) : super(key: key);

//At the moment , error thrown if there is no mood data

  static String id = 'chartSlider';

  @override
  _ChartState createState() => _ChartState();
}

User? user = FirebaseAuth.instance.currentUser;
UserModel loggedInUser = UserModel();

class _ChartState extends State<ChartSlider> {
  int key = 0;

  late List<num> _xValues;
  late List<num> _yValues;
  List<double> _xPointValues = <double>[];
  List<double> _yPointValues = <double>[];

  TooltipBehavior? _tooltipBehavior;
  @override
  void initState() {
    super.initState();
    _tooltipBehavior =
        TooltipBehavior(enable: true, header: '', canShowMarker: false);

    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());

      if (mounted) {
        // check whether the state object is in tree
        getDataFromFireStore().then((results) {
          SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
            setState(() {});
          });
        });
        setPage();
      }
    });
  }

  void asyncMethod(bool isVisible) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());

      if (mounted) {

        getDataFromFireStore().then((results) {
          SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
            setState(() {});
          });
        });
        setPage();
      }
    });
  }

  var today = DateTime.now();

  late List<Mood> _moods = [];

  List<_ChartData> chartData = <_ChartData>[];
  Map<String, double> getMoodData() {
    

    Map<String, double> catMap = {};

    for (var item in _moods) {
      if (catMap.containsKey(item.mood) == false) {
        catMap[item.mood] = 1;
      } else {
        catMap.update(item.mood, (int) => catMap[item.mood]! + 1);
      }
    }
    return catMap;
  }

  final gradientList = <List<Color>>[
    [
      const Color.fromRGBO(223, 250, 92, 1),
      const Color.fromRGBO(129, 250, 112, 1),
    ],
    [
      const Color.fromRGBO(129, 182, 205, 1),
      const Color.fromRGBO(91, 253, 199, 1),
    ],
    [
      const Color.fromRGBO(175, 63, 62, 1.0),
      const Color.fromRGBO(254, 154, 92, 1),
    ]
  ];

  List<Color> colorList = [
    const Color.fromRGBO(82, 98, 255, 1),
    const Color.fromARGB(255, 77, 46, 255),
    const Color.fromRGBO(123, 201, 82, 1),
    const Color.fromRGBO(255, 171, 67, 1),
    const Color.fromRGBO(252, 91, 57, 1),
    const Color.fromRGBO(139, 135, 130, 1),
  ];

  Widget pieChartExampleOne() {
    return PieChart(
      key: ValueKey(key),
      dataMap: getMoodData(),
      initialAngleInDegree: 0,
      animationDuration: const Duration(milliseconds: 2000),
      chartType: ChartType.ring,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      ringStrokeWidth: 32,
      
      chartLegendSpacing: 32,
      chartValuesOptions: const ChartValuesOptions(
          decimalPlaces: 0,
          showChartValuesOutside: true,
          showChartValuesInPercentage: true,
          showChartValueBackground: true,
          showChartValues: true,
          chartValueStyle:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      centerText: 'Moods',
      legendOptions: const LegendOptions(
          showLegendsInRow: false,
          showLegends: true,
          legendShape: BoxShape.rectangle,
       
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          )),
    );
  }

  Future<void> getDataFromFireStore() async {
    var snapShotsValue = await FirebaseFirestore.instance
        .collection("BMI")
        .orderBy("bmiTime")
        .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    List<_ChartData> list = snapShotsValue.docs
        .map((e) => _ChartData(
            x: DateTime.fromMillisecondsSinceEpoch(
                e.data()['bmiTime'].millisecondsSinceEpoch),
            y: e.data()['bmiScore']))
        .toList();
    setState(() {
      chartData = list;
    });
  }

  final Stream<QuerySnapshot> moodStream = FirebaseFirestore.instance
      .collection('MoodTracking')
      .orderBy("DateTime")
      .limitToLast(1)
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  final Stream<QuerySnapshot> expStream = FirebaseFirestore.instance
      .collection('MoodTracking')
      .orderBy("DateTime")
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  final Stream<QuerySnapshot> BMIStream = FirebaseFirestore.instance
      .collection('BMI')
      .orderBy("bmiTime")
      .limitToLast(1)
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  void getExpfromSanapshot(snapshot) {
    if (snapshot.docs.isNotEmpty) {
      _moods = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        var a = snapshot.docs[i];

        Mood emotion = Mood.fromJson(a.data());
        _moods.add(emotion);

      }
    }
  }

  Future<void> setPage() async {
    await getbmiScore();
    await getBMITextResult();
    await getLatestMood();
  }

  double gotbmiScore = 0;
  double bmiScore = 0;
  Color activeColor = Colors.white;
  Color inactiveColor = Colors.white;
  String bmiResultText = "";
  String moodNameText = "";


  final double _max = 100.0;
  double _value = 60.0;

  Future<double> getbmiScore() async {
    String Exc = "Error";

    try {
      final bmiData = await FirebaseFirestore.instance
          .collection('BMI')
          .orderBy("bmiTime")
          .limitToLast(1)
          .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      for (var name in bmiData.docs) {
       
        bmiScore = bmiData.docs[0].get("bmiScore");

        double gotbmiScore = bmiScore;
     

        setState(() {
          gotbmiScore = bmiScore;
        });
        return gotbmiScore;
      }

      return bmiScore;
    } catch (Exc) {
      print(Exc);
      rethrow;
    }
  }

  //DISPLAYS LATEST TDEE
  final Stream<QuerySnapshot> bmiResultStream = FirebaseFirestore.instance
      .collection('BMI')
      .orderBy("bmiTime")
      .limitToLast(1)
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  //DISPLAYS LATEST Calorie Deductions
  final Stream<QuerySnapshot> CalsStream = FirebaseFirestore.instance
      .collection('remainingCalories')
      .orderBy("DateTime")
      .limitToLast(1)
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  Future<String> getBMITextResult() async {
    String Exc = "Error";

    try {
      final latestBmiResult = await FirebaseFirestore.instance
          .collection('BMI')
          .orderBy('bmiTime')
          .limitToLast(1)
          .where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      for (var bmiInterpretation in latestBmiResult.docs) {

        bmiResultText = latestBmiResult.docs[0].get("result");

        

        String FirestoreBmiTxtResult = bmiResultText;
  

        setBMIResult();

        setColorSlider(FirestoreBmiTxtResult);

        return FirestoreBmiTxtResult;
      }
      return bmiResultText;
    } catch (Exc) {
      print(Exc);
      rethrow;
    }
  }

  Future<String> getLatestMood() async {
    String Exc = "Error";

    try {
      final latestMoodName = await FirebaseFirestore.instance
          .collection('MoodTracking')
          .orderBy('DateTime')
          .limitToLast(1)
          .where("userID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
     
      for (var moodName in latestMoodName.docs) {
        moodNameText = latestMoodName.docs[0].get("Mood");


        String FirestoreMoodText = moodNameText;
      

        setMoodResult();

        return FirestoreMoodText;
      }
      return moodNameText;
    } catch (Exc) {
      print(Exc);
      rethrow;
    }
  }

  void setMoodResult() async {
    getLatestMood().then((FirestoreMoodText) {
      moodNameText = FirestoreMoodText;
    });
  }

  void setBMIResult() async {
    getBMITextResult().then((FirestoreBmiTxtResult) {
      bmiResultText = FirestoreBmiTxtResult;
    });
  }

  void setColorSlider(String result) {
    if (result == "Overweight") {
      activeColor = Colors.yellow;
      inactiveColor = Colors.yellow;
      result = "Overweight";
    } else if (result == "Underweight") {
      activeColor = Colors.red;
      inactiveColor = Colors.red;
      result = "Underweight";
    } else if (result == "Healthy") {
      activeColor = Colors.green;
      inactiveColor = Colors.green;
      result = "Healthy";
    } else if (result == "Obese") {
      activeColor = Colors.red;
      inactiveColor = Colors.red;
   
      result = "Obese";
    }
  }

  @override
  Widget build(BuildContext context) //=> Scaffold( {
  {
    return VisibilityDetector(
        key: Key(ChartSlider.id),
        onVisibilityChanged: (VisibilityInfo info) {
          bool isVisible = info.visibleFraction != 0;
          asyncMethod(isVisible);
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              elevation: 0,
              backgroundColor: Colors.black,
            ),
            body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      
                        colors: [
                      Colors.black,
                      Colors.grey,
                    
                    ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: SingleChildScrollView(
                    // <-- wrap this around
                    child: Column(children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 25,
                            child: Text(
                              "Welcome ${loggedInUser.firstName}!",
                              style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                      

                          const SizedBox(
                            height: 25,
                          ),
                          Text(
                              "Your Name: ${loggedInUser.firstName} ${loggedInUser.secondName}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              )),
                          Text("Your E-mail: ${loggedInUser.email}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              )),
                          const SizedBox(
                            height: 25,
                          ),
                          ActionChip(
                              label: const Text("Log Out"),
                              labelStyle: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                              backgroundColor: Colors.red,
                              onPressed: () {
                                logout(context);
                              }),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 2,
                  ),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(children: [
                            SizedBox(
                                height: 80.0,
                                child: StreamBuilder<QuerySnapshot>(
                                
                                  stream: CalsStream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text('Something went wrong');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text("Loading");
                                    }

                                    return ListView(
                               
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        Map<String, dynamic> data = document
                                            .data()! as Map<String, dynamic>;

                                        return ListTile(
                                                title: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(children: <TextSpan>[
                                            const TextSpan(
                                                text: "You have ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20)),
                                            TextSpan(
                                                text: data[('Cals')]
                                                    .toStringAsFixed(0),
                                               
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const TextSpan(
                                                text:
                                                    " calories remaining for today ",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                )),
                                          ]),
                                        ))
                                           
                                            ;
                                      }).toList(),
                                    );
                                  },
                                )),
                            const Divider(
                              color: Colors.grey,
                              thickness: 2,
                            ),
                            ListTile(
                                title: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: <TextSpan>[
                                const TextSpan(
                                    text: "Your BMI Score of ",
                                    style:  TextStyle(
                                        color: Colors.white, fontSize: 20)),
                                TextSpan(
                                    text: bmiScore.toStringAsFixed(1),
                                    style: TextStyle(
                                        color: activeColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                const TextSpan(
                                    text: " indicates that you are ",
                                    style:  TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    )),
                                TextSpan(
                                    text: bmiResultText,
                                    style: TextStyle(
                                      color: activeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    )),
                              ]),
                            )),
                            SizedBox(
                                height: 100,
                                child: SfSliderTheme(
                                  data: SfSliderThemeData(
                                    activeLabelStyle: TextStyle(
                                        color: activeColor,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic),
                                    inactiveLabelStyle: TextStyle(
                                        color: inactiveColor,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic),
                                    thumbColor: Colors.white,
                                    thumbRadius: 15,
                                    thumbStrokeWidth: 2,
                                    thumbStrokeColor: activeColor,

                                    activeTrackColor: activeColor,
                                    inactiveTrackColor: inactiveColor,
                                  
                                  ),
                                  child: SfSlider(
                                    thumbIcon: Icon(
                                        Icons.keyboard_arrow_right_outlined,
                                        color: activeColor,
                                        size: 20.0),
                                    min: 0,
                                    max: 50,
                                    value: bmiScore,
                                    interval: 20.0,
                                    showLabels: true,
                                    showTicks: true,
                                    onChanged:
                                    
                                        (bmiScore) {
                                      setState(() {
                                        bmiScore = bmiScore;
                                      });
                                    },
                                  ),
                                )),
                            const Divider(
                              color: Colors.grey,
                              thickness: 2,
                            ),
                            const SizedBox(
                                height: 30,
                                child: Text("Your last logged mood was:",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20))),
                          

                  
                            SizedBox(
                                height: 60,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: moodStream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text('Something went wrong');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text("Loading");
                                    }

                                    return ListView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        Map<String, dynamic> data = document
                                            .data()! as Map<String, dynamic>;
                                        return ListTile(
                                            leading:
                                               
                                                DisplayMoodIcon(
                                              image: data['Icon'],
                                            ),
                                            isThreeLine: true,
                                            title: Text(
                                              data['Mood'],
                                              style: const TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                            
                                              data['Activities']
                                                      .toString()
                                                      .substring(
                                                          1,
                                                          data['Activities']
                                                                  .toString()
                                                                  .length -
                                                              1) +
                                                  "             " +
                                                  data['DateOfMood'] +
                                                  " " +
                                        
                                                  data['TimeOfMood'],
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ));
                                      }).toList(),
                                    );
                                  },
                                )),
                           
                            const SizedBox(height: 20),
                            const Divider(
                              color: Colors.grey,
                              thickness: 2,
                            ),
                            SizedBox(
                              height: 40,
                              child: ListTile(
                                  title: RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: "Mood Tracker",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20)),
                                ]),
                              )),
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                StreamBuilder<Object>(
                                  stream: expStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text("something went wrong");
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    final data = snapshot.requireData;
                                   
                                    getExpfromSanapshot(data);
                                  
                                    return pieChartExampleOne();
                              
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Divider(
                              color: Colors.grey,
                              thickness: 2,
                            ),

                            SfCartesianChart(
                                title: ChartTitle(
                                    text: 'BMI over time',
                                    textStyle: const TextStyle(
                                        color: Colors.white, fontSize: 20)),
                                legend: Legend(
                                    isVisible: true,
                                    overflowMode: LegendItemOverflowMode.wrap),
                                primaryXAxis: DateTimeAxis(

                                   

                                    ),
                                primaryYAxis: NumericAxis(),
                                series: <ChartSeries<_ChartData, DateTime>>[
                                  LineSeries<_ChartData, DateTime>(
                                      dataSource: chartData,
                                      width: 2,
                                      name: "BMI",
                                      markerSettings:
                                          const MarkerSettings(isVisible: true),
                                      xValueMapper: (_ChartData data, _) =>
                                          data.x,
                                      yValueMapper: (_ChartData data, _) =>
                                          data.y),
                                ])
                          ]))),
                  SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    title: ChartTitle(text: 'BMI Data'),
                    primaryXAxis: DateTimeAxis(
                      edgeLabelPlacement: EdgeLabelPlacement.shift,
                      dateFormat: DateFormat.yMMM(),
                      intervalType: DateTimeIntervalType.days,
                      interval: 1,
                    ),
                    primaryYAxis: NumericAxis(
                        labelFormat: '{value}',
                        minimum: 0,
                        maximum: 100,
                        interval: 10,
                        majorGridLines:
                            const MajorGridLines(color: Colors.transparent)),
                    series: <ChartSeries<_ChartData, DateTime>>[
                      LineSeries<_ChartData, DateTime>(
                        animationDuration: 0,
                        dataSource: chartData,
                        xValueMapper: (_ChartData data, _) => data.x,
                        yValueMapper: (_ChartData data, _) => data.y,
                      ),
                    ],
                    tooltipBehavior: _tooltipBehavior,
                  )
                ])))));
  }
}

// Class for chart data source, this can be modified based on the data in Firestore
class _ChartData {
  _ChartData({this.x, this.y});
  final DateTime? x;
  final double? y;
}

class bmiData {
  bmiData(this.bmiTime, this.bmiScore);
  final DateTime bmiTime;
  final double bmiScore;
}

class Mood {
  String mood;

  Mood({
    required this.mood,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      mood: json['Mood'],
    );
  }
}

void callThisMethod(bool isVisible) {
  debugPrint('_HomeScreenState.callThisMethod: isVisible: $isVisible');
}
