
% This function loads the log file from neurobs Presentation and creates:
% A Response Matrix with trial information per participant
% COLUMN 1 = Block number (from 1 to 10)
% COLUMN 2 = Response Type, 0 = missed, 1 = correct, 2 = false positive
% COLUMN 3 = RT (only for correct answers)

% Summary Table (6 columns)
% Total number of trials | correct | missed | false positive | RT | std

% It saves data as matlab structure and txt

% Reaction time - measured relative to the point in which target frames become
% distinguishable, that is 800 ms post-stimulus onset.
% Correct response - only if it occurs within two non-target frames (1600 ms)

function CTETbehav(SubID, BlockNum)

RespMatrix = [];

for Bnum = 1:length(BlockNum)
    
    FilePath = '/Volumes/Data HD/experiments/NF/CTET/EEGdata/healthy/';
    %FilePath = '/Volumes/Data HD/experiments/NF/CTET/EEGdata/ABI/';
    
    cd(FilePath);
    %% Load log File
    
    [LogData,Logtxt,Lograw] = xlsread([FilePath SubID '/trigs_Blck' num2str(BlockNum(Bnum)) '.xlsx']); %sk-wedges.xlsx
    LogData = LogData(isfinite(LogData(:,1)),:);% eliminate Nan
    LogData = LogData(isfinite(LogData(:,4)),:);% eliminate warning of not sent triggers (column 4)
    LogData = LogData(:,[3 4]);% Keep event code and Time
    LogData(:,2) = round(LogData(:,2)/10);
    
    %%
    % total number of trials presented
    Targets = find(LogData(:,1)>=1120);
    TotalTrials = length(Targets);
    Resp = find(LogData(:,1)==4);
    CorrectResp = zeros(length(Resp(2:end)),1);
    RTs = nan(length(Resp(2:end)),1);
    TargetsLatency = LogData(Targets,2);
    RespLatency = LogData(Resp(2:end),2);
    
    % find whether there is a response within the following two non-targets
    % frames
    
    RespLatencyInterval = TargetsLatency + 800;
    RespLatencyInterval(:,2) = TargetsLatency + LogData(Targets(1),1) + 1600;
    
    for i = 1 : length(RespLatency)
        tmpResp = RespLatencyInterval(RespLatency(i) >= RespLatencyInterval(:,1) & RespLatency(i) <= RespLatencyInterval(:,2));
        
        if isempty(tmpResp)
            CorrectResp(i) = 2; %false alarm
        else
            CorrectResp(i) = 1; % Correct
            RTs(i) = RespLatency(i) - tmpResp ;
        end
    end
    
    %% Create Response matrix
    
    tmpRespMatrix = [ones(length(CorrectResp),1)*BlockNum(Bnum) CorrectResp RTs];
    MissedTrials = TotalTrials - sum(CorrectResp == 1);
    if MissedTrials > 0;
        tmpRespMatrix = [tmpRespMatrix ; [ones(MissedTrials,1)*BlockNum(Bnum) zeros(MissedTrials,1)...
            nan(MissedTrials,1)]];
    end
        
end

% ==========================================
% Save Matlab structure with Behaviour info 
% ==========================================
RespMatrixHeader = {'Block Num' 'Response type' 'RT'};
SummaryTableHeader = {'Total Trials' 'Correct' 'Missed' 'False positive' 'RT' 'std'};

SummaryTable = nan(1,6);
SummaryTable(1) = sum(RespMatrix(:,2) == 1 | RespMatrix(:,2) == 0); % Total trials
SummaryTable(2) = sum(RespMatrix(:,2) == 1); % Correct
SummaryTable(3) = sum(RespMatrix(:,2) == 0); % Missed
SummaryTable(4) = sum(RespMatrix(:,2) == 2); % False positive
SummaryTable(5) = nanmean(RespMatrix(:,3));  % RT
SummaryTable(6) = nanstd(RespMatrix(:,3));   % std

Behaviour.SubID = SubID;
Behaviour.TrialsHeadings = RespMatrixHeader;
Behaviour.Trials = RespMatrix;
Behaviour.SummaryTable = SummaryTable;
Behaviour.SummaryTableHeading = SummaryTableHeader;

save([FilePath SubID '/' SubID '_Behaviour'], 'Behaviour');
        
% ==========================================
% Save to txt file
% ==========================================

% Save Response Matrix to txt file
fid = fopen( [FilePath SubID '/' SubID '_BehavResults.txt'], 'wt' );
fprintf(fid, '%s\t %s\t %s\t \n', RespMatrixHeader{:});

for i = 1:length(RespMatrix)
    fprintf(fid, '%.0f\t  %.0f\t %.0f\t \n', RespMatrix(i,1) , RespMatrix(i,2) , RespMatrix(i,3));
end
fclose(fid);

% Save summary table to txt file
fid = fopen( [FilePath SubID '/' SubID '_BehavResultsSummary.txt'], 'wt' );
fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t \n', SummaryTableHeader{:});

fprintf(fid, '%.0f\t  %.0f\t %.0f\t %.0f\t %.3f\t %.3f\t \n', SummaryTable);

fclose(fid);

end



