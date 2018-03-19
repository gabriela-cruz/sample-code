
close all; clear all; clc;

%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
homeFolder = '/Users/gabycruz/experiments/EEG_eventbased_PM/Study2_AMICA_reviewClusters';
cd(homeFolder)

allFolder = dir('S*');


for subj = [1:12 14:26];
    subid = num2str(subj);
    if length(subid)==1
        subid = ['0',subid];
    end
    
    moveSubFolder = allFolder(subj).name;
    cd(moveSubFolder)
    loadName = dir('*.set');
    
    for session = 1:length(loadName);
        % Load dataset
        tmpLoadName = loadName(session).name;
        EEG = pop_loadset('filename', tmpLoadName, 'filepath', pwd);
        
        % plot scalpmap
        %pop_topoplot(EEG,0, [1:35] ,LoadName, [6 6] ,0,'electrodes','off');
        pop_topoplot(EEG,0, [1:35] ,tmpLoadName, [6 6] ,0,'electrodes','off');
        
        
        
        % save figure
        % MAKE SURE YOU CREATED THE FOLDER check_topoplot IN YOUR FOLDER HA_SC
        mkdir(strcat('/Users/gabycruz/experiments/EEG_eventbased_PM/Study2_AMICA_reviewClusters/Data2PlotchannelERPs/S',subid))
        plotname=strcat('/Users/gabycruz/experiments/EEG_eventbased_PM/Study2_AMICA_reviewClusters/Data2PlotchannelERPs/S',subid,'/S',subid,'_',num2str(session));
        print('-depsc2 ',plotname)
        
        close all
        
        
    end
    
    cd(homeFolder)
          
    
end



%%
% S01 = regular, ~3 brain ICs
% S02 = regular, ~3 brain ICs
% S03 = check data
% S04 = check data
% S05 = check data
% S06 = check data
% S07 = check data, noisy, 1 brain ICs
% S08 = regular, ~8 brain ICs
% S09 = regular, ~10 brain ICs
% S10 = regular, ~9 brain ICs
% S11 = regular, ~6 brain ICs
% S12 = regular, ~4 brain ICs
% S13 = strong frontal component, eye
% S14 = regular, ~10 brain ICs
% S15 = regular ok, ~10 brain ICs
% S16 = bad,
% S17 = bad,
% S18 = regular bad, ~4 brain ICs
% S19 = regularbad , ~3 brain ICs, check data
% S20 = ok, ~5 brain ICs
% S21 = regular, ~5 brain ICs
% S22 = regular, ~7 brain ICs
% S23 = regular, ~3 brain ICs
% S24 = ok, ~10 brain ICs
