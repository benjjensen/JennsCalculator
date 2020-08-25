/*  Parameters used in Jenns thing */

var caloriesPerKg_lower = 25.0; // kcal / kg
var caloriesPerKg_upper = 30.0;

var proteinPerKg_lower = 1.3; // g protein / kg
var proteinPerKg_upper = 1.5;

var fluidRatio = 1.0; // ml / kcal

var parenteralScalingFactor =
    0.8; // Amount of calorie needs provided through parenteral nutrition (ASPEN/SCCM)

var aminoAcidConcentrations = [0.05, 0.06, 0.075];

var rateOfGiving =
    24.0; // how many times a day do we give them stuff ////////////
var portionRounding = 5.0; // What we round the dose to, in ml

var caloriesPerProtein = 4.0;

// LIPIDS
List<double> lipidConcentrations = [0.2, 0.11, 0.11]; // kcals / mL
List<double> lipidVolume = [250, 250, 500]; // in mL

// CHO
List<double> dwConcn = [0.1, 0.15, 0.2, 0.25]; // D%W concentrations, g/ml ?
double kcalsPerGSugar = 3.4; // kcal / g CHO
