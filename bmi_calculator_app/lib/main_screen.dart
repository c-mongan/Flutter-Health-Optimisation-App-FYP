import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'container_box.dart';
import 'data_container.dart';

//Create MainScreen class by typing stful

const activeColor = Colors.blue;
const inActiveColor = Color(0XFFffffff);

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

//Scaffold copied from Material App above and pasted
//inside MainScreen below
class _MainScreenState extends State<MainScreen> {
  @override

  //Method to change color of container box on tap

  Color maleBoxColor = activeColor;
  Color femaleBoxColor = inActiveColor;
  int height = 180;
  int weight = 70;
  int age = 25;
  int result =80;
  String resultDetail = "result here";

  //void updateWeight{

  // }

  void updateBoxColor(int gender) {
    if (gender == 1) {
      if (maleBoxColor == inActiveColor) {
        maleBoxColor = activeColor;
        femaleBoxColor = inActiveColor;
      } else {
        maleBoxColor = inActiveColor;
        femaleBoxColor = activeColor;
      }
    } else {
      if (femaleBoxColor == inActiveColor) {
        femaleBoxColor = activeColor;
        maleBoxColor = inActiveColor;
      } else {
        femaleBoxColor = inActiveColor;
        maleBoxColor = activeColor;
      }
    }
  }

  //Set app bar and body
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI Calculator"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              Expanded(
                //Add gesture detector and call updateBoxColor inside gesture onpressed
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      updateBoxColor(1);
                    });
                  },
                  //Dont forget add set state fun inside onpressed
                  child: ContainerBox(
                    boxColor: maleBoxColor,
                    childWidget: DataContainer(
                      icon: FontAwesomeIcons.mars,
                      title: 'MALE',
                    ),
                  ),
                ),
              ),
              Expanded(
                //Add gesture detector and call updateBoxColor inside gesture onpressed
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      updateBoxColor(2);
                    });
                  },
                  //Dont forget add set state fun inside onpressed
                  child: ContainerBox(
                    boxColor: femaleBoxColor,
                    childWidget: DataContainer(
                      icon: FontAwesomeIcons.venus,
                      title: 'FEMALE',
                    ),
                  ),
                ),
              )
            ],
          )),
          Expanded(
            child: ContainerBox(
                boxColor: Color(0xFFffffff),
                childWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'HEIGHT',
                      style: textStyle1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(
                          height.toString(),
                          style: textStyle2,
                        ),
                        Text(
                          'cm',
                          style: textStyle1,
                        )
                      ],
                    ),
                    Slider(
                      value: height.toDouble(),
                      min: 120,
                      max: 220,
                      activeColor: activeColor,
                      inactiveColor: inActiveColor,
                      onChanged: (double newValue) {
                        //Dont forget to setState so it changes
                        setState(() {
                          height = newValue.round();
                        });
                      },
                    )
                  ],
                )),
          ),
          Expanded(
              child: Row(
            children: <Widget>[
              Expanded(
                child: ContainerBox(
                  boxColor: Colors.white,
                  childWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'WEIGHT',
                        style: textStyle1,
                      ),
                      Text(
                        weight.toString(),
                        style: textStyle2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FloatingActionButton(
                            backgroundColor: activeColor,
                            onPressed: () {
                              setState(() {
                                weight++;
                              });
                            },
                            child: Icon(
                              FontAwesomeIcons.plus,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          FloatingActionButton(
                            backgroundColor: activeColor,
                            onPressed: () {
                              setState(() {
                                if (weight > 0) {
                                  weight--;
                                }
                              });
                            },
                            child: Icon(
                              FontAwesomeIcons.minus,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              // Expanded(
              // child: ContainerBox(boxColor: Colors.black),
              //  )
            ],
          )),
          Expanded(
              child: Row(
            children: <Widget>[
              Expanded(
                child: ContainerBox(
                  boxColor: Colors.white,
                  childWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'AGE',
                        style: textStyle1,
                      ),
                      Text(
                        age.toString(),
                        style: textStyle2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FloatingActionButton(
                            backgroundColor: activeColor,
                            onPressed: () {
                              setState(() {
                                age++;
                              });
                            },
                            child: Icon(
                              FontAwesomeIcons.plus,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          FloatingActionButton(
                            backgroundColor: activeColor,
                            onPressed: () {
                              setState(() {
                                if (age > 0) {
                                  age--;
                                }
                              });
                            },
                            child: Icon(
                              FontAwesomeIcons.minus,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
          //Added Bottom border
          GestureDetector(
            onTap: (){

              showDialog(context: context, 
              builder : (BuildContext context)
              { return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)
              ),
              child: Container(height: 200,
              margin: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Text('Result',
                style: textStyle1,
                ),
                 Text(result.toString(),
                style: textStyle2,
                ),
                 Text(resultDetail,
                style: textStyle1,
                )
              ],
              ),
              ),
              );
            }
              );
            },
         child:  Container(
              child: Center(
                child: Text(
                  'Calculate',
                  style: textStyle3,
                ),
              ),
              width: double.infinity,
              height: 70.0,
              color: activeColor,
              margin: EdgeInsets.only(top: 10.0)),
          )

        ],
      ),
    );
  }
}
            


//Ctrl + . while hovering over widget lets us extract
//the widget and name it , in this case it was named
//ContainerBox. Its implementation is below.

//This allows us to remove duplicate code

