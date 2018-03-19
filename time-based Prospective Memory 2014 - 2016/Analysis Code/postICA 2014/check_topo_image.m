
close all; clear all; clc;

%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
homeFolder = '/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData';
cd(homeFolder)

allFolder = dir('S*');


for subj = 1:length(allFolder);
    subid = num2str(subj);
    if length(subid)==1
        subid = ['0',subid];
    end
    
    filename=allFolder(subj).name;
    cd(allFolder(subj).name)
    
    tmpName = dir('*_epoch.set');
    
    EEG = pop_loadset('filename', tmpName.name, 'filepath', pwd);
    
    
    
    % plot scalpmap
    %pop_topoplot(EEG,0, [1:35] ,LoadName, [6 6] ,0,'electrodes','off');
    pop_topoplot(EEG,0, [1:35] ,tmpName.name, [6 6] ,0,'electrodes','off');

    
    
    % save figure
    % MAKE SURE YOU CREATED THE FOLDER check_topoplot IN YOUR FOLDER HA_SC    
    plotname=strcat('/Users/gabycruz/experiments/EEG_timebased_PM/Figures_TBPM/Alltopoplots/S',subid);
    print('-depsc2 ',plotname)
  
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
