%% create colours
colors = distinguishable_colors(60);
SelectedColours = [2 11 29 5 42 12 7 3 21];
colors = colors(SelectedColours,:);

controlColor(1,:) = [255/255 153/255 153/255];
controlColor(2,:) = [102/255 178/255 255/255];
controlColor(3,:) = [255/255 255/255 102/255];
controlColor(4,:) = [255/255 153/255 255/255];
controlColor(5,:) = [255/255 178/255 102/255];
controlColor(6,:) = [102/255 102/255 255/255];
controlColor(7,:) = [102/255 204/255 0/255];
controlColor(8,:) = [102/255 255/255 102/255];
controlColor(9,:) = [255/255 204/255 153/255];

%% Get ERP info from domain

    
    
domainNumber = 1;

dipoleAndMeasure = STUDY.measureProjection.erp.object; % get the ERP and dipole data (dataAndMeasure object) from the STUDY structure.
domain           = STUDY.measureProjection.erp.projection.domain(domainNumber); % get the domain in a separate variable
projection       = STUDY.measureProjection.erp.projection;
headGrid         = STUDY.measureProjection.ersp.headGrid;

[linearProjectedMeasure sessionConditionCell groupId uniqeDatasetId dipoleDensity]...
    = dipoleAndMeasure.getMeanProjectedMeasureForEachSession(headGrid, domain.membershipCube, projection.projectionParameter);

% create vectors with ERP info

RelatedControlERP   = zeros(24,750);
UnrelatedControlERP = zeros(24,750);
RelatedPMERP        = zeros(24,750);
UnrelatedPMERP      = zeros(24,750);
%TimechecksERP       = zeros(24,750);


for i = 1:size(RelatedControlERP,1)
    UnrelatedControlERP(i,:) = sessionConditionCell{i,1};
    UnrelatedPMERP(i,:)      = sessionConditionCell{i,2};
    RelatedControlERP(i,:)   = sessionConditionCell{i,3};
    %TimechecksERP(i,:)       = sessionConditionCell{i,4};
    RelatedPMERP(i,:)        = sessionConditionCell{i,4};
end

% plot ERP

ERPdomColors = [1 2 9 4 3 6]; % domains' colours
DomainColourPM   = colors(ERPdomColors(domainNumber),:);
DomainColourCtrl = controlColor(ERPdomColors(domainNumber),:);

time = ALLEEG.times;

figure; hold on
plot(time(200:500),mean(RelatedControlERP(:,200:500)),'--','color',DomainColourCtrl,'LineWidth',2); %
plot(time(200:500),mean(UnrelatedControlERP(:,200:500)),'color',DomainColourCtrl,'LineWidth',2); %
plot(time(200:500),mean(RelatedPMERP(:,200:500)),'--','LineWidth',2,'color',DomainColourPM); %
plot(time(200:500),mean(UnrelatedPMERP(:,200:500)),'LineWidth',2,'color',DomainColourPM); %
alpha(1);
v = axis;
axis([-200 1000 -0.5 0.5])

%% Run stats point by point

% define timerange  
winStart = min(find(0 < time )); timestatsStar = winStart;
winEnd   = max(find(time  <= 800)); timestatsEnd = winEnd;

erp11 = RelatedControlERP(:,winStart:winEnd);
erp12 = RelatedPMERP(:,winStart:winEnd);
erp21 = UnrelatedControlERP(:,winStart:winEnd);
erp22 = UnrelatedPMERP(:,winStart:winEnd);

% run stats with std_stats
[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat( {erp11' erp12'; erp21' erp22'},...
    'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','on','alpha',0.05,'paired',{'on' 'on'});%  


% pinter{1} - condition stat
% pinter{2} - group stat
% pinter{3} - intraction

%% Plot Event Type effect (group pooled)

% define timerange to plot  
winStart = min(find(-200 < time ));
winEnd   = max(find(time  <= 800));

erp11 = RelatedControlERP(:,winStart:winEnd);
erp12 = RelatedPMERP(:,winStart:winEnd);
erp21 = UnrelatedControlERP(:,winStart:winEnd);
erp22 = UnrelatedPMERP(:,winStart:winEnd);
PlotTime =  time(winStart:winEnd);
StatsTime =  time(timestatsStar:timestatsEnd);
colour = {'k','r'};
line = {'-','--'};

figure; hold on
axis([-200 800 -0.5 0.5]); a = axis;
plot(PlotTime,mean([erp11 ; erp12]),line{1},'color',colour{1}); %Related
plot(PlotTime,mean([erp21 ; erp22]),line{2},'color',colour{1}); %Unrelated
scatter(StatsTime(find(pinter{1})),ones(1,length(StatsTime(find(pinter{1}))))*(a(3)+0.1),30,'filled','MarkerFaceColor',colour{1});

FvalMax = max(statsinter{1}(find(pinter{1})));
FvalMin = min(statsinter{1}(find(pinter{1})));


figure;
hold on
plot(statsinter{1})
plot(xlim, [1 1]*FvalMin, '-r')
axis([0 200 0 15])

%% plot task condition effect (event type pooled)

figure; hold on
axis([-200 800 -0.5 0.5]);
plot(PlotTime,mean([erp11 ; erp21]),line{1},'color',colour{1}); % Ongoing Only
plot(PlotTime,mean([erp12 ; erp22]),line{1},'color',colour{2}); % Ongoing PM
scatter(StatsTime(find(pinter{2})),ones(1,length(StatsTime(find(pinter{2}))))*(a(3)+0.1),30,'filled','MarkerFaceColor',colour{2});

FvalMax = max(statsinter{2}(find(pinter{2})));
FvalMin = min(statsinter{2}(find(pinter{2})));

figure;
hold on
plot(statsinter{2})
plot(xlim, [1 1]*FvalMin, '-r')



% Interaction
figure; hold on
scatter(PlotTime(find(pinter{3})),ones(1,length(PlotTime(find(pinter{3}))))*(a(3)+0.1),30,'filled','MarkerFaceColor',colour{2});
FvalInt = max(statsinter{3});

%% Run statistics by Group

% define timerange   for stats
winStart = min(find(0 < time )); timestatsStar = winStart;
winEnd   = max(find(time  <= 800)); timestatsEnd = winEnd;

% ========================
OvertheMedianPerformers = [ 2 14 12 13 5 23 24 15 16 11 3 19];
% ========================

erp11AMP = RelatedControlERP(OvertheMedianPerformers,winStart:winEnd); %OO
erp12AMP = RelatedPMERP(OvertheMedianPerformers,winStart:winEnd); % OPM
erp21AMP = UnrelatedControlERP(OvertheMedianPerformers,winStart:winEnd); %OO
erp22AMP = UnrelatedPMERP(OvertheMedianPerformers,winStart:winEnd); %OPM

% ========================
BelowtheMedianPerformers = [17 8 21 20 18 6 9 10 1 22 7 4 ]; 
% ========================

erp11BMP = RelatedControlERP(BelowtheMedianPerformers,winStart:winEnd); %OO
erp12BMP = RelatedPMERP(BelowtheMedianPerformers,winStart:winEnd); %OPM
erp21BMP = UnrelatedControlERP(BelowtheMedianPerformers,winStart:winEnd); %OO
erp22BMP = UnrelatedPMERP(BelowtheMedianPerformers,winStart:winEnd); %OPM

erp11 = [erp11BMP ; erp21BMP]; % OO Below median
erp12 = [erp11AMP ; erp21AMP]; % OO Above median
erp21 = [erp12BMP ; erp22BMP]; % PM Below median
erp22 = [erp12AMP ; erp22AMP]; % PM Above median

% stats
[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat( {erp11' erp12'; erp21' erp22'},...
    'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','on','alpha',0.05,'paired',{'on' 'on'});%  


%% Plot task condition effect (group pooled)

% define timerange to plot  
winStart = min(find(-200 < time ));
winEnd   = max(find(time  <= 800));


PlotTime =  time(winStart:winEnd);
colour = {'k','r'};
line = {'-','--'};

figure; hold on
axis([-200 800 -0.5 0.5]); a = axis;
plot(PlotTime,mean([erp11 ; erp12]),line{1},'color',colour{1}); % Onoing Only
plot(PlotTime,mean([erp21 ; erp22]),line{2},'color',colour{1}); % Ongoing Only
scatter(StatsTime(find(pinter{1})),ones(1,length(StatsTime(find(pinter{1}))))*(a(3)+0.1),30,'filled','MarkerFaceColor',colour{1});

FvalMax = max(statsinter{1}(find(pinter{1})));
FvalMin = min(statsinter{1}(find(pinter{1})));


%% plot group effect (event type pooled)

figure; hold on
axis([-200 800 -0.5 0.5]);
plot(PlotTime,mean([erp11 ; erp21]),line{1},'color',colour{1}); % Below Median
plot(PlotTime,mean([erp12 ; erp22]),line{1},'color',colour{2}); % Above median
scatter(StatsTime(find(pinter{2})),ones(1,length(StatsTime(find(pinter{2}))))*(a(3)+0.1),30,'filled','MarkerFaceColor',colour{2});



FvalTcond = max(statsinter{2}(find(pinter{2})));
FvalInt = max(statsinter{2});

% Interaction
figure; hold on
scatter(PlotTime(find(pinter{3})),ones(1,length(PlotTime(find(pinter{3}))))*(a(3)+0.1),30,'filled','MarkerFaceColor',colour{2});
FvalInt = max(statsinter{3});
%%


% 
% Xf=0:1000;
% figure('Color','w');hold on
% ha=area(time(winStart:winEnd),pinter{2}'*0.3,'LineWidth',1);
% set(ha(1),'FaceColor',[.9 .9 .9],'EdgeColor',[.5 .5 .5]);

figure; hold on
% shade significant area
bar(time(winStart:winEnd),pinter{2}'*0.49,'edgecolor',[.9 .9 .9],'FaceColor',[.9 .9 .9]);
bar(time(winStart:winEnd),pinter{2}'*-0.49,'edgecolor',[.9 .9 .9],'FaceColor',[.9 .9 .9]);

plot(time(200:500),mean(RelatedControlERP(:,200:500)),'--','color',DomainColourCtrl,'LineWidth',2); %
plot(time(200:500),mean(UnrelatedControlERP(:,200:500)),'color',DomainColourCtrl,'LineWidth',2); %
plot(time(200:500),mean(RelatedPMERP(:,200:500)),'--','LineWidth',2,'color',DomainColourPM); %
plot(time(200:500),mean(UnrelatedPMERP(:,200:500)),'LineWidth',2,'color',DomainColourPM); %

plot([-200,1000],[0 0],'k','LineWidth',0.5); 

axis([-200 1000 -0.5 0.5])

print( '-depsc2', ['/Users/gabycruz/experiments/EEG_timebased_PM/Figures_TBPM/MPT_figures_010814/erps_dom' num2str(domainNumber)])


%% Run stats average window
% 
% erpdataAll = cell(2,2);
% erpdataAll(1,1) = {mean(RelatedControlERP)};
% erpdataAll(2,1) = {mean(UnrelatedControlERP)};
% erpdataAll(1,2) = {mean(RelatedPMERP)};
% erpdataAll(2,2) = {mean(UnrelatedPMERP)};
% 
% % define timerange between 300 and 600 ms
% winStart = min(find(300 < time ));
% winEnd   = max(find(time  < 600));
% 
% erp11 = erpdataAll{1,1}(:,winStart:winEnd);
% erp12 = erpdataAll{1,2}(:,winStart:winEnd);
% erp21 = erpdataAll{2,1}(:,winStart:winEnd);
% erp22 = erpdataAll{2,2}(:,winStart:winEnd);
% 
% 
% % run stats with std_stats
% [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
%     std_stat( {erp11 erp12; erp21 erp22}, 'method', 'parametric', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','on','alpha',0.05);%  
% % line 136
% % opt.paired = {'on' 'on'}
% 
% 
% % oneway post-hoc
% [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
%     std_stat( {erp11 erp12}, 'method', 'parametric', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','on','alpha',0.05);%  
% 
% [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
%     std_stat( {erp11 erp12; erp21 erp22}, 'method', 'parametric', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','on','alpha',0.05);%  
% 
% 
% 
% %%
% 
% 
% 
% % run stats
% [stats, df, pvals, surrog] = statcond({erp11 erp12; erp21 erp22},'method', 'perm',  'naccu', 2000, 'paired','on');
% 
% 
% 
% % statistics
% MeanErp11 = mean(erpdataAll{1,1}(:,winStart:winEnd));
% MeanErp12 = mean(erpdataAll{1,2}(:,winStart:winEnd));
% MeanErp21 = mean(erpdataAll{2,1}(:,winStart:winEnd));
% MeanErp22 = mean(erpdataAll{2,2}(:,winStart:winEnd));
% 
% 
% 
% 
% title(['Domain ' num2str(domainNumber)])