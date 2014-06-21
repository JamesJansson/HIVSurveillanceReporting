% function SurveillanceReport
clear
clc
TimeALL=tic;

%% Load settings for the simualtion
% LoadSettings
LoadSettings2013


if InitialisePCToSRThisSim==false
    load([ParameterLocalStorageLocation 'PC2SR.mat']);%If PC2SR file cannot be found, it may need to be generated
else
    % Initialise postcode to statistical region coder
    disp('Initialising PCToSR system');
    [PC2SR]=InitialisePCToSR();
    
end


%% Load the patient data into a large matrix and create objects to store patient data
disp('Loading saved basic patient class data');

%open file format, return separately the postcodes and other subsections of the data 
[LineDataMatrix, LocationDataMatrix]=LoadNotificationFile(HIVFile, SheetName, PerformGeographicCalculations);

%Place data from LineDataMatrix into PatientData
[Patient]=CreatePatientObject(LineDataMatrix);

%Add state data to the system
Patient=GeoAddLocationData(Patient, LocationDataMatrix, PC2SR);

Identifier=1;
SavePatientClass(Patient, 'PatientSaveFiles',  Identifier);

%%
CalculateAIDSAndMortality


%% Collate results for table 6.1.1

clear Temp
YearRanges=1980:2013;
[~, YearSize]=size(YearRanges);
SimSize=100;
GenderSize=2;
StateSize=9;
[~, NoPatients]=size(Patient);
TotalPeople=zeros(34, SimSize);

MatrixValues=zeros(YearSize, GenderSize, StateSize, SimSize);

YearCount=0;
for Year=1980:2013
    YearCount=YearCount+1;
    disp(Year)
    for i=1:NoPatients
        
        TotalPeople(YearCount, :)=TotalPeople(YearCount, :)+Patient(i).AliveAndHIVPosInYear(Year);
        Temp(1, 1, 1, :)=Patient(i).AliveAndHIVPosInYear(Year);

        if Patient(i).Sex==1 || Patient(i).Sex==3
            SexValue=1;
        else
            SexValue=2;
        end
        

        MatrixValues(YearCount, SexValue,  Patient(i).StateAtDiagnosis, :)=MatrixValues(YearCount, SexValue,  Patient(i).StateAtDiagnosis, :)+Temp;
    end
end

Results=median(TotalPeople, 2);
hold off
plot(YearRanges, Results)

ResultsDetailed=median(MatrixValues, 4);
% The 2012 report figure
End2011Table=squeeze(ResultsDetailed(YearRanges==2012, :, :));
% The 2013 report figure
End2012Table=squeeze(ResultsDetailed(YearRanges==2013, :, :));


ResultFor2013Report=End2012Table';


