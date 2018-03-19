close all; clear all; clc;

homeFolder = '/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata';
cd(homeFolder)

allFolder = dir('S*');

%% Reject one channel after average reference and before running ICA
% after doing average reference and before runing ICA you have to reject
% one channel, have a look at this post http://sccn.ucsd.edu/pipermail/eeglablist/2012/004670.html

badchan.S{1}={'E128' }; 
badchan.S{2}={'E16'};
badchan.S{3}={'E46'};%
badchan.S{4}={'E127' }; 
badchan.S{5}={'E110' };
badchan.S{6}={'E103'};
badchan.S{7}={'E58'}; 
badchan.S{8}={'E103'}; 
badchan.S{9}={'E116'}; 
badchan.S{10}={'E102'}; 
badchan.S{11}={'E128'};
badchan.S{12}={'E128' };
badchan.S{13}={'E128'}; 
badchan.S{14}={'E128' }; 
badchan.S{15}={'E56'};
badchan.S{16}={'E128'};
badchan.S{17}={'E110'};
badchan.S{18}={'E124'};
badchan.S{19}={'E126'};
badchan.S{20}={'E128'};
badchan.S{21}={'E128'};
badchan.S{22}={'E4'};
badchan.S{23}={'E128'};
badchan.S{24}={'E128'};

% 
% %as an alternative to this channel rejection you can run ICA with PCA
% %['pca', EEG.nbchan-1] look at this post http://sccn.ucsd.edu/pipermail/eeglablist/2010/003339.html


%%
for subj = 1:length(allFolder);
    %% load clean dataset
    tmpfolder = allFolder(subj).name;
    cd(tmpfolder)
    
    loadName = dir('*clean.set');
  
    EEG = pop_loadset('filename',loadName.name,'filepath',pwd);
     
    %% average ref
     
    EEG = pop_reref( EEG, []);
     
    %% Channel rejection - rank reduction
     
    % Rejection for
    
   
    eval(['badchannels=badchan.S{',num2str(subj),'}(:);'])
    
    if ~isempty(badchannels) 
        EEG = pop_select( EEG, 'nochannel',badchannels );
        EEG = eeg_checkset( EEG );
    end
    
        
    
    %% ICA - infomax
    EEG=pop_runica(EEG,'extended',3);

    
    %% save dataset
    
    filename=strcat(allFolder(subj).name,'_ica');
   
    EEG = pop_saveset( EEG,  'filename', filename,'filepath',pwd);
    
    %%
    cd(homeFolder)
    
end



