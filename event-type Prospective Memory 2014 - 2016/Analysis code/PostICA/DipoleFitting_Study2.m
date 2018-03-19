
close all; clear all; clc;

%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
homeFolder = '/data/projects/gaby/Data_study2';
cd(homeFolder)

allFolder = dir('S*');


for subj = 2:length(allFolder);
     subid = num2str(subj);
       if length(subid)==1
        subid = ['0',subid];
       end
    
moveSubFolder = strcat(allFolder(subj).name,'/Manual/1Hz');
cd(moveSubFolder) 
loadName = dir('*ica.set');


        for session = 1:length(loadName);
        tmpLoadName = loadName(session).name;
        
         EEG = pop_loadset('filename', tmpLoadName, 'filepath', pwd);
         
    % dipole fitting 
        EEG = eeg_checkset( EEG );
        EEG = pop_dipfit_settings( EEG, 'hdmfile','/data/common/matlab/eeglab/plugins/dipfit2.2/standard_BEM/standard_vol_SCCN.mat'...
            ,'coordformat','MNI','mrifile','/data/common/matlab/eeglab/plugins/dipfit2.2/standard_BEM/standard_mri.mat','chanfile',...
            '/data/common/matlab/eeglab/plugins/dipfit2.2/standard_BEM/elec/standard_1005.elc','coord_transform',...
            [0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213] ,'chansel',[1:EEG.nbchan] );
        EEG = pop_multifit(EEG, [1:EEG.nbchan] ,'threshold',100,'dipplot','on','plotopt',{'normlen' 'on'}); 
           
  
    % save
        EEG = pop_saveset( EEG, 'savemode','resave');
            
      end
      cd(homeFolder)
end
    




