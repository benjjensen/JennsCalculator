import "Parameters.dart";

class Settings {
  double parenteralScalingFactor;
  List<double> aminoAcidConcns = [];

  double rateOfGiving;
  double portionRounding;

  double caloriesPerKg_lower;
  double caloriesPerKg_upper;

  List<double> lipidConcns = [];
  List<double> lipidVolumes = [];

  List<double> dwConcns = [];

  Settings() {
    setToDefaults();
  }

  void setToDefaults() {
    parenteralScalingFactor = parenteralScalingFactor_;
    rateOfGiving = rateOfGiving_;
    portionRounding = portionRounding_;
//    aminoAcidConcns.clear();
    aminoAcidConcns = aminoAcidConcns_;
//    lipidConcns.clear();
    lipidConcns = lipidConcns_;
//    lipidVolumes.clear();
    lipidVolumes = lipidVolumes_;
//    dwConcns.clear();
    dwConcns = dwConcns_;
    caloriesPerKg_lower = caloriesPerKg_lower_;
    caloriesPerKg_upper = caloriesPerKg_upper_;
  }
}
