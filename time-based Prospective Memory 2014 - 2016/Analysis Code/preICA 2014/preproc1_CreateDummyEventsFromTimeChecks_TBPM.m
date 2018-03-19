
close all; clear all; clc;

homeFolder = '/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata';
allFolder  = dir('S*');
cd(homeFolder)

%% Count number of events


%=======================================
% Type events
%=======================================
% 1.TarCBL
% 2.TarIBL
% 3.NTaCBL
% 4.NTaIBL
% 5.TarC
% 6.TarI
% 7.NTaC
% 8.NTaI
% 9.chck
% 10.clck
% 11.rest

%=======================================
% Performance Categories for clock checks
%=======================================
% 1. Too Early (<3)
% 2. Early (3 <> 3.75) 3min <> 3min 45seg
% 3. Good (4min +- 0.25 min) 3min 45seg <> 4min 15seg
% 4. Late (4.25 <> 5) 4min 15seg <> 5
% 5. Forgot (> 5)

%=======================================
% Event Info Matrix
%=======================================
% time or trials between checks (between checks within blocks)
% time or trials in clock block (between clocks)
% clock block divided in 4
% Category result
% Eventtype

%% Create Response Matrix

% Eventtype, correct or incorrect

%
% ClockTaskMatrix  = nan(length(allFolder),5);
% RTDataEEG        = nan(length(allFolder),8);
% AccDataEEG       = nan(length(allFolder),2);
% AllSubjCheckHist = nan(length(allFolder),4);

for subj = 24%1:length(allFolder);
    
    filename=allFolder(subj).name;
    cd(allFolder(subj).name)
    
    tmpName = dir('*.raw');
    
    
    %% Load unprocessed data
    
    % Export raw file to eeglab
    EEG = pop_readegi(tmpName.name, [],[],'auto');
    EEG = pop_selectevent( EEG, 'type',{'TCBL','TIBL','NCBL','NIBL','TarC','TarI','NTaC','NTaI','resp','chck','clck','rest'},'deleteevents','on');
    
    % Get events and latency
    Events  = {EEG.event.type};
    latency = {EEG.event.latency};
    
    
    %% Add Dummy event every 1 second
   
    checks     = find(~cellfun(@isempty,strfind(Events, 'chck')));
    clocks     = find(~cellfun(@isempty,strfind(Events, 'clck')));
    TimeChecks = sort([checks clocks]);
    %  
    % Only consider Time check events separated by at least 2 secs
   
    ChecksLatency = [latency{TimeChecks}];
    TimeChecksEvents = ones(1,length( TimeChecks));
    for i = 1:length(ChecksLatency)-1
        if (latency{TimeChecks(i+1)}-latency{TimeChecks(i)})/250 > 2
            TimeChecksEvents(i+1) = 1;
        else
            TimeChecksEvents(i+1) = 0;            
        end
    end
    
    TC = TimeChecks(find(TimeChecksEvents));
    LatencyTC = [latency{TC}];
    
    % Create time check event
    
     fprintf('Adding %u new events ;-))))))) \n',length(LatencyTC));
     EEG = eeg_addnewevents(EEG,{LatencyTC},{'TCheck'});
     EEG = eeg_checkset( EEG );
    
    
    % Crate DummyTC every 2 seconds between two time checks only if there is at least 2
    % secs in between
     
    for i = 1:length(LatencyTC)-1
        if (LatencyTC(i+1)-LatencyTC(i))/250 > 4
            if (LatencyTC(i+1)-LatencyTC(i))/250 < 8
                DummyCheck = mean(LatencyTC(i):LatencyTC(i+1));
                fprintf('Adding %u new events ;-))))))) \n',length(DummyCheck));
                EEG = eeg_addnewevents(EEG,{DummyCheck},{'DC'});
                EEG = eeg_checkset( EEG );
            else
                tmpM = mean(LatencyTC(i):LatencyTC(i+1));
                DummyCheckA = (LatencyTC(i)+500:500:tmpM); %every 2 seconds
                fprintf('Adding %u new events ;-))))))) \n',length(DummyCheckA));
                EEG = eeg_addnewevents(EEG,{DummyCheckA},{'DC'});
                EEG = eeg_checkset( EEG );
                
                DummyCheckB = (LatencyTC(i+1)-500:-500:tmpM); %every two seconds
                fprintf('Adding %u new events ;-))))))) \n',length(DummyCheckB));
                EEG = eeg_addnewevents(EEG,{DummyCheckB},{'DC'});
                EEG = eeg_checkset( EEG );
            end
        else
            continue
        end
    end
    
    % Create Dummy events after the last check
    DummyCheck = (LatencyTC(end)+500:500:latency{end});
    fprintf('Adding %u new events ;-))))))) \n',length(DummyCheck));
    EEG = eeg_addnewevents(EEG,{DummyCheck},{'DC'});
    EEG = eeg_checkset( EEG );
    % Create Dummy events before the first check
    DummyCheck = (LatencyTC(1)-500:-500:latency{1});
    fprintf('Adding %u new events ;-))))))) \n',length(DummyCheck));
    EEG = eeg_addnewevents(EEG,{DummyCheck},{'DC'});
    EEG = eeg_checkset( EEG );
    
    % Update events and latency info
    Events  = {EEG.event.type};
    latency = {EEG.event.latency};
    
      
    %% Create Events Matrix
    
    % Find eventNumber of all events
    
    TCBL     = find(~cellfun(@isempty,strfind(Events, 'TCBL')));
    TIBL     = find(~cellfun(@isempty,strfind(Events, 'TIBL')));
    NCBL     = find(~cellfun(@isempty,strfind(Events, 'NCBL')));
    NIBL     = find(~cellfun(@isempty,strfind(Events, 'NIBL')));
    TarC     = find(~cellfun(@isempty,strfind(Events, 'TarC')));
    TarI     = find(~cellfun(@isempty,strfind(Events, 'TarI')));
    NTaC     = find(~cellfun(@isempty,strfind(Events, 'NTaC')));
    NTaI     = find(~cellfun(@isempty,strfind(Events, 'NTaI')));
    checks   = find(~cellfun(@isempty,strfind(Events, 'chck')));
    clocks   = find(~cellfun(@isempty,strfind(Events, 'clck')));
    rest     = find(~cellfun(@isempty,strfind(Events, 'rest')));
    DC       = find(~cellfun(@isempty,strfind(Events, 'DC')));
    TC       = find(~cellfun(@isempty,strfind(Events, 'TCheck')));
    resp     = find(~cellfun(@isempty,strfind(Events, 'resp')));
    
    
    EventNumber = sort([TCBL TIBL NCBL NIBL TarC TarI NTaC NTaI checks clocks rest DC TC resp]);
    
    EventsInfoMatrix = zeros(length(EventNumber),12);
    
    % ======================================================================
    % Column 1 = Event number
    % ======================================================================
    EventsInfoMatrix(:,1) =  EventNumber';
    
    % ======================================================================
    % Column 2 = EventCode  1       2      3      4       5         6      7      8      9      10      11     12    13   14
    % ======================================================================
    Eventtype            = {'TCBL','NCBL','TarC','NTaC','checks','clocks','TIBL','NIBL','TarI','NTaI', 'rest', 'DC', 'TC','resp'};
    column2              = nan(length(Events),1);
    for it = 1:length( Eventtype )
        eval(['column2(',Eventtype{it},',1)=',num2str(it),';']);
    end
    EventsInfoMatrix(:,2) = column2(~isnan(column2(:, 1)), :);
    
    % ======================================================================
    % Column 3 = Latency
    % ======================================================================
    EventsInfoMatrix(:,3) = [latency{EventNumber}];
    
    
    % ======================================================================
    % Column 4 = Clock Block
    % ======================================================================
    ClockTime0 =  find(ismember(EventsInfoMatrix(:,2),[3 4 9 10]),1); % clock time starts
    ClockTimes =  find(EventsInfoMatrix(:,2)==6); % Clock time for clock reset
    ClockResetTime = [ClockTime0 ; ClockTimes];
    %ClockResetTime = [ClockTime0 ; ClockTimes ;length(EventsInfoMatrix(:,4))]; in caseI want to label events out of
    %clock blocks
    
    for tn = 1:length(ClockResetTime)-1
        EventsInfoMatrix(ClockResetTime(tn):ClockResetTime(tn+1)-1,4)=tn;
    end
    
    
    % ======================================================================
    % Column 5 = Clock Reset Category result
    % ======================================================================
    NbClockReset    = length(ClockTimes);
    LatencyClockReset = EventsInfoMatrix(ClockResetTime,3);
    
    % Duration of each clock check
    ClockResetDur = nan(1,NbClockReset);
    for it = 1:NbClockReset;
        ClockResetDur(it) = (LatencyClockReset(it+1)-LatencyClockReset(it))/250/60;
    end
    
    % Categorise duration
    TimeCategories = [0 2 3 3.75 4.25 5 100];
    PerformanceClassification = nan(1,NbClockReset);
    
    for chcktm = 1: NbClockReset;
        for t = 1:length(TimeCategories);%  different categories
            if ClockResetDur(chcktm) >= TimeCategories(t) && ClockResetDur(chcktm) < TimeCategories(t+1)
                PerformanceClassification(chcktm)=t;
            end
        end
    end
    
    % Assign Clock Block category to column 5
    for it = 1:NbClockReset;
        EventsInfoMatrix(find(EventsInfoMatrix(:,4)==it),5)=PerformanceClassification(it);
    end
    
    % ======================================================================
    % Column 6 = divide clock block time in 4 time chuncks
    % ======================================================================
    
    for it = 1:NbClockReset;
        LatencyChunck   = (LatencyClockReset(it+1)-LatencyClockReset(it))/4;
        Time0 = LatencyClockReset(it);
        Time1 = LatencyClockReset(it)+LatencyChunck;
        Time2 = LatencyClockReset(it)+LatencyChunck*2;
        Time3 = LatencyClockReset(it)+LatencyChunck*3;
        Time4 = LatencyClockReset(it)+LatencyChunck*4; % = LatencyClockReset(it+1)
        
        tmpTime = [Time0 Time1 Time2 Time3 Time4];
        
        for T = 1:4;
            Idx  = EventsInfoMatrix(EventsInfoMatrix(:,3) >=  tmpTime(T) & EventsInfoMatrix(:,3) < tmpTime(T+1));%Find Event number
            CIdx = find(ismember(EventsInfoMatrix(:,1),Idx)); %find event consecutive number
            EventsInfoMatrix(CIdx,6)=T;
        end
        
        
        
    end
    
    
    % ======================================================================
    % Column 7 and 8 = Trialnumber in clock (7) and Time between clock reset (8)
    % ======================================================================
    
    for tn = 1:length(ClockResetTime)-1
        tmpCountTrials = (ClockResetTime(tn+1) - ClockResetTime(tn));
        
        T0 = EventsInfoMatrix(ClockResetTime(tn),3);
        EventsInfoMatrix(ClockResetTime(tn):ClockResetTime(tn+1)-1,8)=...
            (EventsInfoMatrix(ClockResetTime(tn):ClockResetTime(tn+1)-1,3)-T0)/250/60;
        
        EventsInfoMatrix(ClockResetTime(tn):ClockResetTime(tn+1)-1,7)=(1:1:tmpCountTrials)';
    end
    
    % ======================================================================
    % Column 9 = divide clock checks block time in 4 time chuncks
    % ======================================================================
    
    ClockTimes        = find(ismember(EventsInfoMatrix(:,2),[5 6])); % Clock time for checks and clock reset
    ClockResetTime    = [ClockTime0 ; ClockTimes ];
    NbClockChecks     = length(ClockTimes);
    LatencyClockReset = EventsInfoMatrix(ClockResetTime,3);
   
    for it = 1:NbClockChecks;
        LatencyChunck   = (LatencyClockReset(it+1)-LatencyClockReset(it))/4;
        Time0 = LatencyClockReset(it);
        Time1 = LatencyClockReset(it)+LatencyChunck;
        Time2 = LatencyClockReset(it)+LatencyChunck*2;
        Time3 = LatencyClockReset(it)+LatencyChunck*3;
        Time4 = LatencyClockReset(it)+LatencyChunck*4; % = LatencyClockReset(it+1)
        
        tmpTime = [Time0 Time1 Time2 Time3 Time4];
        
        for T = 1:4;
            Idx  = EventsInfoMatrix(EventsInfoMatrix(:,3) >=  tmpTime(T) & EventsInfoMatrix(:,3) < tmpTime(T+1));%Find Event number
            CIdx = find(ismember(EventsInfoMatrix(:,1),Idx)); %find event consecutive number
            EventsInfoMatrix(CIdx,9)=T;
        end
    end
    
    
    % ======================================================================
    % Column 10 and 11 = trial number in clock check and time between clock checks (for ongoing)
    % ======================================================================
    
    
    
    for tn = 1:length(ClockResetTime)-1
        tmpCountTrials = (ClockResetTime(tn+1) - ClockResetTime(tn));
        
        T0 = EventsInfoMatrix(ClockResetTime(tn),3);
        EventsInfoMatrix(ClockResetTime(tn):ClockResetTime(tn+1)-1,11)=...
            (EventsInfoMatrix(ClockResetTime(tn):ClockResetTime(tn+1)-1,3)-T0)/250/60;
        
        EventsInfoMatrix(ClockResetTime(tn):ClockResetTime(tn+1)-1,10)=(1:1:tmpCountTrials)';
    end
    
    % ======================================================================
    % Column 12 = time around Time checks events
    % ======================================================================
    
    TimeCheckLatency = [latency{ClockTime0} latency{TC}];
    TimeCheckEvent = [ClockTime0 TC];
    
    for tn = 1:length(TimeCheckLatency)-1
        tmpM = mean(TimeCheckLatency(tn):TimeCheckLatency(tn+1));
        medEventL = find(EventsInfoMatrix(:,3)<tmpM,1,'last');
        medEventU = find(EventsInfoMatrix(:,3)>tmpM,1);
        
        EventsInfoMatrix(TimeCheckEvent(tn):medEventL,12) = ...
            (EventsInfoMatrix(TimeCheckEvent(tn):medEventL,3)-TimeCheckLatency(tn))/250/60;
        
        EventsInfoMatrix(medEventU:TimeCheckEvent(tn+1),12) = ...
            (EventsInfoMatrix(medEventU:TimeCheckEvent(tn+1),3)-TimeCheckLatency(tn+1))/250/60;
       
    end
    
    
    
     
        
    %% Chage label from DC to DCBL
    % use TimeClock0 to change label of DC to DCBL
    DCEventNumber = DC(DC<ClockTime0);
    
    for e = 1:length(DCEventNumber)
        EEG.event(DCEventNumber(e)).type = 'DCBL';
    end
   
    %% Change Event type name for overlap between ongoing trials and time check
    % Find events after a break and modify Eventtype, so after break events are not included
    % in ongoing analysis.
    OngoingTrials = sort([TarC TarI NTaC NTaI]);
    
    for r = 1:length(rest)
        afterBreak = find(OngoingTrials>rest(r),1);
        if ~isempty(afterBreak)
            EEG.event(OngoingTrials(afterBreak)).type = [EEG.event(OngoingTrials(afterBreak)).type '_rest' ];
            EventsInfoMatrix(OngoingTrials(afterBreak),2)= str2num([num2str(EventsInfoMatrix(OngoingTrials(afterBreak),2)) '11']);
        end
    end
    
    % Find ongoing events overlaping with time check events so only pure
    % ongoing trials are included in the ERP ongoing analysis
    
    % Find and rename events before and after clock checks
    for ch = 1:length(checks)
        afterChecks = find(OngoingTrials>checks(ch),1);
        if ~isempty(afterChecks)
            EEG.event(OngoingTrials(afterChecks)).type = [EEG.event(OngoingTrials(afterChecks)).type '_check' ];
            EventsInfoMatrix(OngoingTrials(afterChecks),2)= str2num([num2str(EventsInfoMatrix(OngoingTrials(afterChecks),2)) '5']);
        end
        
        beforeChecks = find(OngoingTrials<checks(ch),1,'last');
        if ~isempty(beforeChecks)
            EEG.event(OngoingTrials(beforeChecks)).type = [EEG.event(OngoingTrials(beforeChecks)).type '_check' ];
            EventsInfoMatrix(OngoingTrials(beforeChecks),2)= str2num([num2str(EventsInfoMatrix(OngoingTrials(beforeChecks),2)) '5']);
        end
    end
    
    % Find and rename events before and after clock reset
    for ch = 1:length(clocks)
        afterClocks = find(OngoingTrials>clocks(ch),1);
        if ~isempty(afterClocks)
            EEG.event(OngoingTrials(afterClocks)).type = [EEG.event(OngoingTrials(afterClocks)).type '_clock' ];
            EventsInfoMatrix(OngoingTrials(afterClocks),2)= str2num([num2str(EventsInfoMatrix(OngoingTrials(afterClocks),2)) '6']);
        end
        
        beforeClocks = find(OngoingTrials<clocks(ch),1,'last');
        if ~isempty(beforeClocks)
            EEG.event(OngoingTrials(beforeClocks)).type = [EEG.event(OngoingTrials(beforeClocks)).type '_clock' ];
            EventsInfoMatrix(OngoingTrials(beforeClocks),2)= str2num([num2str(EventsInfoMatrix(OngoingTrials(beforeClocks),2)) '6']);
        end
    end
    
    %% Add new Event field
    
    %Vector with length of EEG.events containing the new event field info
    
    % Clock Reset category column 5
    fprintf('Adding new event field: Clock Reset category \n');
    EEG = pop_editeventfield( EEG, 'ClockCategory',EventsInfoMatrix(:,5));
    EEG = eeg_checkset( EEG );
    
    % Clock Time column 8
    fprintf('Adding new event field: Reset Time \n');
    EEG = pop_editeventfield( EEG, 'ResetTime',EventsInfoMatrix(:,8));
    EEG = eeg_checkset( EEG );
    
    % Clock chunk column 6
    fprintf('Adding new event field: Clock Chunk \n');
    EEG = pop_editeventfield( EEG, 'ResetChunk',EventsInfoMatrix(:,6));
    EEG = eeg_checkset( EEG );
    
    
    % Clock Time column 8
    fprintf('Adding new event field: Check Time \n');
    EEG = pop_editeventfield( EEG, 'CheckTime',EventsInfoMatrix(:,11));
    EEG = eeg_checkset( EEG );
    
    % Clock chunk column 9
    fprintf('Adding new event field: Check Chunk \n');
    EEG = pop_editeventfield( EEG, 'CheckChunk',EventsInfoMatrix(:,9));
    EEG = eeg_checkset( EEG );
    
    % Timer around check column 12
    fprintf('Adding new event field: CheckTimer \n');
    EEG = pop_editeventfield( EEG, 'CheckTimer',EventsInfoMatrix(:,12));
    EEG = eeg_checkset( EEG );
    
    
    %% save dataset

    EEG = pop_saveset( EEG,  'filename', filename,'filepath',pwd);
    
    % Save eventInfoMatrix
    save('EventsInfoMatrix.mat','EventsInfoMatrix');
    
    cd(homeFolder)
end





