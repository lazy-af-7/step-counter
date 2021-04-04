import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

void main() {
  runApp(main_page());
}

class main_page extends StatefulWidget {
  @override
  _main_pageState createState() => _main_pageState();
}

class _main_pageState extends State<main_page> {
  Stream<StepCount> _stepCountStream;
  Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  double _value = 0;
  int _goal = 10000;
  String goal_str;
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
      _value = (event.steps.toInt() / _goal).toDouble();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = '0';
      _value = int.parse(_steps) / _goal.toDouble();
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Pedometer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                'Steps Taken',
                style: TextStyle(fontSize: 30),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.all(15),
              height: 200,
              width: 200,
              child: CircularProgressIndicator(
                strokeWidth: 10,
                backgroundColor: Colors.white,
                value: _value,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                _steps + ' out of ',
                style: TextStyle(fontSize: 30, color: Colors.blueAccent),
              ),
            ),
            Center(
              child: Container(
                width: 100,
                child: TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: _goal.toString(),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white, fontSize: 30),
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Steps',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      focusColor: Colors.amber,
                    ),
                    onChanged: (String str) {
                      setState(() {
                        goal_str = str;
                        _value = int.parse(_steps) / double.parse(goal_str);
                      });
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
