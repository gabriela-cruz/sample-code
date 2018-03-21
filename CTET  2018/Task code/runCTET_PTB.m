%% CTET Experiment
% Task designed by O'Connell et al. See http://www.jneurosci.org/content/29/26/8604
% PTB version of the code by G.Cruz
%
% To run, call this function with the id code for your subject, eg:
% runCTET_PTB('gc1');
%

function runCTET_PTB(subID)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settingsCTET; % Load all the settings from the file

rand('state', sum(100*clock)); % Initialize the random number generator

% Keyboard setup
KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE')];

% Screen setup
clear screen
whichScreen = min(Screen('Screens')); % Set the screen number to the external secondary monitor if there is one connected
[window1, rect] = Screen('Openwindow',whichScreen,backgroundColor,[],[],2);
slack = Screen('GetFlipInterval', window1)/2;
W=rect(RectRight); % screen width
H=rect(RectBottom); % screen height
Screen(window1,'FillRect',backgroundColor);
Screen('Flip', window1);
black = BlackIndex(whichScreen);  % Get color index for writing text in black
% white = WhiteIndex(screenNumber);
% grey = white / 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up stimuli lists and results file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create random list with images
imageList = {'check1.bmp' 'check2.bmp' 'check3.bmp' 'check4.bmp'};

cNumb = nan(1,nTrials);
cNumb(1) = randi([1 4],1,1);
for i = 2:nTrials
    cNumb(i) = randsample(setdiff(1:4, cNumb(i-1)), 1);
end

stimList = cell(1,nTrials);
for i = 1:nTrials;
    stimList{i} = ['check' num2str(cNumb(i)) '.bmp'];
end

% Create vector with standard and target times
imageDuration = nan(1,nTrials);
betw = randi([7 15],1,1);
sincetarg = 1;
MWprobeTrial = nan(1,nTrials);

for i = 1:nTrials
    if betw == sincetarg;
        imageDuration(i) = targetDuration;
        sincetarg = 1;
        betw = randi([7 15],1,1);
        MWprobeTrial(i) = betw;
    else
        imageDuration(i) = standardDuration;
        sincetarg = sincetarg + 1;
    end
end

% One mind wandering probe per block will appear with at least 5 trials 
% of distance both directions. It can happen any time excluding the first
% ~30 seconds of the trial

MWprobeTrial = find(MWprobeTrial > 10);

save('stimDuration.mat','imageDuration');

endTrialTime = nan(1,length(nTrials));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Experiment instructions
DrawFormattedText(window1, 'Fixate in the middle of the flickering pattern \n\n  The pattern changes at regular intervals \n\n\n\n Click the mouse as soon as you notice that one pattern \n\n persists for longer than the regular interval \n\n\n\n Press any key to continue...',...
    'center', 'center', black);
Screen('Flip', window1);
KbStrokeWait;

% Load images into texture array
for i = 1:nTrials
    img = imread(stimList{i});
    imageDisplay(i) = Screen('MakeTexture', window1, img);
    
    % Calculate image position (center of the screen)
    imageSize = size(img);
    pos = [(W-imageSize(2))/2 (H-imageSize(1))/2 (W+imageSize(2))/2 (H+imageSize(1))/2];
end

% Screen priority
Priority(MaxPriority(window1));
Priority(2);

% Get stimulus presentation times
startTrialTime=nan(1,nTrials);

% Get response time
%respTime = [];
respTime=nan(1,nTrials);

% Show the image stream
flipTime = Screen('Flip', window1);
%timeInfo(1) = GetSecs; % time experiment beggins

% Run experimental trials
for i = 1:nTrials
    Screen(window1, 'FillRect', backgroundColor);
    Screen('DrawTexture', window1, imageDisplay(i), [], pos);

    [flipTime,StimulusOnsetTime] = Screen('Flip', window1);%,...
    
    startTrialTime(i) = StimulusOnsetTime;
        
    endTrialTime(i) = flipTime + imageDuration(i);
    
    disp(num2str(imageDuration(i)));
    
    clickdetected=0; %add some more checks to make
               %sure that RTs are measured correctly
    while GetSecs < endTrialTime(i)%        
     
        % Get Mouse response%
        if ~clickdetected;
            [~,~,buttons] = GetMouse; %
            if any(buttons)
                respTime(i) = GetSecs;
                clickdetected=1; %don't monitor mouse anymore if response given already
                disp('mouse clicked')      
            end
        end
        
        % Is this keyboard monitoring causing problems???
        % ESC key quits the experiment
        [keyIsDown,secs,keyCode] = KbCheck;
        % pressedKeys = find(keyCode);
               
        if keyCode(KbName('ESCAPE')) == 1 
           clear all
           close all
           sca
           return;
        end
        
    end
        Screen('Close',imageDisplay(i));  % Clear texture array
end
save('endTrialTimeInfo.mat','endTrialTime');
save('startTrialTimeInfo.mat','startTrialTime');
save('ResponseTimeInfo.mat','respTime');


% Save results to file
% resultMatrix = cell(nTrials,5);
% resultMatrix(:,1) = num2cell(1:nTrials)';
% EventType = cell(nTrials,1);
% EventType(imageDuration==standardDuration) = {'standard'};
% EventType(imageDuration==targetDuration) = {'target'};
% resultMatrix(:,2) = EventType;
% resultMatrix(:,3) = num2cell(startTrialTime);
% resultMatrix(:,4) = num2cell(endTrialTime-startTrialTime); % RequestedTrialDuration
% resultMatrix(:,5) = num2cell(diff([startTrialTime NaN]));
% 
% RespInfo = [(1:nTrials)' respTime'];
% RespInfo = RespInfo((~isnan(respTime)),:);
% RespInfo = [num2cell(RespInfo(:,1)) repmat({'resp'}, 1,size(RespInfo,1))' num2cell(RespInfo(:,2)) num2cell(nan(size(RespInfo,1),1)) num2cell(nan(size(RespInfo,1),1))];
% 
% resultMatrix = [resultMatrix ; RespInfo];
% 
% resultMatrix = sortrows(resultMatrix,[3,1]);
% 
% save(['Results_' subID '.mat'],'resultMatrix');
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RestrictKeysForKbCheck([]);
%fclose(outputfile);
Screen(window1,'Close');
close all
sca;

%%
%%% debug
%endTrialTime=respTime;
endTrialTime(isnan(endTrialTime))=startTrialTime(isnan(endTrialTime));
stimdur=diff([startTrialTime NaN]);
disp('Debug info')
disp('ROW1 = desired image duration (ms)')
disp('ROW2 = actual image duration')
disp('ROW3 = stim onset relative to previous stim')
disp('ROW4 = requested image duration')
disp(num2str([imageDuration*1000;... %desired image duration
    stimdur*1000; %actual stimulus duration
    [0 diff([startTrialTime])]*1000;... %stimulus onset time relative to previous
    ([endTrialTime-startTrialTime])*1000],'%0.0f ')) %requested image duration
disp('note that actual > desired image duration by a couple ms')
%%% debug
%%

return

end
