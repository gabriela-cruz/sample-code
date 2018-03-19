
close all; clear all; clc;

%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
homeFolder = '/analyse/Project0108/timebased_PM/EEGdata';
cd(homeFolder)

allFolder = dir('S*');


for subj = 1:length(allFolder);
     subid = num2str(subj);
       if length(subid)==1
        subid = ['0',subid];
       end
    
moveSubFolder = allFolder(subj).name;
cd(moveSubFolder) 
loadName = dir('*ica.set');


        for session = 1:length(loadName);
        tmpLoadName = loadName(session).name;
        
         EEG = pop_loadset('filename', tmpLoadName, 'filepath', pwd);
         
    % dipole fitting 
    
        EEG = eeg_checkset( EEG );
        EEG = pop_dipfit_settings( EEG, 'hdmfile','/usr/matlab-2013b/toolbox/eeglab13_1_1b/plugins/dipfit2.2/standard_BEM/standard_vol_SCCN.mat'...
            ,'coordformat','MNI','mrifile','/usr/matlab-2013b/toolbox/eeglab13_1_1b/plugins/dipfit2.2/standard_BEM/standard_mri.mat','chanfile',...
            '/usr/matlab-2013b/toolbox/eeglab13_1_1b/plugins/dipfit2.2/standard_BEM/elec/standard_1005.elc','coord_transform',...
            [0.05476 -22 -2 0.057 0.0031836 -1.5696 11.7138 12.7933 12.213] ,'chansel',[1:EEG.nbchan] );
        EEG = pop_multifit(EEG, [1:EEG.nbchan] ,'threshold',100,'dipplot','on','plotopt',{'normlen' 'on'}); 
        
      
   
  
    % save
        EEG = pop_saveset( EEG, 'savemode','resave');
            
      end
      cd(homeFolder)
end
    




