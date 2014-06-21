%% Optimisation settings
Sx.HistogramCentres=25:50:4975;

%% Simulation settings
MaxYears=20;%Max years is the maximum number of years a person can spend without being diagnosed with HIV. Although longer times are possible in real life, so few would occur that we can successfully ignore it in the name of simplicity and approximation
Sx.MaxYears=MaxYears;    
StepSize=0.1;
Sx.StepSize=StepSize;

%% Data settings


CD4BackProjectionYears=[1965.0 YearOfDiagnosedDataEnd-StepSize];
CD4BackProjectionYearsWhole=[1965 YearOfDiagnosedDataEnd];

ConsiderRecentInfection=true;

%% Program settings


%change the 2 following variables to false if geographic calculations unnecessary or
%outside of the Australian region
PerformGeographicCalculations=true;%do movement calculations and break up according to location
InitialisePCToSRThisSim=true;%re-perform this function. Only relevant if geographic calculations take place. 

UseGeneticAlgorithmOptimisation=true;




NumberOfSamples=500;%Used in the old optmisation algorithm
Sx.NumberOfSamples=NumberOfSamples;
RangeOfCD4Averages=[(YearOfDiagnosedDataEnd-5) YearOfDiagnosedDataEnd];%YearOfDiagnosedDataEnd not inclusive
RangeOfCD4AveragesForForwardProjection=[(YearOfDiagnosedDataEnd-5) YearOfDiagnosedDataEnd];


TotalTime=tic;

ParameterLocalStorageLocation='Parameters/';



SheetName='Dataset_1';


PlotSettings.ListOfCD4sToPlot=[200 350 500];
PlotSettings.YearsToPlot=[1970 CD4BackProjectionYearsWhole(2)];
PlotSettings.YearsToPlotForCD4AtDiagnosis=[1985 CD4BackProjectionYearsWhole(2)];






