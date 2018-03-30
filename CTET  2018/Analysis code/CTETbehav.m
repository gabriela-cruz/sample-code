
% This function creates:
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
    
    %FilePath = '/Volumes/Data HD/experiments/NF/CTET/EEGdata/control/';
    FilePath = '/Volumes/Data HD/experiments/NF/CTET/EEGdata/ABI/';
    
    cd(FilePath);
    %% Load log File
    
    %LogData = xlsread('sk-wedges.xlsx');
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
    CorrectResp = zeros(length(Resp(2:end)),2);
    RTs = nan(length(Resp(2:end)),1);
    TargetsLatency = LogData(Targets,2);
    RespLatency = LogData(Resp(2:end),2);
   
    % find whether there is a response within the following two non-targets
    % frames
    
    
    RespLatencyInterval = TargetsLatency + 800;
    RespLatencyInterval(:,2) = TargetsLatency + LogData(Targets(1),1) + 1600;
    % i = 9
    for i = 1 : length(RespLatency)
        tmpResp = RespLatencyInterval(RespLatency(i) >= RespLatencyInterval(:,1) & RespLatency(i) <= RespLatencyInterval(:,2));
        
        if isempty(tmpResp)
            CorrectResp(i,1) = 2; %false alarm
            CorrectResp(i,2) = RespLatency(i);
            
        else
            CorrectResp(i,1) = 1; % Correct
            RTs(i) = RespLatency(i) - tmpResp ;
            %CorrectTargetLatency(i,1) = RespLatencyInterval(i,1);
            CorrectResp(i,2) = tmpResp-800;        
        end
    end
    
    %% Find missing trials
    
    MissingTrialsIdx = ~ismember(TargetsLatency,CorrectResp((CorrectResp(:,1)==1),2));
    MissingTrials = [zeros(sum(MissingTrialsIdx),1)  TargetsLatency(MissingTrialsIdx)];
    
    %% Create Response matrix
    
    tmpRespMatrix = [CorrectResp RTs ; MissingTrials nan(length(MissingTrials),1)];
    tmpRespMatrix = sortrows(tmpRespMatrix,2);
    tmpRespMatrix = [ones(length(tmpRespMatrix),1)*BlockNum(Bnum) tmpRespMatrix(:,[1 3])]; 
    
    RespMatrix = [RespMatrix ; tmpRespMatrix];
    
end

%%
% ==========================================
% Save Matlab structure with Behaviour info 
% ==========================================

% Add consecutive response number
RespMatrix = [(1:1:length(RespMatrix))' RespMatrix];

% Save info

RespMatrixHeader = {'RespNum' 'Block Num' 'Response type' 'RT'};
SummaryTableHeader = {'Total Trials' 'Correct' 'Missed' 'False positive' 'RT' 'std'};

SummaryTable = nan(1,6);
SummaryTable(1) = sum(RespMatrix(:,3) == 1 | RespMatrix(:,3) == 0); % Total trials
SummaryTable(2) = sum(RespMatrix(:,3) == 1); % Correct
SummaryTable(3) = sum(RespMatrix(:,3) == 0); % Missed
SummaryTable(4) = sum(RespMatrix(:,3) == 2); % False positive
SummaryTable(5) = nanmean(RespMatrix(:,4));  % RT
SummaryTable(6) = nanstd(RespMatrix(:,4));   % std

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
fprintf(fid, '%s\t %s\t %s\t %s\t \n', RespMatrixHeader{:});

for i = 1:length(RespMatrix)
    fprintf(fid, '%.0f\t %.0f\t  %.0f\t %.0f\t \n', RespMatrix(i,1) , RespMatrix(i,2) , RespMatrix(i,3) , RespMatrix(i,4));
end
fclose(fid);

% Save summary table to txt file
fid = fopen( [FilePath SubID '/' SubID '_BehavResultsSummary.txt'], 'wt' );
fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t \n', SummaryTableHeader{:});

fprintf(fid, '%.0f\t  %.0f\t %.0f\t %.0f\t %.3f\t %.3f\t \n', SummaryTable);

fclose(fid);

end



