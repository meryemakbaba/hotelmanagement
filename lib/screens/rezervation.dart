import 'package:flutter/material.dart';
import 'package:serenadepalace/widgets/custom_scaffold.dart';

class RezervationScreen extends StatefulWidget {
  const RezervationScreen({Key? key}) : super(key: key);

  @override
  _RezervationScreenState createState() => _RezervationScreenState();
}

class _RezervationScreenState extends State<RezervationScreen> {
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: ListView(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Choose your room',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                      color:  const Color.fromARGB(255, 143, 115, 94) ,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  const SizedBox(height: 75),
                
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}