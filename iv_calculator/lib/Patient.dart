import "Settings.dart";
import "Parameters.dart";

class Patient {
  Settings settings;
  double patientWeight;
  double caloricNeeds_min;
  double caloricNeeds_max;
  double proteinNeeds_min;
  double proteinNeeds_max;
  double scaledCaloricNeeds_min;
  double scaledCaloricNeeds_max;

  double averageCaloricNeeds;
  double averageProteinNeeds;
  int averageProteinRounded;

  List<double> aminoAcidSlns = [];
  List<double> hourlyRate = [];
  List<double> updatedVolume = [];
  List<double> updatedProtein = [];
  List<double> updatedCalories = [];

  Patient(Settings settings) : settings = settings;

  // Lipids
  var calRemaining;
  List<double> calFromLipids = [];

  // CHO
  var dextroseProvided;

  // Recalculating kcals - #AA Concn x #Lipid Volume x #CHO Concn
  var newCalVals;

  void calculateNutrientNeeds() {
    caloricNeeds_min =
        settings.caloriesPerKg_lower * patientWeight; // in kcal/day
    caloricNeeds_max = settings.caloriesPerKg_upper * patientWeight;

    proteinNeeds_min = proteinPerKg_lower * patientWeight; // in g / day
    proteinNeeds_max = proteinPerKg_upper * patientWeight;

    scaledCaloricNeeds_min =
        caloricNeeds_min * settings.parenteralScalingFactor; // in kcal / day
    scaledCaloricNeeds_max =
        caloricNeeds_max * settings.parenteralScalingFactor;

    averageCaloricNeeds =
        (scaledCaloricNeeds_min + scaledCaloricNeeds_max) / 2.0;
    averageProteinNeeds = (proteinNeeds_min + proteinNeeds_max) / 2.0;
    averageProteinRounded = averageProteinNeeds.round();

    for (int i = 0; i < settings.aminoAcidConcns.length; i++) {
      aminoAcidSlns.add(averageProteinRounded / settings.aminoAcidConcns[i]);
    }
  }

  void determineHourlyRate() {
    for (int i = 0; i < settings.aminoAcidConcns.length; i++) {
      // Break down daily allotment into specified doses, and then round to the nearest specified volume (e.g., nearest 5)
      hourlyRate.add(((aminoAcidSlns[i] / settings.rateOfGiving) /
                  settings.portionRounding)
              .round() *
          settings.portionRounding);

      // Update volume using rounded values
      updatedVolume.add(settings.rateOfGiving * hourlyRate[i]);

      // Update the total protein provided based off of updated volume
      updatedProtein.add(updatedVolume[i] * settings.aminoAcidConcns[i]);

      // Updated calories provided with updated protein count
      updatedCalories.add(updatedProtein[i] * caloriesPerProtein);
    }
  }

  void determineLipids() {
    calRemaining = List.generate(settings.aminoAcidConcns.length,
        (i) => List(settings.lipidVolumes.length),
        growable: false);

    for (int i = 0; i < settings.lipidVolumes.length; i++) {
      calFromLipids.add(settings.lipidVolumes[i] *
          settings.lipidConcns[i] *
          10.0); // x10 to convert from grams to calories (?)
    }

    for (int i = 0; i < settings.aminoAcidConcns.length; i++) {
      for (int j = 0; j < settings.lipidVolumes.length; j++) {
        calRemaining[i][j] =
            averageCaloricNeeds - updatedCalories[i] - calFromLipids[j];
      }
    }
  }

  void determineCHO() {
    dextroseProvided = List.generate(
        settings.aminoAcidConcns.length, (i) => List(settings.dwConcns.length),
        growable: false);
    for (int i = 0; i < settings.aminoAcidConcns.length; i++) {
      for (int j = 0; j < settings.dwConcns.length; j++) {
        dextroseProvided[i][j] =
            updatedVolume[i] * settings.dwConcns[j] * kcalsPerGSugar;
      }
    }
  }

  void sumUpNewCalCount() {
    //    #AA Concn x #Lipid Volume x #CHO Concn
    newCalVals = List.generate(
        settings.aminoAcidConcns.length,
        (i) => List.generate(
            settings.lipidVolumes.length, (j) => List(settings.dwConcns.length),
            growable: false),
        growable: false);

    for (int aaIdx = 0; aaIdx < settings.aminoAcidConcns.length; aaIdx++) {
      for (int lipIdx = 0; lipIdx < settings.lipidVolumes.length; lipIdx++) {
        for (int dwIdx = 0; dwIdx < settings.dwConcns.length; dwIdx++) {
          newCalVals[aaIdx][lipIdx][dwIdx] = updatedCalories[aaIdx] +
              calFromLipids[lipIdx] +
              dextroseProvided[aaIdx][dwIdx];
        }
      }
    }
  }

  List<double> nutrientPercentage(int aaIdx, int lipIdx, int dwIdx) {
    /*
        Returns the contribution of protein, lipids, and dextrose to
      overall calorie count, by percentage (in that order)
     */
    double percentCalFromProtein =
        updatedCalories[aaIdx] / newCalVals[aaIdx][lipIdx][dwIdx];
    double percentCalFromLipids =
        calFromLipids[lipIdx] / newCalVals[aaIdx][lipIdx][dwIdx];
    double percentCalFromCHO =
        dextroseProvided[aaIdx][dwIdx] / newCalVals[aaIdx][lipIdx][dwIdx];

    List<double> calorieBreakdown = [];
    calorieBreakdown.add(percentCalFromProtein);
    calorieBreakdown.add(percentCalFromLipids);
    calorieBreakdown.add(percentCalFromCHO);

    return calorieBreakdown;
  }

  double getInfusionRate(int aaIdx, int lipIdx, int dwIdx) {
    // convert from calories back to grams CHO
    double gramsCHO = dextroseProvided[aaIdx][dwIdx] / kcalsPerGSugar;
    // grams -> mg, divided by weight, divided by minutes in day
    double infusionRate = gramsCHO * 1000.0 / (patientWeight * 1440.0);
    return infusionRate; // in mg/kg/min
  }

  double getLipidRatio(int aaIdx, int lipIdx, int dwIdx) {
    double gramsLipid = calFromLipids[lipIdx] / 10.0; // convert back to grams
    return (gramsLipid / patientWeight); // g/kg/day (less than 1, hopefully)
  }

  void doItAll() {
    calculateNutrientNeeds();
    determineHourlyRate();
    determineLipids();
    determineCHO();
    sumUpNewCalCount();
  }
}
