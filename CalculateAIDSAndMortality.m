
% In order to run this file, the back projection on data should have already occurred


tic
NumSims=100;

%% Load the results of the back projection
% load('PatientSaveFiles/BackProjectedResults.mat');
% [NumSims, ~]=size(BackProjectedResults.TotalUndiagnosedByTime);


%% Load up the standardised mortality rate information
SMR=MortalityClass;

MortalityTableFile= 'MortalityData\MortalityTables.xls';
SMRFile= 'MortalityData\HIVStandardisedMortalityRateOriginalValuesFromStudy.xlsx';
SMR=SMR.LoadData(MortalityTableFile, SMRFile, NumSims);


 
    % Load up save patient data from backprojection calculations
    disp('Loading patient data');
    Identifier=1;
    Patient=LoadPatientClass('PatientSaveFiles', Identifier);
    %% AIDS related functions
    [AIDSProgression, ViralLoadProbability, VLCD4Locator]=SetUpAIDSProgession;
    %Progress people to AIDS
    disp('Performing AIDS progression');
    [Patient, YearOfDiagnosisArray]=ProgressToAIDS(Patient, AIDSProgression, ViralLoadProbability, VLCD4Locator);
    hist(YearOfDiagnosisArray, 1980:2012);%Compare with Nakhaee et al. Table 4 AIDS diagnoses
    hold off;
    CheckAIDSResults=false;
    if CheckAIDSResults==true
        AIDSDiagnosisVector=[];
        for CurrentPatient=Patient
            AIDSDiagnosisVector=[AIDSDiagnosisVector CurrentPatient.YearOfAIDSDiagnosis];
        end
        [AIDSDiagnosisVectorHisty, AIDSDiagnosisVectorHistx]=hist(AIDSDiagnosisVector, 1980.5:1999.5);
        %disp([B;A]')
            %         1980           0
            %         1981           0
            %         1982           0
            %         1983           0
            %         1984          56
            %         1985         278
            %         1986         517
            %         1987         755
            %         1988         834
            %         1989         931
            %         1990        1064
            %         1991        1027
            %         1992        1084
            %         1993        1155
            %         1994        1170
            %         1995        1073
            %         1996        1112
            %         1997         482
            %         1998           0
            %         1999           0
            %         2000           0
            %These results are a little above what is expected, but aren't bad overall

    end

    %% Calculating moratlity
    [~, NoPatients]=size(Patient);
%     YearOfDeathMat=zeros(NoPatients, NumSims);
    
    for SimNum=1:NumSims
        YearOfDeathStorage(SimNum).v=zeros(1, NoPatients);
    end
    
    
    MortalityTimer=tic;
    matlabpool(getenv('NUMBER_OF_PROCESSORS'));
    parfor SimNum=1:NumSims
%     for SimNum=1:NumSims
        disp(['Performing mortality calculation on sim ' num2str(SimNum) ' of ' num2str(NumSims) ' ' num2str(toc(MortalityTimer)) 'seconds']);
        LoopSMR=SMR.RestartRandomNumbers();%Put here to ensure matlab parfor doesn't get confused
        LPatient=Patient;%same as above
        for i=1:NoPatients
            DateOfDiagnosis=LPatient(i).DateOfDiagnosisContinuous;
            AgeAtInfection=LPatient(i).CurrentAge(DateOfDiagnosis);
            [YearOfDeath, AgeOfDeath]=LoopSMR.DetermineDeath(DateOfDiagnosis, AgeAtInfection, LPatient(i).Sex, LPatient(i).YearOfAIDSDiagnosis, SimNum);

            %YearOfDeathMat(i, SimNum)=YearOfDeath;
            
            YearOfDeathStorage(SimNum).v(i)=YearOfDeath;
        end
    end
    matlabpool close;

    %Copy mortality information back into the patient structure
    for i=1:NoPatients
        %Patient(i).YearOfDeath=YearOfDeathMat(i, :);
        Patient(i).YearOfDeath=zeros(1, NumSims);
        for SimNum=1:NumSims
            Patient(i).YearOfDeath(SimNum)=YearOfDeathStorage(SimNum).v(i);
        end
    end

        TimeOFAIDSCalculation=toc;
        
%         OutputGraphsMortality;
        

        
%         hold on;
%         Simi=0;
%         for SimNum=1:100%Sims
%             Simi=Simi+1;
%             [f, x]=hist(YearOfDeathStorage(SimNum).v, 1980:2020);
%             plot(x, f)
%         end

        
        
%     DeathsByYear=[];
%     for SimNum=1:NumSims
% %         [DeathsThisSimByYear, YearForPlot]=hist(YearOfDeathMat(:, SimNum), YearsToPlotOver+0.5);
%         [DeathsThisSimByYear, YearForPlot]=hist(YearOfDeathStorage(SimNum).v, YearsToPlotOver+0.5);
%         DeathsByYear=[DeathsByYear; DeathsThisSimByYear];
%     end
    
    
    
    
    

    
    
%     %Determine diagnoses by year
%     DiagnosisDates=zeros(1, NoPatients);
%     for i=1:NoPatients
%         if mod(i, 1000)==0
%             disp([i])
%         end
%         DiagnosisDates(i)=Patient(i).DateOfDiagnosisContinuous;
%     end
%     
%     
%     %% Plotting output
%     DiagnosesByYear=hist(DiagnosisDates, YearsToPlotOver+0.5);
%     plot(YearsToPlotOver, DiagnosesByYear);
%     
%     UCI=prctile(DeathsByYear, 97.5, 1);
%     LCI=prctile(DeathsByYear, 2.5, 1);
%     MedianDeaths=prctile(DeathsByYear, 50, 1);
%     plot(YearsToPlotOver, MedianDeaths);
%     hold on;
%     plot(YearsToPlotOver, UCI);
%     plot(YearsToPlotOver, LCI);
    
    
    %% Save data to a new patient file, identifier 2
    Identifier=2;
    SavePatientClass(Patient, 'PatientSaveFiles',  Identifier);
    
    save('PatientSaveFiles/SMR.mat', 'SMR');


