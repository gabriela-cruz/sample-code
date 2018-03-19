%  Group analysis

%% Get ERSP from domain

domainNumber = 1;

dipoleAndMeasure = STUDY.measureProjection.ersp.object; % get the ERP and dipole data (dataAndMeasure object) from the STUDY structure.
domain = STUDY.measureProjection.ersp.projection.domain(domainNumber); % get the domain in a separate variable
projection  = STUDY.measureProjection.ersp.projection;

headGrid = STUDY.measureProjection.ersp.headGrid;
[linearProjectedMeasure sessionConditionCell groupId uniqeDatasetId dipoleDensity] = ...
    dipoleAndMeasure.getMeanProjectedMeasureForEachSession(headGrid, domain.membershipCube, projection.projectionParameter);

ersptimes = STUDY.measureProjection.ersp.object.time;
erspfreqs = STUDY.measureProjection.ersp.object.frequency;

ersp21 = sessionConditionCell(:,1);
ersp22 = sessionConditionCell(:,2);
ersp11 = sessionConditionCell(:,3);
ersp12 = sessionConditionCell(:,4);

% % % domain 4 - no data for subj 16
% ersp21 = sessionConditionCell([1:15 17:24],1);%(:,1);([1:15 17:24],1);
% ersp22 = sessionConditionCell([1:15 17:24],2);%(:,2);
% ersp11 = sessionConditionCell([1:15 17:24],3);%(:,3);
% ersp12 = sessionConditionCell([1:15 17:24],5);%(:,5);

Allerspdata11 =  cat(3,ersp11{:});  
Allerspdata12 =  cat(3,ersp12{:});  
Allerspdata21 =  cat(3,ersp21{:});  
Allerspdata22 =  cat(3,ersp22{:});  



% ERSPdata = sessionConditionCell(:,4);
% dim = ndims(ERSPdata{1});
% M = cat(dim+1,ERSPdata{:});
% meanERSPArray = mean(M,dim+1);

% Plot - Time window
winStart = min(find(-200 < ersptimes ));
winEnd   = max(find(ersptimes  < 800));

erspdata11 =  Allerspdata11(winStart:winEnd,:,:);  
erspdata12 =  Allerspdata12(winStart:winEnd,:,:);    
erspdata21 =  Allerspdata21(winStart:winEnd,:,:);    
erspdata22 =  Allerspdata22(winStart:winEnd,:,:);    

% Stats - Time window
winStartStats = min(find(0 < ersptimes ));
winEndStats   = max(find(ersptimes  < 800));

erspdata11St =  Allerspdata11(winStartStats:winEndStats,:,:);  
erspdata12St =  Allerspdata12(winStartStats:winEndStats,:,:);    
erspdata21St =  Allerspdata21(winStartStats:winEndStats,:,:);    
erspdata22St =  Allerspdata22(winStartStats:winEndStats,:,:);    
 

%% statistics

% run stats
% [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
%  std_stat( {erspdata11 erspdata12; erspdata21 erspdata22}, 'method', 'parametric', 'condstats', 'on', 'mcorrect', 'fdr', 'groupstats','on','alpha',0.05);

[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
std_stat( {erspdata11St erspdata12St; erspdata21St erspdata22St}, ...
'method', 'permutation', 'condstats', 'on', 'mcorrect', 'fdr', 'groupstats','on','alpha',0.05,'paired',{'on','on'});

Freqs = dipoleAndMeasure.frequency;

% line 136
% opt.paired = {'on' 'on'}

% pinter{1} - condition stat
% pinter{2} - group stat
% pinter{3} - intraction

% calculate mean
meanerspdata11 = mean(erspdata11,3);
meanerspdata12 = mean(erspdata12,3);
meanerspdata21 = mean(erspdata21,3);
meanerspdata22 = mean(erspdata22,3);


mask = zeros(200,20);
mask(winStartStats:winEndStats,:) = pcond{1};
mask = mask(winStart:winEnd,:); pcond{1} = mask;

mask = zeros(200,20);
mask(winStartStats:winEndStats,:) = pcond{2};
mask = mask(winStart:winEnd,:); pcond{2} = mask;

mask = zeros(200,20);
mask(winStartStats:winEndStats,:) = pgroup{1};
mask = mask(winStart:winEnd,:); pgroup{1} = mask;

mask = zeros(200,20);
mask(winStartStats:winEndStats,:) = pgroup{2};
mask = mask(winStart:winEnd,:); pgroup{2} = mask;

mask = zeros(200,20);
mask(winStartStats:winEndStats,:) = pinter{1};
mask = mask(winStart:winEnd,:); pinter{1} = mask;

mask = zeros(200,20);
mask(winStartStats:winEndStats,:) = pinter{2};
mask = mask(winStart:winEnd,:); pinter{2} = mask;


mask = zeros(200,20);
mask(winStartStats:winEndStats,:) = pinter{3};
mask = mask(winStart:winEnd,:); pinter{3} = mask;

% create masks
maskedImage1 = (meanerspdata21-meanerspdata11).*pcond{1};
maskedImage2 = (meanerspdata22-meanerspdata12).*pcond{2};
maskedImage3 = (meanerspdata12-meanerspdata11).*pgroup{1};
maskedImage4 = (meanerspdata22-meanerspdata21).*pgroup{2};

% % create big masks
% 
% BigmaskedImage1  = zeros(200,20);
% BigmaskedImage1(winStart:winEnd,:) = maskedImage1;
% BigmaskedImage2  = zeros(200,20);
% BigmaskedImage2(winStart:winEnd,:) = maskedImage2;
% BigmaskedImage3  = zeros(200,20);
% BigmaskedImage3(winStart:winEnd,:) = maskedImage3;
% BigmaskedImage4  = zeros(200,20);
% BigmaskedImage4(winStart:winEnd,:) = maskedImage4;


% plot results

minC=min([min(erspdata11(:)),min(erspdata12(:)),min(erspdata21(:)),min(erspdata22(:))]); % min and max points to set all subplots to the same colormap scalling
maxC=max([max(erspdata11(:)),max(erspdata12(:)),max(erspdata21(:)),max(erspdata22(:))]);
%clim = [min(abs(minC),maxC)*-1,min(abs(minC),maxC)];
clim = [-4 4];

EvType = {'Related' 'Unrelated' };

 figure; hold on
    
    subplot(3,3,1)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,meanerspdata12',clim)
    set(gca,'YDir','normal');
    %set(gca,'YScale','log','YMinorTick','on','Ydir','normal')
    %set(gca,'YTick',2:(40-3)/10:100,'YTicklabel',round(2:(40-3)/10:100))
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title([EvType{1} ' Ongoing PM'])
    
    subplot(3,3,2)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,meanerspdata11',clim)
    set(gca,'YDir','normal');
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title([EvType{1} ' Ongoing Ctrl'])
    
    subplot(3,3,3)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,maskedImage3',clim)
    set(gca,'YDir','normal');
    %colorbar
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title([EvType{1} ', PM minus Ctrl, perm(p<0.05) fdr'])
    
    
    
    subplot(3,3,4)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,meanerspdata22',clim)
    set(gca,'YDir','normal');
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title([EvType{2} ' Ongoing PM'])
    
    subplot(3,3,5)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,meanerspdata21',clim)
    set(gca,'YDir','normal');
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title([EvType{2} ' Ongoing Ctrl'])
    
    subplot(3,3,6)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,maskedImage4',clim)
    set(gca,'YDir','normal');
    %colorbar
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title([EvType{2} ', PM minus Ctrl, perm(p<0.05) fdr'])
    
    
    
    subplot(3,3,7)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,maskedImage1',clim)
    set(gca,'YDir','normal');
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title([EvType{1} ' minus ' EvType{2} ' Ongoing PM'])
    
    subplot(3,3,8)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,maskedImage2',clim)
    set(gca,'YDir','normal');
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title([EvType{1} ' minus ' EvType{2}  ' Ongoing Ctrl'])
    
    subplot(3,3,9)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,pinter{3}',clim)
    set(gca,'YDir','normal');
    %colorbar
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title(' Interaction, perm(p<0.05) fdr')
    colorbar;


    %print( '-depsc2',  ['/Users/gabycruz/experiments/EEG_timebased_PM/Figures_TBPM/MPT_Jan16/ERSPs Ongoing Task Domain' num2str(domainNumber) ' ANOVA'])

%% New plot

%clim = [-2.3 2.3]; %scale taken from MPT plots


% erspdata11 =  Allerspdata11(winStart:winEnd,:,:);  
% erspdata12 =  Allerspdata12(winStart:winEnd,:,:);    
% erspdata21 =  Allerspdata21(winStart:winEnd,:,:);    
% erspdata22 =  Allerspdata22(winStart:winEnd,:,:);    
% 
% % calculate mean
% meanerspdata11 = mean(erspdata11,3);
% meanerspdata12 = mean(erspdata12,3);
% meanerspdata21 = mean(erspdata21,3);
% meanerspdata22 = mean(erspdata22,3);


% Event Type effect (Task condition pooled)
clim = [-3 3];

% tmpERSP = cat(3,erspdata11,erspdata12);
% meanerspdata11 = mean(tmpERSP,3);
% 
% tmpERSP = cat(3,erspdata21,erspdata22);
% meanerspdata12 = mean(tmpERSP,3);
% 
maskedImage = (meanerspdata12-meanerspdata11).*pinter{1};

figure; hold on
    
    subplot(1,3,1)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,meanerspdata12',clim)
    set(gca,'YDir','normal');
    %set(gca,'YScale','log','YMinorTick','on','Ydir','normal')
    %set(gca,'YTick',2:(40-3)/10:100,'YTicklabel',round(2:(40-3)/10:100))
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title(' Unrelated Words')
    
    subplot(1,3,2)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,meanerspdata11',clim)
    set(gca,'YDir','normal');
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title(' Related Words')
    
    subplot(1,3,3)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,maskedImage',clim)
    set(gca,'YDir','normal');
    colorbar
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title(' Unrelated minus Related, perm(p<0.05) fdr')

  %print( '-depsc2',  ['/Users/gabycruz/experiments/EEG_timebased_PM/Figures_TBPM/MPT_Jan16/ERSP_EventTypeeffect_TaskCond_pooled_ANOVA'])

  
    
% Task effect (Event type pooled)
clim = [-2.3 2.3]; %scale taken from MPT plots

% tmpERSP = cat(3,erspdata11,erspdata21);
% meanerspdata11 = mean(tmpERSP,3);
% 
% tmpERSP = cat(3,erspdata12,erspdata22);
% meanerspdata12 = mean(tmpERSP,3);
% 
 maskedImage = (meanerspdata12-meanerspdata11).*pinter{2};

 figure; hold on
    
    subplot(1,3,1)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,meanerspdata12',clim)
    set(gca,'YDir','normal');
    %set(gca,'YScale','log','YMinorTick','on','Ydir','normal')
    %set(gca,'YTick',2:(40-3)/10:100,'YTicklabel',round(2:(40-3)/10:100))
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title(' Ongoing PM')
    
    subplot(1,3,2)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,meanerspdata11',clim)
    set(gca,'YDir','normal');
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title(' Ongoing Only')
    
    subplot(1,3,3)
    imagesc(ersptimes(winStart:winEnd), erspfreqs,maskedImage',clim)
    set(gca,'YDir','normal');
    colorbar
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title(' PM minus Only, perm(p<0.05) fdr')

  %print( '-depsc2',  ['/Users/gabycruz/experiments/EEG_timebased_PM/Figures_TBPM/MPT_Jan16/ERSP_Taskeffect_Eventtype_pooled_ANOVA'])

 
  
% plot F-values
    clim = [-55 55];
    
    mask = zeros(200,20);
    mask(winStartStats:winEndStats,:) = statsinter{1};
    mask = mask(winStart:winEnd,:); statsinter{1} = mask;
    
    maskedImage = statsinter{1}.*pinter{1};
    figure; hold on
    imagesc(ersptimes(winStart:winEnd), erspfreqs,maskedImage',clim)
    set(gca,'YDir','normal');
    colorbar
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title(' Unrelated minus Related, perm(p<0.05) fdr')


    
    
 % plot F-values
   % clim = [5 25];
    mask = zeros(200,20);
    mask(winStartStats:winEndStats,:) = statsinter{2};
    mask = mask(winStart:winEnd,:); statsinter{2} = mask;
    
    maskedImage = statsinter{2}.*pinter{2};
    figure; hold on
    imagesc(ersptimes(winStart:winEnd), erspfreqs,maskedImage',clim)
    set(gca,'YDir','normal');
    colorbar
    ylabel('Frequency(Hz)','FontSize',14)
    xlabel('Time (ms)','FontSize',14)
    title(' Ongoing Only minus Ongoing PM, perm(p<0.05) fdr')

    

    mask = zeros(200,20);
    mask(winStartStats:winEndStats,:) = statsinter{3};
    mask = mask(winStart:winEnd,:); statsinter{3} = mask;

%% retrieve highest F values




figure,imagesc(ersptimes(winStart:winEnd), erspfreqs,pgroup{1}');  set(gca,'YDir','normal'); 
figure,imagesc(ersptimes(winStart:winEnd), erspfreqs,pgroup{2}');  set(gca,'YDir','normal');


figure,imagesc(ersptimes(winStart:winEnd), erspfreqs,pcond{1}');  set(gca,'YDir','normal'); 
figure,imagesc(ersptimes(winStart:winEnd), erspfreqs,pcond{2}');  set(gca,'YDir','normal');

figure,imagesc(ersptimes(winStart:winEnd), erspfreqs,pinter{1}');  set(gca,'YDir','normal'); 
FvalMax = max(statsinter{1}(find(pinter{1})));
FvalMin = min(statsinter{1}(find(pinter{1})));

figure,imagesc(ersptimes(winStart:winEnd), erspfreqs,pinter{2}');  set(gca,'YDir','normal');
FvalMax = max(statsinter{2}(find(pinter{2})));
FvalMin = min(statsinter{2}(find(pinter{2})));

figure,imagesc(ersptimes(winStart:winEnd), erspfreqs,pinter{3}');  set(gca,'YDir','normal');
FvalInt = max(statsinter{3}(:));

figure;
hold on
plot(statsinter{2})
plot(xlim, [1 1]*8.13, '-r')

figure;
hold on
plot(statsinter{1})
plot(xlim, [1 1]*6.382, '-r')





