close all; clear all; clc;

homeFolder = '/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks';
allFolder  = dir('S*');
cd(homeFolder)

% load components nuber, domain 1 ERP
load('/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/ContributingICs/Tchecks/ERP_ClsList_dom1.mat');

IC2use = [1 2 1 1 2 2 1 1 2 1 2 2 2 2 1 1 2 2 2 2 2 2 2 2];

AlloutputPotential = cell(length(allFolder),4);
AlloutputPower5Hzto7Hz = cell(length(allFolder),4);
AlloutputPower9Hzto15Hz = cell(length(allFolder),4);
AlloutputPower15Hzto24Hz = cell(length(allFolder),4);

%% plot erpimage - amplitudeor power(dB) and potentional (uVolt)

for subj = [1:12 14:length(allFolder)]; % subj 13, too few trials
    
    
    filename=allFolder(subj).name;
    cd(allFolder(subj).name)
    load('UReventAndTimeofTtimeChecksEvents.mat');
    
    EEG = pop_loadset('filename',[filename '_epochTC.set'],'filepath',pwd);
    Events = {EEG.event.type};
    
    Timechecks  = find(ismember(Events,'TCheck')); % find events
    %tmpsortvar1 = [EEG.event(Timechecks).TimeBetweenClock];% sort variable
    URevent1    = [EEG.event(Timechecks).urevent];
    URevent2    = tmpMatrix(1,:);
    
    tmpTCinfo(1,:) = [EEG.event(Timechecks).epoch];
    tmpTCinfo(2,:) = [EEG.event(Timechecks).urevent];
    tmpTCinfo(3,:) = tmpMatrix(2,ismember(URevent2,URevent1));
    
    % do not consider events with time 0
    tmpTCinfo = tmpTCinfo(:,tmpTCinfo(3,:)~=0);
    
    %temp sort
    tmpsortvar = tmpTCinfo(3,:);
    
    % Component number
    CompNum = ICsList(subj,IC2use(subj));
    
    % Get IC activity
    epochsNum   = tmpTCinfo(1,:); % epochsNum
    tmpdata = EEG.icaact(CompNum,:,epochsNum);
    
    % clear temporal variable
    clear tmpTCinfo
    
    %input for potential erpimage
    data     = tmpdata;         % (frames,trials)
    sortvar  = tmpsortvar;      % variable to sort epochs (lenght(sortvar)=nepochs)
    times    = [-1000 500 256] ;% epoch time points  [startms ntimes srate]
    avewidth = 1;               % 1 = not smoothed
    decimate = 1;               % 1 = not decimated
    plotamps = 'off';           %plot potential
    
    figure;
    [outdata,outvar] = ...
        erpimage(data,sortvar,times,'ERP - potential',avewidth,decimate,'plotamps',plotamps);
    
    % save output
    % outdata = data matrix after smoothing
    save('ERPimagePotential_ERPd1.mat','outdata')
    % outvar  = actual values trials are sorted on
    save('ERPimagePotentialSortvar_ERPd1.mat','outvar')
    
    % save figure
    print( '-depsc2', ['ERPimagePotential_ERPd1_S' filename])
    
    % store output in cell array
    AlloutputPotential{subj,1} = outdata;
    AlloutputPotential{subj,2} = outvar;
    
    % store raw data in cell array
    AlloutputPotential{subj,3} = data;
    AlloutputPotential{subj,4} = sortvar;
    
    %% input for power(amplitude) erpimage
    
    %data = ;% (frames,trials)
    %sortvar =;% variable to sort epochs (lenght(sortvar)=nepochs)
    times = [-1000 500 256] ;%epoch time points  [startms ntimes srate]
    avewidth = 1; %smooth 1 = no smooth,
    plotamps = 'on'; % amplitude of each trial
    
    % bandwidht 5-7Hz
    coher = [5 7 0.05]; % with alpha level 'coher',[LowFq HighFq 0.05]
    figure;
    [outdata,outvar] = ...
        erpimage(data,sortvar,times,'ERP - power',avewidth,decimate,'plotamps',plotamps,'coher',coher);
    
    % save output
    % outdata = data matrix after smoothing
    save('ERPimagePower5-7Hz_ERPd1.mat','outdata')
    % outvar  = actual values trials are sorted on
    save('ERPimagePower5-7Hz_Sortvar_ERPd1.mat','outvar')
    
    % save figure
    print( '-depsc2', ['ERPimagePower5-7Hz_ERPd1_S' filename])
    
    % store output in cell array
    AlloutputPower5Hzto7Hz{subj,1} = outdata;
    AlloutputPower5Hzto7Hz{subj,2} = outvar;
    
    % store raw data in cell array
    AlloutputPower5Hzto7Hz{subj,3} = data;
    AlloutputPower5Hzto7Hz{subj,4} = sortvar;
    
    % bandwidht 9-15Hz
    coher = [9 15 0.05]; % with alpha level 'coher',[LowFq HighFq 0.05]
    figure;
    [outdata,outvar] = ...
        erpimage(data,sortvar,times,'ERP - power',avewidth,decimate,'plotamps',plotamps,'coher',coher);
    
    % save output
    % outdata = data matrix after smoothing
    save('ERPimagePower9-15Hz_ERPd1.mat','outdata')
    % outvar  = actual values trials are sorted on
    save('ERPimagePower9-15Hz_Sortvar_ERPd1.mat','outvar')
 
    % save figure
    print( '-depsc2', ['ERPimagePower9-15Hz_ERPd1_S' filename])
    
    % store output in cell array
    AlloutputPower9Hzto15Hz{subj,1} = outdata;
    AlloutputPower9Hzto15Hz{subj,2} = outvar;
    
    % store raw data in cell array
    AlloutputPower9Hzto15Hz{subj,3} = data;
    AlloutputPower9Hzto15Hz{subj,4} = sortvar;
   
    
    % bandwidht 15-24Hz
    
    coher = [15 24 0.05]; % with alpha level 'coher',[LowFq HighFq 0.05]
    figure;
    [outdata,outvar] = ...
        erpimage(data,sortvar,times,'ERP - power',avewidth,decimate,'plotamps',plotamps,'coher',coher);
    
    % save output
    % outdata = data matrix after smoothing
    save('ERPimagePower15-24Hz_ERPd1.mat','outdata')
    % outvar  = actual values trials are sorted on
    save('ERPimagePower15-24Hz_Sortvar_ERPd1.mat','outvar')
    
    % save figure
    print( '-depsc2', ['ERPimagePower15-24Hz_ERPd1_S' filename])
    
    % store output in cell array
    AlloutputPower15Hzto24Hz{subj,1} = outdata;
    AlloutputPower15Hzto24Hz{subj,2} = outvar;
    
    % store raw data in cell array
    AlloutputPower15Hzto24Hz{subj,3} = data;
    AlloutputPower15Hzto24Hz{subj,4} = sortvar;
   
    
    cd(homeFolder)
    
    close all
end
%% save matrix with all subject info

AlloutputPotential = AlloutputPotential([1:12 14:24],:);
AlloutputPower5Hzto7Hz = AlloutputPower5Hzto7Hz([1:12 14:24],:);
AlloutputPower9Hzto15Hz = AlloutputPower9Hzto15Hz([1:12 14:24],:);
AlloutputPower15Hzto24Hz = AlloutputPower15Hzto24Hz([1:12 14:24],:);

save('/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AlloutputPotential_ERPd1.mat','AlloutputPotential')
save('/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AlloutputPower5Hzto7Hz_ERPd1.mat','AlloutputPower5Hzto7Hz')
save('/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AlloutputPower9Hzto15Hz_ERPd1.mat','AlloutputPower9Hzto15Hz')
save('/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AlloutputPower15Hzto24Hz_ERPd1.mat','AlloutputPower15Hzto24Hz')

%% group erp image


%input for potential erpimage from outvar
% data     = cat(2,AlloutputPotential{:,1}); % (frames,trials)
% sortvar  = cat(2,AlloutputPotential{:,2});% variable to sort epochs (lenght(sortvar)=nepochs)
% times    = [-1000 500 256] ;%epoch time points  [startms ntimes srate]
% avewidth = 10; %smooth 1 = no smooth,
% plotamps = 'off';           %plot potential
% 
% figure;
% [outdata,outvar] = ...
%     erpimage(data,sortvar,times,'ERP - potential',avewidth,decimate,'plotamps',plotamps);


%input for potential erpimage from outvar
data     = cat(3,AlloutputPotential{:,3}); % (frames,trials)
sortvar  = cat(2,AlloutputPotential{:,4});% variable to sort epochs (lenght(sortvar)=nepochs)
times    = [-1000 500 256] ;%epoch time points  [startms ntimes srate]
avewidth = 10; %smooth 1 = no smooth,
decimate = 1;
plotamps = 'off';           %plot potential


figure;
[outdata,outvar] = ...
    erpimage(data,sortvar,times,'ERP - potential',avewidth,decimate,'plotamps',plotamps, 'renorm' ,'yes');
print( '-depsc2','/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AllerpimagePotential_ERPd1')

% input for power(amplitude) erpimage
avewidth = 10; %smooth 1 = no smooth,
plotamps = 'on'; % amplitude of each trial

% bandwidht 5-7Hz
coher = [5 7 0.05]; % with alpha level 'coher',[LowFq HighFq 0.05]
figure;
[outdata,outvar] = ...
    erpimage(data,sortvar,times,'ERP - power',avewidth,decimate,'plotamps',plotamps,'coher',coher, 'renorm' ,'yes',  'nosort'  ,'off');
% save figure
print( '-depsc2','/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AllerpimagePower5Hzto7Hz_ERPd1')


% bandwidht 9-15Hz
coher = [9 15 0.05]; % with alpha level 'coher',[LowFq HighFq 0.05]
figure;
[outdata,outvar] = ...
    erpimage(data,sortvar,times,'ERP - power',avewidth,decimate,'plotamps',...
    plotamps,'coher',coher, 'renorm' ,'yes',  'nosort'  ,'off','cbar' ,'on','caxis',[-8.8 8.8] );
print( '-depsc2','/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AllerpimagePower9Hzto15Hz_ERPd1')

% bandwidht 15-24Hz

coher = [15 24 0.05]; % with alpha level 'coher',[LowFq HighFq 0.05]
figure;
[outdata,outvar] = ...
    erpimage(data,sortvar,times,'ERP - power',avewidth,decimate,'plotamps',plotamps,'coher',coher, 'renorm' ,'yes',  'nosort'  ,'off');
print( '-depsc2','/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AllerpimagePower15Hzto24Hz_ERPd1')

% plot colour bar


%% sorted by phase

% bandwidht 5-7Hz
coher = [5 7 0.05]; % with alpha level 'coher',[LowFq HighFq 0.05]
figure;
[outdata,outvar] = ...
    erpimage(data,sortvar,times,'ERP - power',avewidth,decimate,'plotamps',plotamps,'coher',coher, 'renorm' ,'yes',  'nosort'  ,'off','phasesort',[0 50 5 7]);
% save figure
print( '-depsc2','/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AllerpimagePower5Hzto7Hz_PhaseSorted_ERPd1')


% bandwidht 9-15Hz
coher = [9 15 0.05]; % with alpha level 'coher',[LowFq HighFq 0.05]
figure;
[outdata,outvar] = ...
    erpimage(data,sortvar,times,'ERP - power',avewidth,decimate,'plotamps',plotamps,'coher',coher, 'renorm' ,'yes',  'nosort'  ,'off','phasesort',[0 50 9 15]);
print( '-depsc2','/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AllerpimagePower9Hzto15Hz_PhaseSorted_ERPd1')

% bandwidht 15-24Hz

coher = [15 24 0.05]; % with alpha level 'coher',[LowFq HighFq 0.05]
figure;
[outdata,outvar] = ...
    erpimage(data,sortvar,times,'ERP - power',avewidth,decimate,'plotamps',plotamps,'coher',coher, 'renorm' ,'yes',  'nosort'  ,'off','phasesort',[0 50 15 24]);
print( '-depsc2','/Users/gabycruz/experiments/EEG_timebased_PM/EEGdata/EEGcontData/cont2epochTchecks/AllerpimagePower15Hzto24Hz_PhaseSorted_ERPd1')




% 
% % example
% 
% >> figure;
% erpimage(data,RTs,[-400 256 256],'Test',1,1, 'erp','cbar','vert',-350);
% % Plots an ERP-image of 1-s data epochs sampled at 256 Hz, sorted by RTs, with
% % title ('Test'), and sorted epochs not smoothed or decimated (1,1). Overplots
% % the (unsmoothed) RT latencies on the colored ERP-image. Also plots the
% % epoch-mean (ERP), a color bar, and a dashed vertical line at -350 ms.