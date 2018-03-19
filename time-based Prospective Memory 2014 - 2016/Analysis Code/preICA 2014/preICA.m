homefolder = '/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata'

allFolder = dir('S*');

for subj = 1:length(allFolder)
    tmpfolder = allFolder(subj).name;
    cd(tmpfolder)
    
    %loadName = dir('*.raw');
    loadName = dir('*.set');
    
    %export raw file to eeglab
    EEG = pop_readegi(loadName.name, [],[],'auto');
    
    
    %% Filter, Bad Channel rejection & autoClean
    
    % high-pass filter at 1Hz, filter order 826, transition band width 1Hz
    %EEG = pop_eegfiltnew(EEG, [], 1, 826, true, [], 1);
    EEG = pop_firws(EEG, 'fcutoff', 0.5, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', 826);
    EEG = eeg_checkset( EEG );
    
    % low-pass filter at 40Hz
    EEG = pop_eegfiltnew(EEG, [], 40, 84, 0, [], 0);
    %EEG = pop_firws(EEG, 'fcutoff', 45, 'ftype', 'lowpass', 'wtype', 'hamming', 'forder', 84);
    EEG = eeg_checkset( EEG );
    
    %% chan rej
    EEG = pop_rejchan(EEG, 'elec',[1:EEG.nbchan] ,'threshold',5,'norm','on','measure','kurt');
    
    %% select events & epoch data
    
    EEG = pop_selectevent( EEG, 'type',{'LonC' 'LonI' 'NewC' 'NewI' 'ShoC' 'ShoI' 'resp'},'deleteevents','on');
    EEG = pop_epoch( EEG, {  'LonC' 'LonI' 'NewC' 'NewI' 'ShoC' 'ShoI'  }, [-0.3         1.2], 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-300    0]);
    
    %% epoch rejection
    EEG = pop_jointprob(EEG,1,[1:EEG.nbchan] ,5,5,0,1);
    EEG = pop_eegthresh(EEG,1,[1:EEG.nbchan] ,-300,300,-0.3,1.196,2,1);
      
    
    %% save & visual inspection
    pwd
    newfilename = [loadName.name(1:8) '_autocleaned.set' ];  
    
    EEG = pop_saveset( EEG, 'filename',newfilename,'filepath',pwd);
    
    cd(homefolder)
end