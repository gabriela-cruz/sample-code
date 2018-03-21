% ===================================================================================
% Clean the data, calculate PSD, store new data file and save PSD figures
% ===================================================================================
% This code calculate Power Spectral Density to calculate individual
% frequency bands. See code: preproc2_AlphaSuppression.m





FilePath = '/Volumes/Data HD/experiments/NF/EEGdata/';

SubID = '01';

Eyes = {'EC' 'EO'};

for e = 1:length(Eyes) % e= 2
    %% Load, filter and clean baseline data% Load subject data and keep EEG data only
    %load([ FilePath 'S' SubID '/B1_EC.mat']);
    load([ FilePath 'S' SubID '/B1_' Eyes{e} '.mat']);
    
    EEG_data = [TrigEEG_19Chs(3:18,:) ; TrigEEG_19Chs(20:22,:)];
    
    save([ FilePath 'S' SubID '/EEG_' Eyes{e} '.mat'],'EEG_data');
    
    % Load EEG data in EEGlab
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_importdata('dataformat','matlab','nbchan',0,'data',[ FilePath 'S' SubID '/EEG_' Eyes{e} '.mat'],'srate',256,'pnts',0,'xmin',0,...
        'chanlocs','/Users/gabycruz/toolboxes/eeglab/sample_locs/Standard-10-20-Cap19.locs');
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',['S01_' Eyes{e}],'gui','off');
    
    % filter the data
    %EEG = pop_eegfiltnew(EEG, [], 40, 86, 0, [], 1);
    EEG = pop_eegfiltnew(EEG, [], 30, 114, 0, [], 0);
    %EEG = pop_eegfiltnew(EEG, [], 0.1, 8448, true, [], 1);
    EEG = pop_eegfiltnew(EEG, [], 1, 846, true, [], 0);
    EEG = eeg_checkset( EEG );
    
    
    eeglab redraw
    %%
    % Reject initial and final data - manual inspection
    pop_eegplot( EEG, 1, 1, 1);
    
    %EEG = eeg_eegrej( EEG, [1 6400] ); % delete first 25 secs (25*256=6400)
    %EEG = eeg_eegrej( EEG, [44288 46592] ); % delete last seconds
    
    EEG = eeg_checkset( EEG );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    
    % save data
    
    EEG_data = EEG.data;
    save([ FilePath 'S' SubID '/EEG_' Eyes{e} '.mat'],'EEG_data');
    
    %% Calculate PSD (Power Spectral Density)
    % For channels Pz(15), P3(14), P4(16), O1(18), O2(19)
    
    channels = [14 15 16 18 19];
    channelsName = {'P3' 'Pz' 'P4' 'O1' 'O2'};
    
    if e ==1 % Eyes closed
        
        EC.AlphaPeakFreq = nan(length(channels),1);
        EC.AlphaPeakDb = nan(length(channels),1);
        EC.logPSD = nan(length(channels),225);
        
        
        for i = 1:length(channels)
            
            % Calculate PSD
            [Px,X]=pwelch(EEG.data(channels(i),:),512,[],2048,256);
            
            % Plot results
            subplot(2,3,i)
            plot(X(17:241),10*log10(Px(17:241)));
            title(channelsName{i})
            xlabel('Frequency (Hz)','FontSize',10);
            ylabel('Power 10*log10(µV^2/Hz)','FontSize',10);
            axis([2 30 -10 15])
            
            l = find(X==5);  % 5 Hz
            u = find(X==15); % 15 Hz
            a = max(Px(l:u)); % Find max value between 5Hz and 15Hz
            
            EC.AlphaPeakFreq(i) = X(Px==a);
            EC.AlphaPeakDb(i) = a;
            EC.logPSD(i,:) = 10*log10(Px(17:241));
            
        end
        
        EC.Freqs = X(17:241);
        %figure; plot(Freqs,logPSD(2,:));
        
        save([ FilePath 'S' SubID '/ECdata.mat'],'EC');
        print( '-depsc2', [ FilePath 'S' SubID '/EEG_' Eyes{e}])
        
        
    else % Eyes open
        
        EO.logPSD = nan(length(channels),225);
        
        
        for i = 1:length(channels)
            
            % Calculate PSD
            [Px,X]=pwelch(EEG.data(channels(i),:),512,[],2048,256);
            
            % Plot results
            subplot(2,3,i)
            plot(X(17:241),10*log10(Px(17:241)));
            title(channelsName{i})
            xlabel('Frequency (Hz)','FontSize',10);
            ylabel('Power 10*log10(µV^2/Hz)','FontSize',10);
            axis([2 30 -10 15])
            
            l = find(X==5);  % 5 Hz
            u = find(X==15); % 15 Hz
            a = max(Px(l:u)); % Find max value between 5Hz and 15Hz
            
            
            EO.logPSD(i,:) = 10*log10(Px(17:241));
            
        end
        
        EO.Freqs = X(17:241);
        %figure; plot(Freqs,logPSD(2,:));
        save([ FilePath 'S' SubID '/EOdata.mat'],'EO');
        print( '-depsc2', [ FilePath 'S' SubID '/EEG_' Eyes{e}])
        
    end
    
    
    
end



%%
% channel numbers
% 1  Fp1
% 2  Fp2
% 3  F7
% 4  F3
% 5  Fz
% 6  F4
% 7  F8
% 8  T7
% 9  C3
% 10 Cz
% 11 C4
% 12 T8
% 13 P7
% 14 P3
% 15 Pz
% 16 P4
% 17 P8
% 18 O1
% 19 O2




