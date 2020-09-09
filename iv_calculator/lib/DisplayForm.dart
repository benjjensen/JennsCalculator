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
import 'Parameters.dart';

class DisplayForm {
  /* Hierarchy
      getAmino Acid Tile
        updatedValueBar
          getValueBarRowHeader
          getValueBarRowEntry
        lipidList
        choList
        calorieCountCharts
          getTableRowHeader
          getTableRowEntry
   */
  Settings settings;
  Patient patient;

  DisplayForm(Settings settings, Patient patient)
      : settings = settings,
        patient = patient;

  Center getValueBarRowHeader(String headerText, String subText) {
    return Center(
      child: Column(
        children: [
          Text(
            headerText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            subText,
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

  Center getValueBarRowEntry(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
        child: Text(text,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.black,
            )),
      ),
    );
  }

  Widget updatedValueBar(int idx) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 10.0),
      child: Table(
        children: [
          TableRow(
            children: [
              getValueBarRowHeader('SolutionVolume', '(ml)'),
              getValueBarRowHeader('Rounded Rate', '(ml/hour)'),
              getValueBarRowHeader('Updated Volume', '(_ / day?)'),
              getValueBarRowHeader('Protein', '(g/day)'),
              getValueBarRowHeader('Updated Calories', 'kcal/day'),
            ],
          ),
          TableRow(
            children: [
              getValueBarRowEntry(
                  '${patient.aminoAcidSlns[idx].toStringAsFixed(1)}'),
              getValueBarRowEntry(
                  '${patient.hourlyRate[idx].toStringAsFixed(1)}'),
              getValueBarRowEntry(
                  '${patient.updatedVolume[idx].toStringAsFixed(1)}'),
              getValueBarRowEntry(
                  '${patient.updatedProtein[idx].toStringAsFixed(1)}'),
              getValueBarRowEntry(
                  '${patient.updatedCalories[idx].toStringAsFixed(1)}'),
            ],
          ),
        ],
      ),
    );
  }

  Column lipidList(int idx) {
    List<Widget> body = [];
    body.add(
      Text(
        'Lipids',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
    for (int i = 0; i < settings.lipidVolumes.length; i++) {
      body.add(
        // TODO use a richText to bold the value?
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '${settings.lipidVolumes[i]} ml @${settings.lipidConcns[i] * 100}% ILE: '),
                TextSpan(
                  text: '\t${patient.calRemaining[idx][i].toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                TextSpan(text: ' kcalRemaining for PN'),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: body,
    );
  }

  Widget choList(int idx) {
    List<Widget> body = [];
    body.add(
      Text(
        'CHO',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
    for (int i = 0; i < settings.dwConcns.length; i++) {
      body.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(text: '${settings.dwConcns[i] * 100}% Concn: '),
                TextSpan(
                  text:
                      '\t${patient.dextroseProvided[idx][i].toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                TextSpan(text: ' kcal/day from CHO'),
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: body,
    );
  }

  Widget getTableRowHeader(
      String headerText, String subheaderText, bool isLipid) {
    double value;
    Color validValue;

    // Lipid section
    if (isLipid) {
      if (subheaderText != "") {
        value = double.parse(subheaderText);
        subheaderText = '$value g/kg/day';

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
      value = double.parse(subheaderText);
      subheaderText = '$value mg/kg/min';

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
            headerText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '$subheaderText',
            style: TextStyle(
              fontSize: 12,
              color: validValue,
            ),
          ),
        ],
      ),
    );
  }

  Widget getTableRowEntry(int aaIdx, int lipIdx, int dwIdx) {
    // Used to generate a value for the table, with a color illustrating whether or not the value is in the desired range
    Color valueColor;
    double value = patient.newCalVals[aaIdx][lipIdx][dwIdx];

    valueColor = (value >= patient.caloricNeeds_min)
        ? (value <= patient.caloricNeeds_max ? Colors.green : Colors.red)
        : Colors.red;
//    if ((value <= patient.caloricNeeds_max) && (value >= patient.caloricNeeds_min)) {
//      valueColor = Colors.green;
//    } else {
//      valueColor = Colors.red;
//      valueColor = (value > 5) ? Colors.red : Colors.black;
//    }

    List<double> breakdown = patient.nutrientPercentage(aaIdx, lipIdx, dwIdx);

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
        child: Column(
          children: [
            Text(
              '${value.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: valueColor,
              ),
            ),
            Text(
              '(${(100 * breakdown[0]).toStringAsFixed(1)}%, ${(100 * breakdown[1]).toStringAsFixed(1)}%, ${(100 * breakdown[2]).toStringAsFixed(1)}%)',
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

  Widget calorieCountCharts(int aaIdx) {
    List<Widget> body = [];
    // Section Header
    body.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(32.0, 0.0, 0.0, 0.0),
        child: Text(
          'Updated Calorie Counts:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
    // Beginning of Table, which is created dynamically
    List<TableRow> tableRows = [];
    List<Widget> tableColumns = [];

    // Create header row
    List<Widget> headerCols = [];
    for (int lipIdx = 0;
        lipIdx < (settings.lipidVolumes.length + 1);
        lipIdx++) {
      if (lipIdx == 0) {
        headerCols.add(
          Text(" "),
        ); // blank space
      } else {
        headerCols.add(
          getTableRowHeader(
              '${settings.lipidVolumes[lipIdx - 1]}ml @${settings.lipidConcns[lipIdx - 1] * 100}%',
              '${patient.getLipidRatio(aaIdx, (lipIdx - 1), 0).toStringAsFixed(1)}',
              true),
        );
      }
    }
    tableRows.add(
      TableRow(
        children: headerCols,
      ),
    );

    // Create table entry rows
    for (int dwIdx = 0; dwIdx < settings.dwConcns.length; dwIdx++) {
      for (int lipIdx = 0;
          lipIdx < (settings.lipidVolumes.length + 1);
          lipIdx++) {
        if (lipIdx != 0) {
          tableColumns.add(
            Center(
              child: getTableRowEntry(aaIdx, (lipIdx - 1), dwIdx),
            ),
          );
        } else {
          // Add in a CHO row header
          tableColumns.add(getTableRowHeader(
              '${settings.dwConcns[dwIdx] * 100}% CHO Concn',
              '${patient.getInfusionRate(aaIdx, 0, dwIdx).toStringAsFixed(1)}',
              false));
        }
      }
      tableRows.add(
        TableRow(
          children: tableColumns,
        ),
      );
      tableColumns = [];
    }

    body.add(
      Table(
        children: tableRows,
      ),
    );
    return Column(
      children: body,
    );
  }

  Widget getAminoAcidTile(int idx) {
    // Used to display volume, protein, and calories for each amino acid concn
    // Creates an updatedValueBar, a Lipid list, a CHO list, and a displayTable
    return ExpansionTile(
      title: Text(
        "Amino Acid Concentration: ${settings.aminoAcidConcns[idx].toStringAsFixed(3)}",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        ListTile(
          // TODO does this need to be a list tile?
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              updatedValueBar(idx),
              // Lipid and Dextrose lists
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 32.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    lipidList(idx),
                    choList(idx),
                  ],
                ),
              ),
              calorieCountCharts(idx),
            ],
          ),
        ),
      ],
    );
  }
}
