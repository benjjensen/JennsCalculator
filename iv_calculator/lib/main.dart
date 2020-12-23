// TODO Color the percent breakdown in displayForm
/* https://blog.solutelabs.com/flutter-for-web-how-to-deploy-a-flutter-web-app-c7d9db7ced2e
 Above was used for deploying to web. Note that for Part 2, step 2, you must remember to
 "git push origin gh-pages
 Pushing changes:
    1) Push to github
    2) On Firebase CLI thing:
      a) flutter build web
      b) flutter pub global run peanut:peanut
      c) git push origin gh-pages
    3) Wait like 2-3 min
    (C:\Users\benjj\Downloads\firebase-tools-instant-win.exe)
*/

import 'package:flutter/material.dart';
import 'Patient.dart';
import 'Settings.dart';
import 'DisplayForm.dart';

void main() {
  runApp(IVCalculator());
}

class IVCalculator extends StatefulWidget {
  @override
  _IVCalculatorState createState() => _IVCalculatorState();
}

class _IVCalculatorState extends State<IVCalculator> {
  bool displayResultsFlag = false;
  bool displaySettingsFlag = false;
  bool displaySettingsErrorFlag =
      false; // Flag used to signal display of error (e.g., lipid volumes and concentrations dont align
  static Settings settings = Settings();
  static Patient patient = Patient(settings);
  static DisplayForm displayForm = DisplayForm(settings, patient);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Parenteral IV Calculator: v1.3"),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: getBody(),
      ),
    );
  }

  Widget weightInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 300),
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Enter Patient Weight', border: OutlineInputBorder()),
            onSubmitted: (String text) {
              setState(() {
                patient.patientWeight = double.parse(text);
                displayResultsFlag = true;
                displaySettingsFlag = false;
                patient.doItAll();
              });
            },
          ),
        ),
      ),
    );
  }

  Widget settingsButton() {
    return RaisedButton(
      textColor: Colors.white,
      color: Colors.blueAccent,
      child: Text(
        "Adjust Settings",
        style: TextStyle(fontSize: 16),
      ),
      onPressed: () {
        setState(() {
          displayResultsFlag = false;
          displaySettingsFlag = !displaySettingsFlag;
        });
      },
    );
  }

  Widget settingsInputField(
      // TODO note about hitting enter/button (changed instead of submitted? problems for arrays?)
      String fieldText,
      String hintText,
      Function callbackAction) {
    return Padding(
      // TODO start using controller lists?
      padding: const EdgeInsets.fromLTRB(0, 2.0, 0, 2.0),
      child: Container(
        constraints: BoxConstraints(maxWidth: 800),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fieldText),
            Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextField(
                cursorColor: Colors.amber,
                decoration: InputDecoration.collapsed(
                  hintText: hintText,
//                  hintStyle: TextStyle(
//                    color: Colors.blueAccent.withOpacity(0.5),
//                  ),
                ),
                onSubmitted: (String text) {
                  setState(() {
                    callbackAction(text);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getErrorMessage() {
    // Displays an error message if there is a problem in setting settings
    if (displaySettingsErrorFlag) {
      return Center(
          child: Container(
              color: Colors.red,
              child: Column(
                children: [
                  Text(" "),
                  Text(
                    "ERROR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      "The amount of comma-seperated values in the 'Lipid Concentrations' and 'Lipid Volumes' fields must match!",
                      style: TextStyle(fontSize: 14)),
                  Text(" "),
                ],
              )));
    } else {
      return Text(" ");
    }
  }

  Widget settingsInputForm() {
    /*
      Form containing multiple settingInputField s
      Used to update settings
    */
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TODO could i shorten the name and have a full name with hovering over?
            // TODO some sort of validation (e.g., for lipid fields)
            settingsInputField(
                'Amount of calories per kg (lower and upper values, seperate with commas)',
                '${settings.caloriesPerKg_lower}, ${settings.caloriesPerKg_upper}',
                (String text) {
              List<double> calsPerKg = [];
              List<String> inputList = text.split(','); // split input by commas
              for (int i = 0; i < inputList.length; i++) {
                calsPerKg.add(double.parse(inputList[i]));
              }
              settings.caloriesPerKg_lower = calsPerKg[0];
              settings.caloriesPerKg_upper = calsPerKg[1];
            }),
            settingsInputField(
                'Amount of calories to be provided through parenteral IV:',
                '${settings.parenteralScalingFactor}', (String text) {
              settings.parenteralScalingFactor = double.parse(text);
            }),
            settingsInputField(
              "Rate of Giving (times per day):",
              '${settings.rateOfGiving}',
              (String text) {
                settings.rateOfGiving = double.parse(text);
              },
            ),
            settingsInputField(
                'Amino Acid Concentrations (seperate with commas):',
                '${settings.aminoAcidConcns}'
                    .substring(1, '${settings.aminoAcidConcns}'.length - 1),
                (String text) {
              List<double> aminoAcidConcns = [];
              List<String> inputList = text.split(','); // split input by commas
              for (int i = 0; i < inputList.length; i++) {
                aminoAcidConcns.add(double.parse(inputList[i]));
              }
              settings.aminoAcidConcns = aminoAcidConcns;
            }),
            settingsInputField(
                'Lipid concentrations (in kcals/ml, seperate with commas):',
                '${settings.lipidConcns}'.substring(
                    // trim off brackets for clarity
                    1,
                    '${settings.lipidConcns}'.length - 1), (String text) {
              List<double> lipidConcns = [];
              List<String> inputList = text.split(',');
              for (int i = 0; i < inputList.length; i++) {
                lipidConcns.add(double.parse(inputList[i]));
              }
              settings.lipidConcns = lipidConcns;
            }),
            settingsInputField(
                // TODO is this pair format too confusing? ask Jenn
                'Lipid volumes (in mL, be sure to match up with concentrations above):',
                '${settings.lipidVolumes}'.substring(
                    1, '${settings.lipidVolumes}'.length - 1), (String text) {
              List<double> lipidVolumes = [];
              List<String> inputList = text.split(',');
              for (int i = 0; i < inputList.length; i++) {
                lipidVolumes.add(double.parse(inputList[i]));
              }
              settings.lipidVolumes = lipidVolumes;
            }),
            settingsInputField(
                'CHO Concentrations (in g/mL?, seperate with commas)',
                '${settings.dwConcns}'.substring(
                    1, '${settings.dwConcns}'.length - 1), (String text) {
              List<double> dwConcns = [];
              List<String> inputList = text.split(',');
              for (int i = 0; i < inputList.length; i++) {
                dwConcns.add(double.parse(inputList[i]));
              }
              settings.dwConcns = dwConcns;
            }),
            // Add in a Reset to Default button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  textColor: Colors.blueAccent,
//              color: Colors.blueAccent,
                  child: Text(
                    "Reset to Default",
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      settings.setToDefaults();
                      displaySettingsFlag =
                          false; // TODO is there a better way to refresh the screen?
                    });
                  },
                ),
                SizedBox(
                  width: 30,
                ),
                RaisedButton(
                  textColor: Colors.blueAccent,
                  child: Text(
                    "Close Settings",
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      if (settings.lipidConcns.length !=
                          settings.lipidVolumes.length) {
                        displaySettingsErrorFlag = true;
                      } else {
                        displaySettingsFlag = false;
                        displaySettingsErrorFlag = false;
                      }
                    });
                  },
                ),
              ],
            ),
            getErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget patientNeedsTile() {
    return Container(
      constraints: BoxConstraints(maxWidth: 1000), // TODO do i want this?
      child: Card(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "Summary of Patient Needs",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                  child: RichText(
                    // TODO: leave untouched? bold/color the amount? the category?
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Calories: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text:
                                '${patient.caloricNeeds_min} - ${patient.caloricNeeds_max} kcalories / day'),
                        TextSpan(
                            text: '\nProtein: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                          text:
                              '${patient.proteinNeeds_min.toStringAsFixed(1)} - ${patient.proteinNeeds_max.toStringAsFixed(1)}',
                        ),
                        TextSpan(text: ' grams / day'),
                        TextSpan(text: '\nAdjusted Calories: '),
                        TextSpan(
                            text:
                                '${patient.scaledCaloricNeeds_min} - ${patient.scaledCaloricNeeds_max}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' kcalories/day'),
                        TextSpan(text: '\nCalorie Average: '),
                        TextSpan(
                            text: '${patient.averageCaloricNeeds}',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' kcalories / day'),
                        TextSpan(
                            text:
                                '\nProtein Average: ${patient.averageProteinRounded} (${patient.averageProteinNeeds.toStringAsFixed(1)}) grams / day')
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBody() {
    List<Widget> body = [];
    // Always display the patient weight form + buttons
    body.add(weightInputField());
    body.add(settingsButton());
    if (displaySettingsFlag) {
      body.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
          child: Text(
            "Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      body.add(Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
        child:
            Text('(Note, you must hit \'Enter\' after each field you update)'),
      ));
      body.add(settingsInputForm());
    } else if (displayResultsFlag) {
      body.add(
        Text(
          "Results",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      body.add(patientNeedsTile());
      for (int i = 0; i < settings.aminoAcidConcns.length; i++) {
        body.add(displayForm.getAminoAcidTile(i));
      }
      //TODO added this in to enable more scrolling... probably could find a better way
      body.add(Container(
        constraints: BoxConstraints(minHeight: 1000),
      ));
    }
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: body,
        ),
      ],
    );
  }
}
