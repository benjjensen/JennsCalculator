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

/* Long Term TODO:
  - Add in the non-parenteral
  - Allow input of which lipids/CHO concn are available and cross out others
 */

import 'package:flutter/material.dart';
import 'Patient.dart';
import "Parameters.dart";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();
  static var _patient = Patient();
  var displayFlag = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Jenn's Thing v1.1"),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            Column(
              children:
                  getBody(), // Entry form, start button, and cards when relevant
            ),
          ],
        ),
      ),
    );
  }

  Widget getWeight() {
    /*
      Entry form for gathering data from user (patient's weight)
    */
    Widget playerForm = TextFormField(
      decoration: const InputDecoration(
        hintText: 'Enter patient weight',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        hintStyle: TextStyle(
          color: Colors.black54,
        ),
      ),
      style: TextStyle(
        color: Colors.black,
      ),

      // Validator is called when the start button is clicked
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please input a weight';
        }
        _patient.setPatientWeight(value);
        _patient.doItAll();
        return null;
      },
    );
    return Container(
      child: playerForm,
    );
  }

  Widget answerCard(var title, var text) {
    return Card(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              subtitle: Text(text),
            ),
          ],
        ),
      ),
    );
  }

  Widget startButton() {
    return ButtonTheme(
      minWidth: 150,
      height: 50,
      child: RaisedButton(
        textColor: Colors.white,
        color: Colors.blueAccent,
        child: Text(
          "Start",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.blue[800],
            width: 1,
          ),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        onPressed: () {
          setState(() {
            displayFlag = true;
            _formKey.currentState.validate();
          });
        },
      ),
    );
  }

  List<Widget> getBody() {
    List<Widget> body = [];
    // Patient Weight Input Field
    body.add(
      Padding(
        // TODO find a way to do this not hardocded (fits phone, chrome, etc...)
        padding: const EdgeInsets.fromLTRB(150.0, 0.0, 150.0, 0.0),
        child: Form(
          key: _formKey, // Used for the validation step
          child:
              getWeight(), // Returns a TextFormField with the appropriate number of name fields
        ),
      ),
    );
    // Start button
    body.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: startButton(),
      ),
    );

    // After the patient weight has been added, display the results
    if (displayFlag) {
      // Display input weight
      body.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Patient Weight: ${_patient.patientWeight}"),
        ),
      );
      // Patient Needs Tile
      String patientNeeds =
          "\tCalories: ${_patient.caloricNeeds_min} - ${_patient.caloricNeeds_max} kcal/day";
      patientNeeds +=
          "\n\tProtein: ${_patient.proteinNeeds_min} - ${_patient.proteinNeeds_max} g/day";
      patientNeeds +=
          "\n\tAdjusted Calories: ${_patient.scaledCaloricNeeds_min} - ${_patient.scaledCaloricNeeds_max} kcal/day ";
      patientNeeds +=
          "\n\tCalorie Average: ${_patient.averageCaloricNeeds} kcal/day";
      patientNeeds +=
          "\n\tProtein Average: ${_patient.averageProteinRounded} (${_patient.averageProteinNeeds}) g/day";
      body.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: answerCard("Patient Needs: ", patientNeeds),
        ),
      );

      // Section 3 Tile - likely will be cut out
      body.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text("Section 3 (likely will be cut out)",
                        style: TextStyle(
                          fontSize: 24,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 0.0),
                    child: Table(////////////// Make a for loop here?
                        children: [
                      TableRow(children: [
                        Text(
                          "AA Concentration (%)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Solution Volume (ml)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Rounded Rate (ml/hour)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Updated Volume (l/day)??",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Updated Protein (g/day)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Updated Calories (kcal/day)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                      // TODO Make this a for loop in case more than 3
                      TableRow(children: [
                        Text("${aminoAcidConcentrations[0]}"),
                        Text(
                            "${_patient.aminoAcidSolution[0].toStringAsFixed(1)}"),
                        Text("${_patient.hourlyRate[0].toStringAsFixed(1)}"),
                        Text("${_patient.updatedVolume[0].toStringAsFixed(1)}"),
                        Text(
                            "${_patient.updatedProtein[0].toStringAsFixed(1)}"),
                        Text(
                            "${_patient.updatedCalories[0].toStringAsFixed(1)}"),
                      ]),
                      TableRow(children: [
                        Text("${aminoAcidConcentrations[1]}"),
                        Text(
                            "${_patient.aminoAcidSolution[1].toStringAsFixed(1)}"),
                        Text("${_patient.hourlyRate[1].toStringAsFixed(1)}"),
                        Text("${_patient.updatedVolume[1].toStringAsFixed(1)}"),
                        Text(
                            "${_patient.updatedProtein[1].toStringAsFixed(1)}"),
                        Text(
                            "${_patient.updatedCalories[1].toStringAsFixed(1)}"),
                      ]),
                      TableRow(children: [
                        Text("${aminoAcidConcentrations[2]}"),
                        Text(
                            "${_patient.aminoAcidSolution[2].toStringAsFixed(1)}"),
                        Text("${_patient.hourlyRate[2].toStringAsFixed(1)}"),
                        Text("${_patient.updatedVolume[2].toStringAsFixed(1)}"),
                        Text(
                            "${_patient.updatedProtein[2].toStringAsFixed(1)}"),
                        Text(
                            "${_patient.updatedCalories[2].toStringAsFixed(1)}"),
                      ]),
                    ]),
                  )
                ],
              ),
            ),
          ),
        ),
      );

      // Add in amino acid (AA) concentrations
      for (int i = 0; i < aminoAcidConcentrations.length; i++) {
        body.add(getTableTile(i));
      }
    }
    return body;
  }

  Center getTableTileRowHeader(String headerText1, String headerText2) {
    return Center(
      child: Column(
        children: [
          Text(
            headerText1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
//          decoration: TextDecoration.underline,
            ),
          ),
          Text(
            headerText2,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Center getTableTileRowEntry(String entryText) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
      child: Text(entryText,
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.black,
          )),
    ));
  }

  Center getTableTileRowHeader_colored(
      String headerText1, String headerText2, bool isLipid) {
    double value;
    Color validValue;

    // Lipid section
    if (isLipid) {
      if (headerText2 != "") {
        value = double.parse(headerText2);
        headerText2 = "$value g/kg/day";

        if (value <= 1.0) {
          validValue = Colors.green;
        } else {
          validValue = Colors.red;
        }
      } else {
        validValue = Colors.white;
      }

      // CHO section
    } else {
      value = double.parse(headerText2);
      headerText2 = "$value mg/kg/min";

      if (value <= 5.0 && value >= 2.0) {
        validValue = Colors.green;
      } else {
        validValue = Colors.red;
      }
    }

    return Center(
      child: Column(
        children: [
          Text(
            headerText1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
//          decoration: TextDecoration.underline,
            ),
          ),
          Text(
            "$headerText2",
            style: TextStyle(
              fontSize: 12,
              color: validValue,
            ),
          ),
        ],
      ),
    );
  }

  Center getTableTileRowEntry_colored(int aaIdx, int lipIdx, int dwIdx) {
    // TODO add color to each percentage as well
    var valueColor;
    double value = _patient.newCalVals[aaIdx][lipIdx][dwIdx];
    if (value < (_patient.caloricNeeds_max) &&
        value > (_patient.caloricNeeds_min)) {
      valueColor = Colors.green;
    } else {
      valueColor = Colors.red;
    }

    List<double> breakdown = _patient.nutrientPercentage(aaIdx, lipIdx, dwIdx);

    return Center(
      //TODO see if you can make units display when hovering
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
        child: Column(
          children: [
            Text(
              "${value.toStringAsFixed(1)}",
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: valueColor,
              ),
            ),
            Text(
              "(${(100 * breakdown[0]).toStringAsFixed(1)}%, ${(100 * breakdown[1]).toStringAsFixed(1)}%, ${(100 * breakdown[2]).toStringAsFixed(1)}%)",
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding getUpdatedCalTable(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 10.0),
      child: Table(
        children: [
          TableRow(
            children: [
              Text(" "),
              Text(" "),
              Text(
                "LIPIDS",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(" "),
            ],
          ),
          TableRow(
            children: [
              //TODO dont hardcode numbers
              getTableTileRowHeader_colored(" ", "", true),
              getTableTileRowHeader_colored(
                  "250ml @20%",
                  "${_patient.getLipidRatio(index, 0, 0).toStringAsFixed(1)}",
                  true),
              getTableTileRowHeader_colored(
                  "250ml @11%",
                  "${_patient.getLipidRatio(index, 1, 0).toStringAsFixed(1)}",
                  true),
              getTableTileRowHeader_colored(
                  "500ml @11%",
                  "${_patient.getLipidRatio(index, 2, 0).toStringAsFixed(1)}",
                  true),
            ],
          ),
          TableRow(
            children: [
              //TODO dont hardcode numbers
              getTableTileRowHeader_colored(
                  "10% Concn",
                  "${_patient.getInfusionRate(index, 0, 0).toStringAsFixed(1)}",
                  false),
              getTableTileRowEntry_colored(index, 0, 0),
              getTableTileRowEntry_colored(index, 1, 0),
              getTableTileRowEntry_colored(index, 2, 0),
            ],
          ),
          TableRow(
            children: [
              //TODO dont hardcode numbers
              getTableTileRowHeader_colored(
                  "15% Concn",
                  "${_patient.getInfusionRate(index, 0, 1).toStringAsFixed(1)}",
                  false),
              getTableTileRowEntry_colored(index, 0, 1),
              getTableTileRowEntry_colored(index, 1, 1),
              getTableTileRowEntry_colored(index, 2, 1),
            ],
          ),
          TableRow(
            children: [
              //TODO dont hardcode numbers
              getTableTileRowHeader_colored(
                  "20% Concn",
                  "${_patient.getInfusionRate(index, 0, 2).toStringAsFixed(1)}",
                  false),
              getTableTileRowEntry_colored(index, 0, 2),
              getTableTileRowEntry_colored(index, 1, 2),
              getTableTileRowEntry_colored(index, 2, 2),
            ],
          ),
          TableRow(
            children: [
              //TODO dont hardcode numbers
              getTableTileRowHeader_colored(
                  "25% Concn",
                  "${_patient.getInfusionRate(index, 0, 3).toStringAsFixed(1)}",
                  false),
              getTableTileRowEntry_colored(index, 0, 3),
              getTableTileRowEntry_colored(index, 1, 3),
              getTableTileRowEntry_colored(index, 2, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget getTableTile(int index) {
    /*
        Used to display the updated volume, protein, and calories
      for each amino acid concentration
    */
    // TODO Make collapsible?
    return ExpansionTile(
      title: Text(
        "AA Concentration: ${aminoAcidConcentrations[index].toStringAsFixed(3)}",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        ListTile(
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
//          mainAxisSize: MainAxisSize.min,
            children: [
              // Table containing update volume, calories, protein, etc...
              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 10.0),
                // https://medium.com/flutter-community/table-in-flutter-beyond-the-basics-8d31b022b451
                child: Table(
                  children: [
                    TableRow(
                      children: [
                        getTableTileRowHeader("Solution Volume", "(ml)"),
                        getTableTileRowHeader("Rounded Rate", "(ml/hour)"),
                        getTableTileRowHeader("Updated Volume", "(/day?)"),
                        getTableTileRowHeader('Protein', '(g/day)'),
                        getTableTileRowHeader("Updated Calories", "kcal/day)"),
                      ],
                    ),
                    TableRow(
                      children: [
                        getTableTileRowEntry(
                            "${_patient.aminoAcidSolution[index].toStringAsFixed(1)}"),
                        getTableTileRowEntry(
                            "${_patient.hourlyRate[index].toStringAsFixed(1)}"),
                        getTableTileRowEntry(
                            "${_patient.updatedVolume[index].toStringAsFixed(1)}"),
                        getTableTileRowEntry(
                            "${_patient.updatedProtein[index].toStringAsFixed(1)}"),
                        getTableTileRowEntry(
                            "${_patient.updatedCalories[index].toStringAsFixed(1)}"),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 32.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lipids",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // TODO make a for loop? Is this ever gonna be more than 3...?
                        Text(
                          //TODO use a RichText to bold the value?
                          "\t${lipidVolume[0]}ml @${lipidConcentrations[0] * 100}% ILE: \t${_patient.calRemaining[index][0].toStringAsFixed(1)} kcal remaining for PN",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "\t${lipidVolume[1]}ml @${lipidConcentrations[1] * 100}%* ILE: \t${_patient.calRemaining[index][1].toStringAsFixed(1)} kcal remaining for PN",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "\t${lipidVolume[2]}ml @${lipidConcentrations[2] * 100}%* ILE: \t${_patient.calRemaining[index][2].toStringAsFixed(1)} kcal remaining for PN",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CHO",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "\t${dwConcn[0] * 100}% Concn: ${_patient.dextroseProvided[index][0].toStringAsFixed(1)} kcal/day from CHO",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "\t${dwConcn[1] * 100}% Concn: ${_patient.dextroseProvided[index][1].toStringAsFixed(1)} kcal/day from CHO",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "\t${dwConcn[2] * 100}% Concn: ${_patient.dextroseProvided[index][2].toStringAsFixed(1)} kcal/day from CHO",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "\t${dwConcn[3] * 100}% Concn: ${_patient.dextroseProvided[index][3].toStringAsFixed(1)} kcal/day from CHO",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 0.0),
                child: Text(
                  "Updated Calorie Counts:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              getUpdatedCalTable(index),
            ],
          ),
        ),
      ],
    );
  }
}
