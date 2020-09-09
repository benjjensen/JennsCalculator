// Default setting parameters
const double caloriesPerKg_lower = 25.0; // kcal / kg
const double caloriesPerKg_upper = 30.0; // kcal / kg

const double proteinPerKg_lower = 1.3; // g protein / kg
const double proteinPerKg_upper = 1.5; // g protein / kg

const double caloriesPerProtein = 4.0;
const double kcalsPerGSugar = 3.4;

const double fluidRatio = 1.0; // ml / kcal TODO i have no idea what this means

double parenteralScalingFactor_ =
0.8; // Amount of calorie needs to be provided through parenteral nutrition

List<double> aminoAcidConcns_ = [0.05, 0.06, 0.075];

double rateOfGiving_ = 24.0; // how many times a day they receive a dose
double portionRounding_ = 5.0; // what we round the dose to, in ml

// Lipids
List<double> lipidConcns_ = [0.2, 0.11, 0.11]; // kcals/mL
List<double> lipidVolumes_ = [250, 250, 500]; // in mL

// Dextrose (CHO)
List<double> dwConcns_ = [0.1, 0.15, 0.2, 0.25]; // g/ml ?
