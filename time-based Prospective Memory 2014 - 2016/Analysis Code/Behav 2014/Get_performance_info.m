
close all; clear all; clc;

homeFolder = '/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/rawSetData';
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

%% Create Response Matrix

ClockTaskMatrix  = nan(length(allFolder),6);
RTDataEEG        = nan(length(allFolder),8);
AccDataEEG       = nan(length(allFolder),2);
AllSubjCheckHist = nan(length(allFolder),4);

for subj = 1:length(allFolder);
    
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
        
    %% Plot data
    t = 1:length({EEG.event.type});
                        %dark blue, black, light blue, dark green,light green 
    colorEventType  = {[0.5,0.5,0.5] ,'k',[0.5,0.5,1],'k',[0,0.5,0],'k',[0,1,0],'k','w','b','r','y'};
    Eventtype       = {'TCBL','TIBL','NCBL','NIBL','TarC','TarI','NTaC','NTaI','resp','chck','clck','rest'};
    Stimhigh        = [0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.001,0.8,0.8,0.3];
    
    f1 = figure;hold on;
    for Stim = 1: length(Eventtype)
        StimIdx  = find(~cellfun(@isempty,strfind(Events, Eventtype{Stim})));
        stem(t(StimIdx),t(StimIdx)*0+Stimhigh(Stim),'Color',colorEventType{Stim})
    end
   
   %% Time Based Prospective Memory Performance  
   % Calculate clock checking periods. Instruction was to press clock after 4 minutes
   % From latency to minutes
   
   % ==============================================
   % Find first Target in PM block (time clock 0)
   % ==============================================
  
   FirstofAll = nan(1,4);
   for Stim = 5:8; % find index of PM block events
       FirstStimIdx         = find(~cellfun(@isempty,strfind(Events, Eventtype{Stim})),1);
       FirstofAll(Stim-4)   = FirstStimIdx ; 
   end
   IdxTime0         = min(FirstofAll);
   
   % ==============================================
   % Find clock reset events
   % ==============================================
   IdxClckTimes  = find(~cellfun(@isempty,strfind(Events, 'clck')));
   IdxClckTimes  = IdxClckTimes(IdxClckTimes>IdxTime0);
   NbClockReset  = length(IdxClckTimes);
   
   % Create Array with all ClockTime events
   TimeEvents = [ IdxTime0 IdxClckTimes  ];
   
   % ==============================================
   % Duration of each clock check
   % ==============================================
   ClockResetDur = nan(1,NbClockReset);
   for it = 1:NbClockReset;
        ClockResetDur(it) = (latency{TimeEvents(it+1)}-latency{TimeEvents(it)})/250/60;
   end
 %  save('ClockResetDur_Matrix.mat','ClockResetDur');
   
   % Plot Check performance, diff from 4 minutes
%    DevFrom4min = 4 - ClockResetDur;
%    f2 = figure;hold on;
%    subplot(2,2,1);
%    b=bar(DevFrom4min,'r');
%    axis([0 NbClockReset+1 -2 4]);
%    title('Clock periods deviation from 4 min');
%    
   % ==============================================
   % Create Performance Categories 
   % ==============================================
   % 1. Extremely  Early (<2) - yellow
   % 2. Too Early 2><3
   % 3. Early (3 <> 3.75) 3min <> 3min 45seg - blue
   % 4. Good (4min +- 0.25 min) 3min 45seg <> 4min 15seg - green
   % 5. Late (4.25 <> 5) 4min 15seg <> 5 - red
   % 6. Forgot (> 5) - black
   
   
   TimeCategories = [0 2 3 3.75 4.25 5 100];
   PerformanceClassification = nan(1,NbClockReset);
   %CategoriesColor = {'y',[0.5  0.5  1 ],'b','g','r','k'};
   
   for chcktm = 1: NbClockReset;
       for t = 1:length(TimeCategories);% 5 different categories
           if ClockResetDur(chcktm) >= TimeCategories(t) && ClockResetDur(chcktm) < TimeCategories(t+1)
               PerformanceClassification(chcktm)=t;
           end
           
       end
   end
   
   
   % ==============================================
   % plot 2,2,1 according performance categories
   % ==============================================
     % Plot Check performance, diff from 4 minutes

   CategoriesColor = {[1 1 0],[0.5 0.5 1],[0 0 1],[0 1 0],[1 0 0],[0 0 0]};
   colors = CategoriesColor(PerformanceClassification);
   
   DevFrom4min = 4 - ClockResetDur;
   f2 = figure;hold on;
   subplot(2,2,1);hold on;
    
   for i = 1:numel(DevFrom4min)
        b = bar(i, DevFrom4min(i));%hold on;
        set(b, 'FaceColor', colors{i}) 
   end
  
   axis([0 NbClockReset+1 -2 4]);
   title('Clock periods deviation from 4 min');
   
   
   % ==============================================
   % Number of clock checks per clock period (between clock reset)
   % ==============================================
   
   
   NbClockCheckPerReset = nan(1,NbClockReset);
   
   for it = 1:NbClockReset 
        IdxClckChecks            = find(~cellfun(@isempty,strfind(Events(TimeEvents(it):TimeEvents(it+1)), 'chck')));
        NbClockCheckPerReset(it) = length(IdxClckChecks);
   end
   
   
   subplot(2,2,3);
   bar(NbClockCheckPerReset,'b');
   axis([0 NbClockReset+1 0 10]);
   title('Number of checks per clock period');
   
   % ==============================================
   % Calculates time of each time check and assign performance category
   % ==============================================
    
   ClockChecks          = find(~cellfun(@isempty,strfind(Events(1:TimeEvents(end)), 'chck')));
   ClockchecksLatency   = latency(ClockChecks);
   ChecksTime           = nan(1,length(ClockChecks)); % Time of clock checking between clocks reset
   ChecksCategory       = nan(1,length(ClockChecks));
   NbPeriodPerCategory  = nan(1,6);
   
   for chcklat = 1:length(ClockchecksLatency);
       for it = 1:NbClockReset;
           if latency{TimeEvents(it)} < ClockchecksLatency{chcklat} && ClockchecksLatency{chcklat}  < latency{TimeEvents(it+1)}
               ChecksTime(chcklat)       = (ClockchecksLatency{chcklat}-latency{TimeEvents(it)})/250/60;
               ChecksCategory(chcklat)   = PerformanceClassification(it); 
           end
       end
   end
  
      % Save Clock checks time
   save('ClockChecksDur_Matrix.mat','ChecksTime')
   
   % ==============================================
   % Plot checks according category
   % ==============================================
   H = [0.1 0.2 0.3 0.5 0.7 0.9];
   %f3 = figure;
   subplot(2,2,2)
   hold on;
   for cat = 1:6;
       CheckCat                 = find(ChecksCategory  == cat); 
       stem(ChecksTime(CheckCat),ChecksTime(CheckCat)*0+H(cat),'Color',CategoriesColor{cat});
       tmpCatNb                 = find(PerformanceClassification  == cat);  
       NbPeriodPerCategory(cat) = length(tmpCatNb  );
   end
   title('Time checks according performance');
   axis([0 4.5 0 1]);


   
    ClockTaskMatrix(subj,:) = NbPeriodPerCategory;
   
   % ==============================================
   % Histogram of checks for each clock period according performance
   % ==============================================
   
   subplot(2,2,4) 
   hist(ChecksTime,4); %total
   h=hist(ChecksTime,4);
    title('Histogram of Time checks'); 
   AllSubjCheckHist(subj,:) = h;  
   %axis([0 4.5 0 max(h)+1]); 
   
   % ==============================================
   % Save figures
   % ==============================================
    
   %print( f1, '-depsc2', [filename '_results_summary']) 
   print( f2, '-depsc2', [filename '_ClockTask']) 
   

   
   
   %% Create a super matrix for performance (similar with CSTG)
   % calculate number of clocks, minutes where clock was pressed,  add minutes as a new event field for all events.
   % get general performance and add new tags according that
   
   % Find eventNumber of all events
   
   TarC     = find(~cellfun(@isempty,strfind(Events, 'TarC')));
   TarI     = find(~cellfun(@isempty,strfind(Events, 'TarI')));
   NTaC     = find(~cellfun(@isempty,strfind(Events, 'NTaC')));
   NTaI     = find(~cellfun(@isempty,strfind(Events, 'NTaI')));
   checks   = find(~cellfun(@isempty,strfind(Events, 'chck')));
   clocks   = find(~cellfun(@isempty,strfind(Events, 'clck')));
   rest     = find(~cellfun(@isempty,strfind(Events, 'rest')));
   
   OngEvents = sort([TarC TarI NTaC NTaI]);
   
   %% Ongoing Task Performance
  
   % Find events after a break and modify Eventtype, so after break events are not included
   % in ongoing analysis
   
   for r = 1:length(rest)
       afterBreak = find(OngEvents>rest(r),1);
       if ~isempty(afterBreak) 
        EEG.event(OngEvents(afterBreak)).type = [EEG.event(OngEvents(afterBreak)).type '_break' ];
       end
   end
   
   % Find and rename events before and after clock checks
   for ch = 1:length(checks)
       afterChecks = find(OngEvents>checks(ch),1);
       if ~isempty(afterChecks) 
        EEG.event(OngEvents(afterChecks)).type = [EEG.event(OngEvents(afterChecks)).type '_check' ];
       end
       
       beforeChecks = find(OngEvents<checks(ch),1,'last');
       if ~isempty(beforeChecks) 
        EEG.event(OngEvents(beforeChecks)).type = [EEG.event(OngEvents(beforeChecks)).type '_check' ];
       end
   end
   
      % Find and rename events before and after clock reset
   for ch = 1:length(clocks)
       afterClocks = find(OngEvents>clocks(ch),1);
       if ~isempty(afterClocks) 
        EEG.event(OngEvents(afterClocks)).type = [EEG.event(OngEvents(afterClocks)).type '_clock' ];
       end
       
       beforeClocks = find(OngEvents<clocks(ch),1,'last');
       if ~isempty(beforeClocks) 
        EEG.event(OngEvents(beforeClocks)).type = [EEG.event(OngEvents(beforeClocks)).type '_clock' ];
       end
   end
   
   
   %%

   % epoch data - only to count events and get RT
        
       % EEG = pop_selectevent( EEG, 'type',{'TCBL','TIBL','NCBL','NIBL','TarC','TarI','NTaC','NTaI','resp','chck','clck','rest'},'deleteevents','on');
        EEG = pop_epoch( EEG, {  'TCBL','TIBL','NCBL','NIBL','TarC','TarI','NTaC','NTaI'  }, [0       2], 'epochinfo', 'yes');
        EEG = eeg_checkset( EEG );
        
        
   %% check that all epochs have only 2 events: Event and RT
        
        Events     = {EEG.event.type};     
        AllEpochs  = {EEG.epoch.eventtype};
       
        ExtraEvent = [];
        for Ev = 1:length(AllEpochs)
            if length(AllEpochs{Ev}) > 2
                ExtraEvent = Ev;
                fprintf('Check epoch: %u\n',Ev)
            end
        end
        
       
        
        %% Create behaviour matrix if number of events is ok
        % Create event matrix in the session 1
        
        EventMatrix = cell(length(EEG.epoch),2);
        
        
        if isempty(ExtraEvent)
            fprintf('Number of events is OK \n')
            EventsLat = {EEG.epoch.eventlatency};
            
            %% Complete Matrix with events and reaction times
            
            for j = 1:length(AllEpochs)
                EventMatrix(j,1) = AllEpochs{j}(1);
                if length(AllEpochs{j}) == 2 % it only completes latencies if there was a resp
                    EventMatrix(j,2) = EventsLat{j}(2);
                end
            end
            
            
            %% Get performance Info per condition (see Eventtype array)
            Eventtype       = {'TCBL','TIBL','NCBL','NIBL','TarC','TarI','NTaC','NTaI'};
            
            % RT for all event types
            tempAcc = nan(1,length(Eventtype));
            for Stim = 1: length(Eventtype)
                StimIdx              = find(~cellfun(@isempty,strfind(EventMatrix(1:length(AllEpochs),1), Eventtype{Stim})));
                RTStim               = mean([EventMatrix{StimIdx,2}]);
                tempAcc(Stim)        = length(StimIdx);
                RTDataEEG(subj,Stim) = RTStim;
            end
            % Acc Control Task
            AccDataEEG(subj,1) = sum(tempAcc([1 3]))/sum(tempAcc(1:4))*100;
            % Acc Ongoing Task
            AccDataEEG(subj,2) = sum(tempAcc([5 7]))/sum(tempAcc(5:8))*100;
           
            
            
            
            
        end
    %Save Matrix of each participant
    
    BehavInfo(subj,:) = [RTDataEEG(subj,[1 3 5 7]) AccDataEEG(subj,:) NbPeriodPerCategory];
    
    save('Events_Matrix.mat','EventMatrix');
    close all
    cd(homeFolder)
end

%%

   % ==============================================
   % Save clock task file
   % ==============================================
  
save('/Users/gabycruz/experiments/EEG_timebased_PM/behavFromEEGfiles/ClockTaskMatrix.mat','ClockTaskMatrix');
save('/Users/gabycruz/experiments/EEG_timebased_PM/behavFromEEGfiles/RT_All.mat','RTDataEEG');
save('/Users/gabycruz/experiments/EEG_timebased_PM/behavFromEEGfiles/Acc_All.mat','AccDataEEG');
save('/Users/gabycruz/experiments/EEG_timebased_PM/behavFromEEGfiles/TBPM.mat','BehavInfo');
save('/Users/gabycruz/experiments/EEG_timebased_PM/behavFromEEGfiles/AllSubjCheckHist.mat','AllSubjCheckHist');

 

%% Plot Ong RT Task Data

DataMean = mean(RTDataEEG(:,[1 3 5 7]));
DataStd  = std(RTDataEEG(:,[1 3 5 7]));

figure,
hold on
% TBLP,TP,TBLC,TC,NTBLP,NTP,NTBLC,NTC

%Targets bars
bar([1,2],[DataMean(:,1),DataMean(:,3)],'FaceColor',[1,1,1]*0.5,'EdgeColor',[1,1,1]*0.5,'BarWidth',0.8)
errorbar([1,2],[DataMean(:,1),DataMean(:,3)]...
    ,[DataStd(:,1),DataStd(:,3)],'.k','MarkerSize',1,'Color',[1,1,1]*0.5) 

% NonTarget Bars
bar([4,5],[DataMean(:,2),DataMean(:,4)],'FaceColor',[1,1,1]*0.3,'EdgeColor',[1,1,1]*0.3,'BarWidth',0.8)
errorbar([4,5],[DataMean(:,2),DataMean(:,4)]...
    ,[DataStd(:,2),DataStd(:,4)],'.k','MarkerSize',1,'Color',[1,1,1]*0.3) 

axis([0 6 300 1000]) 

%% Plot RT all participants

TargetRT    = RTDataEEG(:,[1 5]);
NonTargetRT = RTDataEEG(:,[3 7]);

figure;
bar(1:length(allFolder),TargetRT );

% Add title and axis labels
title('Reaction Time Target control ongoing versus PM');
xlabel('Participants');
ylabel('RT');

figure;
bar(1:length(allFolder),NonTargetRT );

% Add title and axis labels
title('Reaction Time NonTarget control ongoing versus PM');
xlabel('Participants');
ylabel('RT');



%% Plot Ongoing Task Error Rate

figure,
hold on
% TBLP,TP,TBLC,TC,NTBLP,NTP,NTBLC,NTC
DataMean=100-mean(AccDataEEG);
DataStd =std(AccDataEEG);
%Targets bars
bar([1,2],[DataMean(:,1),DataMean(:,2)],'FaceColor',[1,1,1]*0.5,'EdgeColor',[1,1,1]*0.5,'BarWidth',0.8)
errorbar([1,2],[DataMean(:,1),DataMean(:,2)]...
    ,[DataStd(:,1),DataStd(:,2)],'.k','MarkerSize',1,'Color',[1,1,1]*0.5) 

axis([0 3 0 20]) 

% Plot Percentage error per participant
%% Plot Error rate all participants

SubjError = 100-AccDataEEG;

figure;
bar(1:length(allFolder),SubjError);
% Adjust the axis limits
axis([0 25 0 23]);


% Add a legend
legend('Ongoing control', 'Ongoing PM');

% Add title and axis labels
title('Error rate ongoing task');
xlabel('Participants');
ylabel('Error rate');

%% Plot Clock Check Data
% 

% Plot Individual Performance
CM = ClockTaskMatrix;

totalClockChecks = sum(CM);

figure;
bar(1:length(allFolder), CM,0.5,'stack');

P=findobj(gca,'type','patch');
C={'k','r','g','b',[0.5 0.5 1],'y'}; % make a colors list
%{[1 1 0],[0.5 0.5 1],[0 0 1],[0 1 0],[1 0 0],[0 0 0]};
%'yellow' 'light blue' 'blue' 'green'  'red'   'black'

    for n=1:length(P)
        set(P(n),'facecolor',C{n});
    end

% Adjust the axis limits
axis([0 25 0 15]);

% Add title and axis labels
title('Clock checks per participants');
xlabel('Participants');
ylabel('Number of clock checks');

% Add a legend
%legend('TooEarly', 'Early','Good', 'Late','Forgot');

%% Plot performance overview


RC = ClockTaskMatrix(:,4);
E = SubjError(:,2);
performance = RC./E;
performance = performance/max(performance); %normalise performance
figure;stem(performance);

figure;boxplot(performance);
%See performance_plot for pairwise linear correlation coeffecient

%% Plot performance overview considering categories 3 4 5 (between 3 and 5 minutes)


RC = sum(ClockTaskMatrix(:,3:5),2);
E = SubjError(:,2);
performance = RC./E;
performance = performance/max(performance); %normalise performance
figure;stem(performance);

figure;boxplot(performance);

figure; 
h=boxplot(performance);
median = get(h(6),'ydata');
uv = get(h(5),'ydata');

PerformancebyNormalisedBoxPlot = nan(1,24);
PerformancebyNormalisedBoxPlot(find(performance > uv(2))) = 1; % Good Performers
PerformancebyNormalisedBoxPlot(find(performance > median(2) & performance <  uv(2))) = 2; % Medium Performers
PerformancebyNormalisedBoxPlot(find(performance < median(2) & performance >  uv(1))) = 3; % Medium Performers

find(performance > uv(2));



findobj(gcf,'tag','Outliers');
xdata = get(h,'XData');
ydata = get(h,'YData');
%See performance_plot for pairwise linear correlation coeffecient%% Event info matrix

% time or trials between checks (between checks within blocks)
% time or trials in clock block (between clocks)
% clock block divided in 4
% Category result


