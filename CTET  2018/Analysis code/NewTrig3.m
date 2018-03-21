
% This function:
%
% Checks the delay of the triggers sent by neurobs Presentation
% (between 20 and 30 ms in average)
%
% It also checks whether there are missing triggers from the DAQ or the USB amplifier
% If it is so, it finds and adds the missing triggers if the info is available
%
% It creates a new EEGfile with a new trigger channel (channel 20)
% It also creates a new txt file with trigger info to load events in eeglab

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE!!!
% Triggers are sent in two ways:
%   1 = neurobs presentation send triggers to the USB amplifier
%   2 = neurobs Presentation send triggers to a data acquisiton card (DAQ)
%   The DAQ detects triggers 20 to 30 milliseconds before in average but
%   sometimes misses some triggers
%
% The trigger numbers used for this task are
% 1 = Stimuli
% 4 = Response
% 3 = MW probe
% 11, 12 or 13 = MW probe answer
%
% Value 5 appears when stimuli (1) and response (4) overlap
% If 5 followed 4, 5 becomes 1: A response was closely followed by a stimulus
% If 5 followed 1, 5 becomes 4: A stimulus was closely followed by a response
% See line 64
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NewTrig2(SubID, BlockNum)

Delay = nan(5,length(BlockNum)); % mean, std, min, max, nº of outliers
EEGdata = [];
EventType = [];

for Bnum = 1:length(BlockNum)
    
    FilePath = '/Volumes/Data HD/experiments/NF/CTET/EEGdata/healthy/';
    %FilePath = '/Volumes/Data HD/experiments/NF/CTET/EEGdata/ABI/';
    load([ FilePath 'S' SubID '/Blck' num2str(BlockNum(Bnum))]);
    
    Time =  TrigEEG_19Chs(1,:);
    BinNum = flipud(TrigEEG_19Chs(2:5,:));
    IntNum = bi2de(BinNum');
    DirectTrig = IntNum';
    USBampTrig = TrigEEG_19Chs(22,:);% USBamp trig channel is saved after channels from device 1 and before channels from device 2
    
    %% Direct triggers
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Creat matrix to complete info from Direct (DAQ) triggers
    DTPulses = nan(9,length(DirectTrig));
    % 1: Pulse number
    % 2: pulse length
    % 3-4: pulse starts and ends in secs
    % 5-6: pulse starts and ends in time points,
    % 7-8: pulse starts and ends in ms
    % 9: Pulse ID
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Replace number 5 by correct number
    Find5 = find(DirectTrig==5);
    DirectTrigCode = DirectTrig;
    for ii = 1:length(Find5);
        if DirectTrigCode(Find5(ii)-1) == 1;
            DirectTrig(Find5(ii)) = 4;
        elseif DirectTrigCode(Find5(ii)-1) == 4;
            DirectTrig(Find5(ii)) = 1;
        elseif DirectTrigCode(Find5(ii)-1) == 0;
            FindFirstOccurrence = cell2mat(arrayfun(@(x) find(DirectTrig(Find5(ii):end)==x,1),[1 4],'un',0))'; % First Occurrence of 4 and 1, after the 5
            [~,idx] = min(FindFirstOccurrence);
            if idx == 1; % the first occurrence after number 5 is number 1
                DirectTrig(Find5(ii)) = 4;
                DirectTrigCode(Find5(ii)) = 4;
            elseif idx == 2; % the first occurrence after number 5 is number 4
                DirectTrig(Find5(ii)) = 1;
                DirectTrigCode(Find5(ii)) = 1;
            end
        else
            DirectTrig(Find5(ii)) = DirectTrig(Find5(ii)-1);
        end
    end
    DirectTrigCode = DirectTrig;
    
    % Complete DAQ triggers matrix
    count=1;
    pulseNumb = 0;
    for i = 2:length(DirectTrig);
        if DirectTrigCode(i) >= 1 && DirectTrigCode(i-1)==DirectTrigCode(i); % count time points
            count=count+1;
            DirectTrig(i)= count;
        elseif DirectTrigCode(i) == 0 && DirectTrigCode(i-1)>=1 ||...
                DirectTrigCode(i) >=1 && DirectTrigCode(i-1)>=1 &&...
                DirectTrigCode(i-1) ~= DirectTrigCode(i); % when pulse finishes
            pulseNumb = pulseNumb+1;
            pulseLength = 3.9*(count+1);
            DTPulses(1,i) = pulseNumb;
            DTPulses(2,i) = pulseLength; % in ms
            DTPulses(3,i) = Time(i-count-1);% pulse starts in s
            DTPulses(4,i) = Time(i-1); % pulse finishes in s
            DTPulses(5,i) = i-count-1; % pulse starts in time points
            DTPulses(6,i) = i-1; % pulse finishes in time points
            DTPulses(7,i) = (i-count-1)*3.9; % pulse starts in ms
            DTPulses(8,i) = (i-1)*3.9; % pulse finishes in ms
            DTPulses(9,i) = DirectTrigCode(i-1);
            count=1;
        end
        
    end
    
    
    DTPulses = DTPulses(:,isfinite(DTPulses(1,:)));% eliminate Nan
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Warning if codes other than the possible ones are detected!!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DetectedCodes = unique(DTPulses(9,:));
    PossibleCodes = [1 4  3 11 12 13];
    if any(~ismember(DetectedCodes,PossibleCodes));
        disp('Warning!!!!!');
        disp('Warning!!!!!');
        disp('Some unusual events were detected');
        
    end
    
    
    %% USBamp triggers
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Creat matrix to complete info from USBamp (USB amplifier) triggers
    UAPulses = nan(9,length(USBampTrig));
    % see line 58 to 63 for explanation
    
    % Replace number 5 by correct number
    Find5 = find(USBampTrig==5);
    USBampTrigCode = USBampTrig;
    for ii = 1:length(Find5);
        if USBampTrigCode(Find5(ii)-1) == 1;
            USBampTrig(Find5(ii)) = 4;
        elseif USBampTrigCode(Find5(ii)-1) == 4;
            USBampTrig(Find5(ii)) = 1;
        else
            USBampTrig(Find5(ii)) = USBampTrig(Find5(ii)-1);
        end
    end
    USBampTrigCode = USBampTrig;
    
    % Complete USBamp triggers matrix
    count=1;
    pulseNumb = 0;
    for i = 2:length(USBampTrig);
        if USBampTrigCode(i) >= 1 && USBampTrigCode(i-1)==USBampTrigCode(i); % count time points
            count=count+1;
            USBampTrig(i)= count;
        elseif USBampTrigCode(i) == 0 && USBampTrigCode(i-1)>=1 ||...
                USBampTrigCode(i) >=1 && USBampTrigCode(i-1)>=1 &&...
                USBampTrigCode(i-1) ~= USBampTrigCode(i); % when pulse finishes
            pulseNumb = pulseNumb+1;
            pulseLength = 3.9*(count+1);
            UAPulses(1,i) = pulseNumb;
            UAPulses(2,i) = pulseLength; % in ms
            UAPulses(3,i) = Time(i-count-1);% pulse starts in s
            UAPulses(4,i) = Time(i-1); % pulse finishes in s
            UAPulses(5,i) = i-count-1; % pulse starts in time points
            UAPulses(6,i) = i-1; % pulse finishes in time points
            UAPulses(7,i) = (i-count-1)*3.9; % pulse starts in ms
            UAPulses(8,i) = (i-1)*3.9; % pulse finishes in ms
            UAPulses(9,i) = USBampTrigCode(i-1);
            count=1;
        end
        
    end
    UAPulses = UAPulses(:,isfinite(UAPulses(1,:)));% eliminate Nan
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Warning if codes other than the possible ones are detected!!!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DetectedCodes = unique(UAPulses(9,:));
    PossibleCodes = [1 4  3 11 12 13];
    if any(~ismember(DetectedCodes,PossibleCodes));
        disp('Warning!!!!!');
        disp('Warning!!!!!');
        disp('Some unusual events were detected');
        
    end
    
    %% Find missing triggers and calculate average delay between USBamplifier and Data acquisition Card
    
    if ~isempty(UAPulses) || ~isempty(DTPulses);
        
        A = DTPulses(5,:);
        B = UAPulses(5,:);
        
        % Find missing triggers by comparing latency of all events
        if length(UAPulses) ~= length(DTPulses);
            TMP = bsxfun(@(x,y) abs(x-y), A(:), reshape(B,1,[]));
            [D, idxB] = min(TMP,[],2);
            shortB = B(idxB);
            MissingTriggers = ~ismember(1:length(UAPulses(5,:)),idxB);
            
            X = unique(idxB); Ncount = histc(idxB, X);
            if ~isempty(find(Ncount>1))
                X = find(MissingTriggers);
                Y = idxB(find(Ncount>1));
                
                FindRep = bsxfun(@(x,y) abs(x-y), X(:), reshape(Y,1,[]));
                [DFR, idxFR] = min(FindRep,[],1);
                MissingTriggers(X(idxFR)) = 0;
            end
            
        else
            shortB = B;
            D = A-B;
            
        end
        
        % Calculate delay between USBamp and DAQ
        figure;hb = boxplot(A-shortB);title(['S' SubID]);
        hOutliers = findobj(hb,'Tag','Outliers');
        yy = abs(get(hOutliers,'YData'));
        
        IdxOut = find(ismember(D, yy)); IdxIn = ~ismember(1:length(A),IdxOut);
        
        % store data
        Delay(1,Bnum) = mean(A(IdxIn)-shortB(IdxIn))*3.9;
        Delay(2,Bnum) = std(A(IdxIn)-shortB(IdxIn))*3.9;
        Delay(3,Bnum) = min(abs(D(IdxIn)));
        Delay(4,Bnum) = max(abs(D(IdxIn)));
        Delay(5,Bnum) = length(yy);
        
    end
    
    
    
    %% Create trigger channel
    
    
    % =========================================
    % Create matrix with triggers from log file
    % =========================================
    % save the log file as  Trigs_Blck(block number).xlsx, e.g. Trigs_Blck1.xlsx
    
    [LogData,Logtxt,Lograw] = xlsread([FilePath 'S' SubID '/trigs_Blck' num2str(BlockNum(Bnum)) '.xlsx']); %sk-wedges.xlsx
    LogData = LogData(isfinite(LogData(:,1)),:);% eliminate Nan
    LogData = LogData(isfinite(LogData(:,4)),:);% eliminate warning of not sent triggers (column 4)
    LogData = LogData(:,[3 4]);% Keep event code and Time
    LogData(:,2) = round(LogData(:,2)/10);
    
    %% Double check that all triggers have been received. Add missing triggers if not
    
    if isempty(UAPulses) || isempty(DTPulses);
        
        disp(['Block number: ' num2str(BlockNum(Bnum))] );
        disp('Bad News!!!');
        disp('The pulses were not detected');
        AllGood = 0;
        
    elseif length(UAPulses) ~= length(DTPulses);
        
        Pdiff = length(UAPulses) - length(DTPulses);
        
        disp(['Block number: ' num2str(BlockNum(Bnum))] );
        disp('For some reason there are different number of triggers');
        
        if Pdiff > 0;
            disp(['USBamp detected ' num2str(abs(Pdiff)) ' more event(s)'] );
            USBampPulseResponse = find(UAPulses(9,:)'==4);
            DTPulseResponse = find(DTPulses(9,:)'==4);
            
            if length(USBampPulseResponse) == length(DTPulseResponse) &&...
                    USBampPulseResponse(1) - DTPulseResponse(1)==1;
                disp('However all critical responses have been detected');
                disp('The first pulse was not detected by the DAQ');
                DTPulses = [UAPulses(:,1) DTPulses];
                disp('The issue has been corrected!');
                AllGood = 1;
                
            elseif length(USBampPulseResponse) == length(DTPulseResponse) &&...
                    USBampPulseResponse(1) - DTPulseResponse(1)~=1;
                disp('All critical responses have been detected');
                disp('Completing event matrix with missing triggers');
                
                DTPulses = [DTPulses UAPulses(:,MissingTriggers)];
                DTPulses = sortrows(DTPulses',5)';
                DTPulses(1,:) = 1:length(DTPulses);
                
                AllGood = 1;
                
            elseif length(USBampPulseResponse) ~= length(DTPulseResponse);
                
                diffResp = length(USBampPulseResponse) - length(DTPulseResponse);
                
                if diffResp > 0;
                    disp(['USBamp detected ' num2str(abs(diffResp)) ' more response(s)'] );
                    disp('Completing event matrix with missing triggers');
                    
                    DTPulses = [DTPulses UAPulses(:,MissingTriggers)];
                    DTPulses = sortrows(DTPulses',5)';
                    DTPulses(1,:) = 1:length(DTPulses);
                    
                    AllGood = 1;
                    
                end
                
            end
            
            % Double check that total number of events is alright
            if find(UAPulses(9,:)'==4) == find(DTPulses(9,:)'==4);
                disp('Good! you have not added extra responses');
            end
            
            if find(UAPulses(9,:)'==1) == find(DTPulses(9,:)'==1);
                disp('Good! you have not added extra stimulus event');
            end
            
            
        else
            disp(['USBamp missed ' num2str(abs(Pdiff)) ' event(s)'] );
            
            if length(DTPulses) == length(LogData);
                disp('But, Good news! The Data acquisiton Card detected all the pulses!');
                
                AllGood = 1;
                % =============================================
                % Check all codes received
                % =============================================
                if isempty(find(find(LogData==4) - find(DTPulses(9,:)'==4)));
                    disp('Things are looking good so far!');
                elseif ~isempty(find(find(LogData==4) - find(DTPulses(9,:)'==4)));
                    LogDataNewCode = nan(length(LogData),1);
                    LogDataNewCode(LogData(:,1)==800) = 1;
                    LogDataNewCode(LogData(:,1)>=1120) = 1;
                    LogDataNewCode(LogData(:,1)==4) = 4;
                    LogDataNewCode(LogData(:,1)==55) = 3;
                    LogDataNewCode(LogData(:,1)==11) = 11;
                    LogDataNewCode(LogData(:,1)==12) = 12;
                    LogDataNewCode(LogData(:,1)==13) = 13;
                    CodeDiff = find(LogDataNewCode(2:end)' - UAPulses(9,2:end));
                    if diff(CodeDiff)==1;
                        disp('Two trial codes are swapped');
                        disp('You may want to check the time difference between them!!!');
                        disp('The overall number of triggers is correct');
                    end
                end
            else
                disp('You may want to check triggers manually');
                
                DTPulseResponse = find(DTPulses(9,:)'==4);
                Diff = length(LogData) - length(DTPulses);
                
                IdxMissTrig = DTPulseResponse(find(find(LogData==4) - DTPulseResponse,1));
                
                AllDiff = diff(DTPulses(7,:));
                BigDiff = find(AllDiff>1600);
                
                [~,BigDiffIdx] = min(abs(BigDiff-IdxMissTrig));
                
                LogData(BigDiff(BigDiffIdx),:)=[];
                
                disp(['The new trigger channel will be created with ' num2str(Diff) ' less event(s)']);
                
                
                AllGood = 1;
            end
        end
        
    elseif length(UAPulses) == length(DTPulses);
        AllGood = 1;
        % =============================================
        % Check all codes received
        % =============================================
        if isempty(find(UAPulses(9,:) - DTPulses(9,:)));
            disp(['Everything goes great with Block ' num2str(BlockNum(Bnum)) '!!!']);
            disp('No Issues so far!!!');
            
        elseif isempty(find(LogData==4) - find(DTPulses(9,:)'==4));
            disp('Well done!!!');
            disp('Things are really looking good so far!');
        elseif ~isempty(find(LogData==4) - find(UAPulses(9,:)'==4));
            LogDataNewCode = nan(length(LogData),1);
            LogDataNewCode(LogData(:,1)==800) = 1;
            LogDataNewCode(LogData(:,1)>=1120) = 1;
            LogDataNewCode(LogData(:,1)==4) = 4;
            LogDataNewCode(LogData(:,1)==55) = 3;
            LogDataNewCode(LogData(:,1)==11) = 11;
            LogDataNewCode(LogData(:,1)==12) = 12;
            LogDataNewCode(LogData(:,1)==13) = 13;
            CodeDiff = find(LogDataNewCode(2:end)' - UAPulses(9,2:end));
            if diff(CodeDiff)==1;
                disp('Two trial codes are swapped');
                disp('You may want to check the time difference between them!!!');
                disp('The overall number of triggers is correct');
            end
            
        end
        
        
        
    end
    %% Find Correct, missing and false postive responses
    
    Targets = find(LogData(:,1)>=1120);
    TotalTrials = length(Targets);
    Resp = find(LogData(:,1)==4);
    CorrectResp = zeros(length(Resp(2:end)),2);
    RTs = nan(length(Resp(2:end)),1);
    TargetsLatency = LogData(Targets,2);
    RespLatency = LogData(Resp(2:end),2);
    TrialDur = unique(LogData(LogData(:,1)>=1120,1));
    
    % find whether there is a response within the following two non-targets
    % frames
    
    RespLatencyInterval = TargetsLatency + 800;
    RespLatencyInterval(:,2) = TargetsLatency + LogData(Targets(1),1) + 1600;
    
    for ii = 1 : length(RespLatency)
        tmpResp = RespLatencyInterval(RespLatency(ii) >= RespLatencyInterval(:,1) & RespLatency(ii) <= RespLatencyInterval(:,2));
        if isempty(tmpResp)
            [val idx] = min(abs(LogData(:,2) - RespLatency(ii)));
            LogData(idx-1,1) = 1101; % false alarm
        else
            [val idx] = min(abs(TargetsLatency - RespLatency(ii)));
            LogData(LogData(:,2)==TargetsLatency(idx),1) = 1111; % correct
        end
    end
    
        
    %%
    
    if AllGood == 1;
        disp('The new trigger channel is being created');
        
        
        % =============================================
        % Create EEGdata matrix plus trigger channel
        % =============================================
        Triggers = DTPulses(9,:)';
        Triggers(:,2) = DTPulses(5,:);
        
        tmpEEGdata = TrigEEG_19Chs([6:21 23:25],:);
        tmpEEGdata(20,Triggers(:,2)') = Triggers(:,1)';
        tmpEEGdata(21,Triggers(:,2)') = BlockNum(Bnum);
        EEGdata = [EEGdata tmpEEGdata];
        % CHECK WHEN STIMULI START IN TIME POINTS!!!!!!!!!!!!!!!!!!!
        % save([FilePath 'S' SubID '/S' SubID '_EEGdataB' num2str(BlockNum(Bnum))], 'EEGdata');
        
        % ==========================================
        % Create matlab array with event description
        % ==========================================
        
        tmpEventType = cell(length(LogData),1);
        tmpEventType(LogData(:,1)==800) = {'standard'};
        tmpEventType(LogData(:,1)==TrialDur) = {'MissedTarget'};
        tmpEventType(LogData(:,1)==1111) = {'CorrectTarget'};
        tmpEventType(LogData(:,1)==1101) = {'FalseAlarm'};
        tmpEventType(LogData(:,1)==4) = {'resp'};
        tmpEventType(LogData(:,1)==55) = {'MWprobe'};
        tmpEventType(LogData(:,1)==11) = {'1'};
        tmpEventType(LogData(:,1)==12) = {'2'};
        tmpEventType(LogData(:,1)==13) = {'3'};
        tmpEventType(1) = {'start'};
        
        EventType = [EventType ; tmpEventType];
        
        disp(['All good with Block ' num2str(BlockNum(Bnum)) '!!!']);
        disp(' ');
        disp('========================================================= ');
    else
        
        disp(['Sorry!!!! the EEG file will not contain block ' num2str(BlockNum(Bnum))]);
        disp(' ');
        disp('========================================================= ');
        
    end
    
    
    
    
end

% ==========================================
% Save Event info to matlab file
% ==========================================disp('Saving new EEG data matrix...');
save([FilePath 'S' SubID '/S' SubID '_DelayInfo' ], 'Delay');
save([FilePath 'S' SubID '/S' SubID '_EEGdata'], 'EEGdata');
BlckID = EEGdata(21,EEGdata(21,:)>0);

% ==========================================
% Save Event info to txt file
% ==========================================
disp('Saving events info to txt file...');
header = {'latency' , 'type' , 'block'};
fid = fopen( [FilePath 'S' SubID '/S' SubID '_Triggers.txt'], 'wt' );
fprintf(fid, '%s\t %s\t %s\t \n', header{:});
[~,TriggersLatency] = find(EEGdata(21,:)>0);

for i = 1:length(EventType)
    fprintf(fid, '%f\t  %s\t %.0f\t \n', TriggersLatency(i) , EventType{i} , BlckID(i));
end
fclose(fid);

disp('All done!');
disp('========================================================= ');
end


