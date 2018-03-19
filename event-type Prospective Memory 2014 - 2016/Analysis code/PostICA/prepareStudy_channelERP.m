clear all; clc; 
ALLEEG = struct();
homeFolder = '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy';
cd(homeFolder)

allSubj = dir('*.set');
count = 0;

for subj = 1:length(allSubj);
    
     
    loadName = allSubj(subj).name;
         
    
    EEG = pop_loadset('filename', loadName, 'filepath', pwd, 'loadmode', 'info');
    
    if mod(subj,2) == 1;
        SubjNum = count+1
        EEG.subject = ['Subj' num2str(SubjNum)];
        EEG.group = 'C';
        count = count+1;
    else
        EEG.subject = ['Subj' num2str(SubjNum)];
        EEG.group= 'P';
    end
    
 
    % store EEG
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, 0);
    
    cd(homeFolder)
    
    
end
eeglab redraw

%%

% eegh
% [EEG ALLEEG CURRENTSET] = eeg_retrieve(ALLEEG,1);
% [STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
% [STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
% [STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
% [STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
% [STUDY, ALLEEG] = std_checkset(STUDY, ALLEEG);
% [STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name','PM1','commands',{{'inbrain' 'on' 'dipselect' 0.15}},'updatedat','on','savedat','on' );
% CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
% STUDY = std_makedesign(STUDY, ALLEEG, 1, 'variable1','condition','variable2','type','name','BLvsOnG','pairing1','off','pairing2','on','delfiles','off','defaultdesign','off','values1',{'C' 'P'},'values2',{{'NTaCBL' 'TarCBL'} {'NTaC' 'TarC'}},'subjselect',{'Subj1' 'Subj10' 'Subj11' 'Subj12' 'Subj13' 'Subj14' 'Subj15' 'Subj16' 'Subj17' 'Subj18' 'Subj19' 'Subj2' 'Subj20' 'Subj21' 'Subj22' 'Subj23' 'Subj24' 'Subj25' 'Subj26' 'Subj3' 'Subj4' 'Subj5' 'Subj6' 'Subj7' 'Subj8' 'Subj9'});
% STUDY = std_makedesign(STUDY, ALLEEG, 2, 'variable1','condition','variable2','type','name','NTarBLvsNTarOnG','pairing1','off','pairing2','on','delfiles','off','defaultdesign','off','values1',{'C' 'P'},'values2',{'NTaC' 'NTaCBL'},'subjselect',{'Subj1' 'Subj10' 'Subj11' 'Subj12' 'Subj13' 'Subj14' 'Subj15' 'Subj16' 'Subj17' 'Subj18' 'Subj19' 'Subj2' 'Subj20' 'Subj21' 'Subj22' 'Subj23' 'Subj24' 'Subj25' 'Subj26' 'Subj3' 'Subj4' 'Subj5' 'Subj6' 'Subj7' 'Subj8' 'Subj9'});
% STUDY = std_makedesign(STUDY, ALLEEG, 3, 'variable1','condition','variable2','type','name','TarBLvsTarOnG','pairing1','off','pairing2','on','delfiles','off','defaultdesign','off','values1',{'C' 'P'},'values2',{'PM_C' {'NTaC' 'TarC'}},'subjselect',{'Subj1' 'Subj10' 'Subj11' 'Subj12' 'Subj13' 'Subj14' 'Subj15' 'Subj16' 'Subj17' 'Subj18' 'Subj19' 'Subj2' 'Subj20' 'Subj21' 'Subj22' 'Subj23' 'Subj24' 'Subj25' 'Subj26' 'Subj3' 'Subj4' 'Subj5' 'Subj6' 'Subj7' 'Subj8' 'Subj9'});
% STUDY = std_makedesign(STUDY, ALLEEG, 4, 'variable1','condition','variable2','type','name','OnGvsPM','pairing1','off','pairing2','on','delfiles','off','defaultdesign','off','values1',{'C' 'P'},'values2',{'PM_C' {'NTaC' 'TarC'}},'subjselect',{'Subj1' 'Subj10' 'Subj11' 'Subj12' 'Subj13' 'Subj14' 'Subj15' 'Subj16' 'Subj17' 'Subj18' 'Subj19' 'Subj2' 'Subj20' 'Subj21' 'Subj22' 'Subj23' 'Subj24' 'Subj25' 'Subj26' 'Subj3' 'Subj4' 'Subj5' 'Subj6' 'Subj7' 'Subj8' 'Subj9'});
% STUDY = std_selectdesign(STUDY, ALLEEG, 3);
% 
% CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
% [STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename','PM1.study','filepath','/data/projects/gaby/project0108_gla/');
% CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];