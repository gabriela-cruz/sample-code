
close all; clear all; clc;

homeFolder = '/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata';
allFolder  = dir('S*');
cd(homeFolder)


%% Events Matrix

% Column 1  = Event number
% Column 2  = EventCode  1       2     3      4      5        6        7      8      9      10    11      12      13
%                      {'TCBL','NCBL','TarC','NTaC','checks','clocks','TIBL','NIBL','TarI','NTaI', 'rest', 'D1', 'resp'};
% Column 3  = Latency
% Column 4  = Clock Block
% Column 5  = Clock Reset Category result
% Column 6  = divide clock block time in 4 time chuncks
% Column 7  = Trialnumber in clock
% Column 8  = Time between clock reset
% Column 9  = divide clock checks block time in 4 time chuncks
% Column 10 = trial number in clock check a
% Column 11 = time between clock checks


for subj = 19:length(allFolder);
    
    filename=allFolder(subj).name;
    cd(allFolder(subj).name)
    
    load('EventsInfoMatrix.mat')
    
    %% Histogram of Errors and clock checks for clock reset chunks
    % Error according clock result
    
    ClockTimes        =  find(EventsInfoMatrix(:,2)==6); % Clock time for clock reset
    LastLat           = ClockTimes(end);
    NbClockReset      = length(ClockTimes);
    ClockTime0        = find(ismember(EventsInfoMatrix(:,2),[3 4 9 10]),1); % clock time starts
    ClockResetTime    = [ClockTime0 ; ClockTimes];
    LatencyClockReset = EventsInfoMatrix(ClockResetTime,3);
    
    AccByClockResetChunks     = nan(NbClockReset,5); AccByClockResetChunks(:,5) = 1; % first column is category of the reponse
    NbTimeChecksPerClockReset = nan(NbClockReset,4);
    NumberErrorsClockReset    = nan(NbClockReset,5); NumberErrorsClockReset(:,5) = 1;
    
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
            % column 2 = 9 and 10 are errors in ongoing task
            TotalOngEvent               = length(find(ismember(EventsInfoMatrix(Idx,2),[3 4 9 10])));
            Incorrect                   = length(find(ismember(EventsInfoMatrix(Idx,2),[9 10])));
            AccByClockResetChunks(it,T) = Incorrect/TotalOngEvent*100;
            NumberErrorsClockReset(it,T)= Incorrect;
            % Number of time checks per quarter per performance category
            NbTimeChecksPerClockReset(it,T) = length(find(EventsInfoMatrix(Idx,2)==5));
        end
        if ~isempty(Idx)
        AccByClockResetChunks(it,5)  = EventsInfoMatrix(Idx(1),5);
        NumberErrorsClockReset(it,5) = EventsInfoMatrix(Idx(1),5);
        end
    end
    
    %% Save files and plot data
    % only plot from early to forgot
    CategoriesColor = {[1 1 0],[0.5 0.5 1],[0 0 1],[0 1 0],[1 0 0],[0 0 0]};
    %                 'yellow' 'light blue' 'blue' 'green'  'red'   'black'
    
    
    f1 = figure;
    h1 = bar3(AccByClockResetChunks(:,1:4)')
    for cc = 1:length(h1)
        C = CategoriesColor{AccByClockResetChunks(cc,5)};
        set(h1(cc),'facecolor',C);
    end
    title('Error rate per Clock reset block');
    
    f2 = figure;
    h2 = bar3(NbTimeChecksPerClockReset')
    for cc = 1:length(h2)
        C = CategoriesColor{AccByClockResetChunks(cc,5)};
        set(h2(cc),'facecolor',C);
    end
    title('Number of time checks during Clock reset block');
    
    f3 = figure;
    h3 = bar3(NumberErrorsClockReset(:,1:4)')
    for cc = 1:length(h3)
        C = CategoriesColor{NumberErrorsClockReset(cc,5)};
        set(h3(cc),'facecolor',C);
    end
    title('Number of errors during Clock reset block');
    
    
    print( f1, '-depsc2', [filename '_ErrorRateClockReset'])
    print( f2, '-depsc2', [filename '_TimeChecksperClockReset'])
    print( f3, '-depsc2', [filename '_NbErrorClockReset'])
    save('ErrorRateClockReset.mat','AccByClockResetChunks');
    save('TimeChecksClockReset.mat','NbTimeChecksPerClockReset');
    save('NumberErrorsClockReset.mat','NumberErrorsClockReset');
    
    %%
    
    %% Histogram of Errors for Time checks
    
    ClockTimes        = find(ismember(EventsInfoMatrix(:,2),[5 6])); % Clock time for checks and clock reset
    ClockTimes        = ClockTimes(ClockTimes<=LastLat);
    NbClockChecks     = length(ClockTimes);
    ClockResetTime    = [ClockTime0 ; ClockTimes ];
    LatencyClockReset = EventsInfoMatrix(ClockResetTime,3);
    
    AccByClockTimeCheck   = nan(NbClockChecks,5); AccByClockTimeCheck(:,5)=1; % first column is category of the reponse
    NumberErrorsTimeCheck = nan(NbClockChecks,5); NumberErrorsTimeCheck(:,5)=1;
    
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
            % column 2 = 9 and 10 are errors in ongoing task
            TotalOngEvent               = length(find(ismember(EventsInfoMatrix(Idx,2),[3 4 9 10])));
            Incorrect                   = length(find(ismember(EventsInfoMatrix(Idx,2),[9 10])));
            AccByClockTimeCheck(it,T)   = Incorrect/TotalOngEvent*100;
            NumberErrorsTimeCheck(it,T) = Incorrect;
        end
        if ~isempty(Idx)
            AccByClockTimeCheck(it,5)   = EventsInfoMatrix(Idx(1),5);
            NumberErrorsTimeCheck(it,5) = EventsInfoMatrix(Idx(1),5);
        end
    end
    
    %% Save files and plot data
    % only plot from early to forgot
    CategoriesColor = {[1 1 0],[0.5 0.5 1],[0 0 1],[0 1 0],[1 0 0],[0 0 0]};
    %                 'yellow' 'light blue' 'blue' 'green'  'red'   'black'
    
    
    f4 = figure;
    h4 = bar3(AccByClockTimeCheck(:,1:4)')
    for cc = 1:length(h4)
        C = CategoriesColor{AccByClockTimeCheck(cc,5)};
        set(h4(cc),'facecolor',C);
    end
    title('Error rate per Time check');
    
    f5 = figure;
    h5 = bar3(NumberErrorsTimeCheck(:,1:4)')
    for cc = 1:length(h5)
        C = CategoriesColor{NumberErrorsTimeCheck(cc,5)};
        set(h5(cc),'facecolor',C);
    end
    title('Number of errors before time checks');
    
    print( f4, '-depsc2', [filename '_ErrorRateTimeCheck'])
    save('ErrorRateTimeCheck.mat','AccByClockTimeCheck');
    
    print( f5, '-depsc2', [filename '_NbErrorTimeCheck'])
    save('NumberErrorsTimeCheck.mat','NumberErrorsTimeCheck');
    
    
    cd(homeFolder)
end





