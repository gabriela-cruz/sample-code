close all; clear all; clc;

homeFolder = '/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata';
cd(homeFolder)

allFolder = dir('S*');

%% Bad channels - Manual inspection (more channels were preiously rejected by prob and clean_art
  
        badchan.S{1}={'E1' 'E8' 'E9' 'E14' 'E15' 'E17' 'E18' 'E19' 'E22' 'E26' 'E56' 'E69' 'E82' 'E89' 'E114' 'E124' 'E125' 'E126'}; % check E23,24,25 > seem to have high frequency
        badchan.S{2}={'E56' 'E63' 'E69' 'E74' 'E82' 'E95'};
        badchan.S{3}={'E49' 'E116'};%
        badchan.S{4}={'E6' 'E8' 'E9' 'E14' 'E22' 'E46' 'E56' 'E58' 'E63' 'E65' 'E68' 'E69' 'E73' 'E74' 'E76' 'E80' 'E82' 'E83' 'E89' 'E93' 'E95' 'E96' 'E97' 'E98' 'E99' 'E100'...
                      'E102' 'E108' 'E109' 'E121' 'E126' 'E128'  }; % check E41,50,59,101 > seem to have high frequency
        badchan.S{5}={'E14' 'E17' 'E19' 'E22' 'E125' 'E126'};
        badchan.S{6}={'E8' 'E14' 'E17' 'E22' 'E26' 'E33' 'E40' 'E46' 'E50' 'E56' 'E57'  'E58' 'E63' 'E64' 'E65' 'E69' 'E70' 'E71' 'E72' 'E74' 'E75' 'E82' 'E83' 'E89' 'E91' 'E95' 'E121'};
        badchan.S{7}={'E8' 'E9' 'E14' 'E15' 'E18' 'E22' 'E23' 'E26' 'E44' 'E55' 'E56'};% check E35, 36 40, 41 45, 46, 103,104 > seem to have high frequency
        badchan.S{8}={'E17' 'E40' 'E126' 'E127' };
        badchan.S{9}={'E17' 'E26' 'E46' 'E63' 'E69' 'E74' 'E82' 'E89' 'E95' 'E100' 'E108' 'E109'};
        badchan.S{10}={'E8' 'E22' 'E26' 'E56' 'E63' 'E69' 'E74' 'E82' 'E89' 'E95' 'E100' 'E101' 'E108'};
        badchan.S{11}={'E8' 'E9' 'E17' 'E49' 'E56' 'E102' 'E115' 'E125'};
        badchan.S{12}={'E1' 'E8' 'E9' 'E14' 'E16' 'E17' 'E22' 'E26' 'E56' 'E63' 'E69' 'E74' 'E82' 'E89' 'E95' 'E99' 'E100' 'E121' 'E125' 'E126' 'E127'};
        badchan.S{13}={'E14' 'E15' 'E17' 'E18' 'E22' 'E23' 'E26' 'E49' 'E56' 'E63' 'E121' 'E125' 'E126'};
        badchan.S{14}={'E8' 'E14' 'E22' 'E26' 'E49' 'E56' 'E63' 'E69' 'E74' 'E95' 'E125' 'E126' 'E127'};
        badchan.S{15}={'E8' 'E22' 'E26' 'E63' 'E69' 'E70' 'E71' 'E74' 'E75' 'E76' 'E82' 'E83' 'E84' 'E89' 'E90'}; 
        badchan.S{16}={'E1' 'E2' 'E8' 'E33' 'E39' 'E40' 'E44' 'E45' 'E52' 'E56' 'E58' 'E63' 'E64' 'E73' 'E85' 'E90' 'E92' 'E96' 'E97' 'E99' 'E100'...
                       'E101' 'E102' 'E104' 'E108' 'E109' 'E116'};
        badchan.S{17}={'E1' 'E2' 'E3' 'E8' 'E9' 'E14' 'E17' 'E22' 'E23' 'E26' 'E27' 'E33' 'E39' 'E63' 'E69' 'E71' 'E74' 'E75' 'E82' 'E89'...
                       'E108' 'E109' 'E125' 'E128'};
        badchan.S{18}={};
        badchan.S{19}={'E26' 'E56' 'E127' 'E128'};
        badchan.S{20}={'E8' 'E20' 'E56' 'E63' 'E71' 'E75' 'E82' 'E89' 'E108' 'E110' 'E125' 'E126' };
        badchan.S{21}={'E1' 'E8' 'E9' 'E14' 'E15' 'E17' 'E26' 'E33' 'E39' 'E44' 'E49' 'E56' 'E57' 'E63' 'E64' 'E69' 'E74' 'E82' 'E83' 'E89' 'E95' 'E100' 'E108'};
        
        badchan.S{22}={'E1' 'E2' 'E3' 'E8' 'E9' 'E14' 'E17' 'E18' 'E22' 'E23' 'E26' 'E27' 'E33' 'E44' 'E56' 'E64' 'E70' 'E71' 'E74' 'E89' 'E90' 'E95' 'E96' 'E125' 'E126' 'E127' 'E128'};
        badchan.S{23}={'E1' 'E8' 'E7' 'E14' 'E22' 'E73' 'E108' 'E125' };
        badchan.S{24}={'E8' 'E9' 'E56' 'E63' 'E69' 'E74' 'E82' 'E89' 'E99' 'E108' 'E125' 'E126'};
    
%%
for subj = 1:length(allFolder);
   tmpfolder = allFolder(subj).name;
    cd(tmpfolder)
    
    loadName = dir('*.set');
  
    EEG = pop_loadset('filename',loadName.name,'filepath',pwd);
    
    
    %% Filter, Bad Channel rejection & autoClean
    
    % high-pass filter at 1Hz, filter order 826, transition band width 1Hz
    %EEG = pop_eegfiltnew(EEG, [], 1, 826, true, [], 1);
    EEG = pop_firws(EEG, 'fcutoff', 0.5, 'ftype', 'highpass', 'wtype', 'hamming', 'forder', 826);
    EEG = eeg_checkset( EEG );
    
    % low-pass filter at 40Hz
    EEG = pop_eegfiltnew(EEG, [], 40, 84, 0, [], 0);
    %EEG = pop_firws(EEG, 'fcutoff', 45, 'ftype', 'lowpass', 'wtype', 'hamming', 'forder', 84);
    EEG = eeg_checkset( EEG );
    

    
    %% manual inspection for chan rej
    % EEG = pop_rejchan(EEG, 'elec',[1:EEG.nbchan]
    % ,'threshold',5,'norm','on','measure','kurt'); IT REJECTS TOO MANY CHANNEL THAT DON'T LOOK BAD
    % TO INSPECT CHANNEL MANUALLY: stdData = std(EEG.data,0,2);figure;bar(stdData); 

    % pop_eegplot( EEG, 1, 1, 1);
    
    %EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[124:126] ,'computepower',1,'linefreqs',[60 120]...
    %  ,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',1,'scanforlines',1,'sigtype','Channels','tau',100,...
    %  'verb',1,'winsize',4,'winstep',1,'ComputeSpectralPower',false);
    
    
    
    
    %% Channel rejection - from manual inpsection

    % Remove Bad Channel 
  
    eval(['badchannels=badchan.S{',num2str(subj),'}(:);'])
   
    if ~isempty(badchannels) % remove bad channels
        EEG = pop_select( EEG, 'nochannel',badchannels );
        EEG = eeg_checkset( EEG );
    end

    %% select events & epoch data
   
%     EEG = pop_selectevent( EEG, 'type',{'TCBL' 'TIBL' 'NCBL' 'NIBL' 'TarC' 'TarI' 'NTaC' 'NTaI' 'resp' 'chk0' 'chck' 'clck' 'rest'},'deleteevents','on');
%     EEG = pop_epoch( EEG, {  'TCBL' 'TIBL' 'NCBL' 'NIBL' 'TarC' 'TarI' 'NTaC' 'NTaI'  }, [-1       2], 'epochinfo', 'yes');
    EEG = pop_selectevent( EEG, 'type',{'checks','clocks','DC','DCBL', 'TCheck'},'deleteevents','on');
    EEG = pop_epoch( EEG, {  'DC','DCBL', 'TCheck'  }, [-1       1], 'epochinfo', 'yes');    
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-1000    0]);
    

    
    
    %% epoch rejection
    EEG = pop_eegthresh(EEG,1,[1:EEG.nbchan] ,-500,500,-1,1,2,1); % change
    EEG = pop_jointprob(EEG,1,[1:EEG.nbchan] ,5,5,0,1);  
    
    % percentage rejected
    % S1 = 23/722 trials rejected ; 80/699 trials rejected
    % S2 = 6/722 trials rejected  ; 104/716 trials rejected
    % S3 = 12/722 trials rejected ; 78/710 trials rejected
    % S4 = 22/722 trials rejected ; 90/700 trials rejected
    % S5 = 28/722 trials rejected ; 91/694 trials rejected
    % S6 = 1/722 trials rejected  ; 101/721 trials rejected
    % S7 = 13/722 trials rejected ; 153/709 trials rejected
    % S8 = 25/722 trials rejected ; 85/697 trials rejected
    % S9 = 3/721 trials rejected  ; 80/718 trials rejected
    % S10= 4/721 trials rejected  ; 72/717 trials rejected
    % S11= 14/722 trials rejected ; 142/708 trials rejected
    % S12= 3/722 trials rejected  ; 92/719 trials rejected
    % S13= 19/722 trials rejected ; 51/703 trials rejected
    % S14= 36/722 trials rejected ; 68/686 trials rejected
    % S15= 0/722 trials rejected  ; 74/722 trials rejected
    % S16= 121/722 trials rejected; 65/601 trials rejected * high number rejected 
    % S17= 6/722 trials rejected  ; 92/716 trials rejected
    % S18= 5/722 trials rejected  ; 77/717 trials rejected * good
    % S19= 0/722 trials rejected  ; 75/722 trials rejected
    % S20= 16/722 trials rejected ; 153/706 trials rejected
    % S21= 25/722 trials rejected ; 84/697 trials rejected
    % S22= 2/721 trials rejected  ; 67/719 trials rejected
    % S23= 23/721 trials rejected ; 65/698 trials rejected
    % S24= 0/722 trials rejected  ; 76/722 trials rejected
    
    
    %% save & visual inspection
    filename=strcat(allFolder(subj).name,'_clean');
     
    EEG = pop_saveset( EEG,  'filename', filename,'filepath',pwd);

  
    cd(homeFolder)
   

    
     
      end
    

    


%%

%  
% [EEGcleaned, Mask]= clean_windows(EEG); % christian's other rejection function
% isFrameAnArtifactByMIR= detect_artifacts_by_robust_sphering_MIR(EEGcleaned, false, 2.1); % this is the rejection by MIR function.
%                  
% Mask = Mask(:) & ~isFrameAnArtifactByMIR(:); % rejects parts deemed bad by any of the methods
%  
% % do ICA, you can replace with binica(), runica(), amica...
% % [w, s] = cudaica(EEG.data(EEG.icachansind, Mask), 'extended', 3);
% % EEG = eeg_checkset(EEG, 'ica');
% 
% EEGcleaned = pop_select( EEGcleaned,'point', find(Mask));
% EEG = pop_runamica( EEGcleaned, 'exteded', 3);
% % EEG = OUT_EEG;

% ssh computing
% qstat -g c
% qstat -u '*'
% qlogin
% matlab
% 
% For amica option,
% 
% 'use_queue', 'qaX', 'do_reject', 1, 'numrej', 5, 'rejsig', 5
