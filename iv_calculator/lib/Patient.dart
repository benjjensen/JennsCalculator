import 'Parameters.dart';

class Patient {
  var patientWeight;
  var caloricNeeds_min;
  var caloricNeeds_max;
  var proteinNeeds_min;
  var proteinNeeds_max;
  var scaledCaloricNeeds_min;
  var scaledCaloricNeeds_max;

  var averageCaloricNeeds;
  var averageProteinNeeds;
  var averageProteinRounded;

  List<double> aminoAcidSolution = [];

  var hourlyRate = [];
  var updatedVolume = [];
  var updatedProtein = [];
  var updatedCalories = [];

  // LIPIDS
  var calRemaining = List.generate(
      aminoAcidConcentrations.length, (i) => List(lipidVolume.length),
      growable: false);

  List<double> calFromLipids = [];

  // CHO
  var dextroseProvided = List.generate(
      aminoAcidConcentrations.length, (i) => List(dwConcn.length),
      growable: false);

  // Recalculating kcals
  //    #AA Concn x #Lipid Volume x #CHO Concn
  var newCalVals = List.generate(
      aminoAcidConcentrations.length,
      (i) => List.generate(lipidVolume.length, (j) => List(dwConcn.length),
          growable: false),
      growable: false);

  void calculateNutrientNeeds() {
    caloricNeeds_min = caloriesPerKg_lower * patientWeight; // in kcal/day
    caloricNeeds_max = caloriesPerKg_upper * patientWeight;

    proteinNeeds_min = proteinPerKg_lower * patientWeight; // in g / day
    proteinNeeds_max = proteinPerKg_upper * patientWeight;

    scaledCaloricNeeds_min =
        caloricNeeds_min * parenteralScalingFactor; // in kcal / day
    scaledCaloricNeeds_max = caloricNeeds_max * parenteralScalingFactor;

    averageCaloricNeeds =
        (scaledCaloricNeeds_min + scaledCaloricNeeds_max) / 2.0;
    averageProteinNeeds = (proteinNeeds_min + proteinNeeds_max) / 2.0;
    averageProteinRounded = averageProteinNeeds.round();
  }

  void determineSolutionVolume() {
    for (int i = 0; i < aminoAcidConcentrations.length; i++) {
      aminoAcidSolution.add(averageProteinRounded / aminoAcidConcentrations[i]);
    }
  }

  void determineHourlyRate() {
    for (int i = 0; i < aminoAcidConcentrations.length; i++) {
      // Round to the nearest 5 for each concentration (divide by 5, round, multiply by 5 again)
      hourlyRate.add(
          ((aminoAcidSolution[i] / rateOfGiving) / portionRounding).round() *
              portionRounding);

      // Update volume with rounded values
      updatedVolume.add(rateOfGiving * hourlyRate[i]);

      // Update the total protein provided
      updatedProtein.add(updatedVolume[i] * aminoAcidConcentrations[i]);

      // Update the calories provided
      updatedCalories.add(updatedProtein[i] * caloriesPerProtein);
    }
  }

  void determineLipids() {
    for (int i = 0; i < lipidVolume.length; i++) {
      calFromLipids.add(lipidVolume[i] *
          lipidConcentrations[i] *
          10.0); // x10 to convert from g to calories (?)
    }
    for (int j = 0; j < aminoAcidConcentrations.length; j++) {
      for (int i = 0; i < lipidVolume.length; i++) {
        calRemaining[j][i] =
            averageCaloricNeeds - updatedCalories[j] - calFromLipids[i];
      }
    }
  }

  void determineCHO() {
    for (int i = 0; i < aminoAcidConcentrations.length; i++) {
      for (int j = 0; j < dwConcn.length; j++) {
        dextroseProvided[i][j] = updatedVolume[i] * dwConcn[j] * kcalsPerGSugar;
      }
    }
  }

  void sumUpNewCalCount() {
    for (int aa = 0; aa < aminoAcidConcentrations.length; aa++) {
      for (int lipVol = 0; lipVol < lipidVolume.length; lipVol++) {
        for (int dwCon = 0; dwCon < dwConcn.length; dwCon++) {
          newCalVals[aa][lipVol][dwCon] = updatedCalories[aa] +
              calFromLipids[lipVol] +
              dextroseProvided[aa][dwCon];
        }
      }
    }
  }

  List<double> nutrientPercentage(int aa, int lipVol, int dwCon) {
    /*  Returns the contribution of protein, lipids, and dextrose to overall
       calorie count, by percentage (in that order)
     */
    // TODO is this divided by the average or the actual?
    double percentCalFromProtein =
        updatedCalories[aa] / newCalVals[aa][lipVol][dwCon];
    double percentCalFromLipids =
        calFromLipids[lipVol] / newCalVals[aa][lipVol][dwCon];
    double percentCalFromCHO =
        dextroseProvided[aa][dwCon] / newCalVals[aa][lipVol][dwCon];

    List<double> calorieBreakdown = [];
    calorieBreakdown.add(percentCalFromProtein);
    calorieBreakdown.add(percentCalFromLipids);
    calorieBreakdown.add(percentCalFromCHO);

    return calorieBreakdown;
  }

  double getInfusionRate(int aaIdx, int lipIdx, int dwIdx) {
    double gramsCHO = dextroseProvided[aaIdx][dwIdx] /
        kcalsPerGSugar; // Convert from calories back to grams CHO
    double infusionRate = gramsCHO *
        1000.0 /
        (patientWeight *
            1440.0); // grams -> mg, divided by weight, divided by minutes
    return infusionRate; // in mg/kg/min
  }

  double getLipidRatio(int aaIdx, int lipIdx, int dwIdx) {
    double gramsLipid = calFromLipids[lipIdx] / 10.0;
    return (gramsLipid / patientWeight); // g/kg/day (less than 1)
  }

  void doItAll() {
    print("Doin it all");
    aminoAcidSolution.clear();
    hourlyRate.clear();
    updatedVolume.clear();
    updatedProtein.clear();
    updatedCalories.clear();

    calculateNutrientNeeds();
    determineSolutionVolume();
    determineHourlyRate();
    determineLipids();
    determineCHO();
    sumUpNewCalCount();
  }

  void setPatientWeight(String weight) {
    patientWeight = double.parse(weight); // in kg
  }

  int getCalories() {
    return caloricNeeds_min;
  }
}
