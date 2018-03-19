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

%% Get ERP info from file


load('/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/RelvsNonRelvsPM/BckPr_Ch85_RelNRelPM_allCls')
load('/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/BlvsOng/BckPrjStrct.mat')


Rel_ERP_C  = BckPr_Ch85_RelNRelPM_allCls{3,1};
NRel_ERP_C =  BckPr_Ch85_RelNRelPM_allCls{1,1};
PM_ERP_C   =  BckPr_Ch85_RelNRelPM_allCls{2,1};

Rel_ERP_P  = BckPr_Ch85_RelNRelPM_allCls{3,2};
NRel_ERP_P =  BckPr_Ch85_RelNRelPM_allCls{1,2};
PM_ERP_P   =  BckPr_Ch85_RelNRelPM_allCls{2,2};

%time = ALLEEG.times;
time = BackProjStrct.times;

figure; hold on
plot(time(200:450),mean(Rel_ERP_C (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_C (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_C (200:450,:)')','color','k','LineWidth',2); %


figure; hold on
plot(time(200:450),mean(Rel_ERP_P (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_P (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_P (200:450,:)')','color','k','LineWidth',2); %



%% Run stats point by point

% define timerange between 300 and 600 ms
winStart = min(find(-200 < time ));
winEnd   = max(find(time  < 800));

erp11 = Rel_ERP_C(winStart:winEnd,:)';
erp12 = Rel_ERP_P(winStart:winEnd,:)';
erp21 = NRel_ERP_C(winStart:winEnd,:)';
erp22 = NRel_ERP_P(winStart:winEnd,:)';
erp31 = PM_ERP_C(winStart:winEnd,:)';
erp32 = PM_ERP_P(winStart:winEnd,:)';


% run stats with std_stats
% [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
%     std_stat( {erp11' erp12'; erp21' erp22'; erp31' erp32'}, 'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','on','alpha',0.001);%  
% line 136
% opt.paired = {'on' 'on'}
% opt.paired = {'on' 'off'}
% pinter{1} - condition stat
% pinter{2} - group stat
% pinter{3} - intraction

[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat( {erp11' erp12'; erp31' erp32'}, 'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','off','alpha',0.001);%  

RelPM_C = pcond{1};
RelPM_P = pcond{2};


[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat( {erp21' erp22'; erp31' erp32'}, 'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','off','alpha',0.001);%  

NRelPM_C = pcond{1};
NRelPM_P = pcond{2};

% 
% Xf=0:1000;
% figure('Color','w');hold on
% ha=area(time(winStart:winEnd),pinter{2}'*0.3,'LineWidth',1);
% set(ha(1),'FaceColor',[.9 .9 .9],'EdgeColor',[.5 .5 .5]);

timewin = time(winStart:winEnd);

figure; hold on
% indicate significat values
scatter(timewin(find(RelPM_C)),ones(1,length(timewin(find(RelPM_C))))*-0.1,50,'filled','g')
scatter(timewin(find(NRelPM_C)),ones(1,length(timewin(find(NRelPM_C))))*-0.3,50,'filled','r')
% plor ERP
plot(time(200:450),mean(Rel_ERP_C (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_C (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_C (200:450,:)')','color','k','LineWidth',2); %plot([-200,800],[0 0],'k','LineWidth',0.5); 
plot([0,0],[-4 4],'k','LineWidth',0.5); 
plot([-200,1000],[0 0],'k','LineWidth',0.5); 
axis([-200 800 -4 4])
print( '-depsc2', '/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/RelvsNonRelvsPM/RelNRelPM_C_ERP_Ch85_001')



figure; hold on
% indicate significat values
scatter(timewin(find(RelPM_P)),ones(1,length(timewin(find(RelPM_P))))*-0.1,50,'filled','g')
scatter(timewin(find(NRelPM_P)),ones(1,length(timewin(find(NRelPM_P))))*-0.3,50,'filled','r')
% plor ERP
plot(time(200:450),mean(Rel_ERP_P (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_P (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_P (200:450,:)')','color','k','LineWidth',2); %
plot([-200,1000],[0 0],'k','LineWidth',0.5); 
plot([0,0],[-4 4],'k','LineWidth',0.5); 
axis([-200 800 -4 4])
print( '-depsc2', '/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/RelvsNonRelvsPM/RelNRelPM_P_ERP_Ch85_005')
%print( '-depsc2', ['/Users/gabycruz/experiments/EEG_timebased_PM/Figures_TBPM/MPT_figures_010814/erps_dom' num2str(domainNumber)])



%% Get ERP info from file

load('/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/RelvsNonRelvsPM/BckPr_Ch62_RelNRelPM_allCls')


Rel_ERP_C  = BckPr_Ch62_RelNRelPM_allCls{3,1};
NRel_ERP_C =  BckPr_Ch62_RelNRelPM_allCls{1,1};
PM_ERP_C   =  BckPr_Ch62_RelNRelPM_allCls{2,1};

Rel_ERP_P  = BckPr_Ch62_RelNRelPM_allCls{3,2};
NRel_ERP_P =  BckPr_Ch62_RelNRelPM_allCls{1,2};
PM_ERP_P   =  BckPr_Ch62_RelNRelPM_allCls{2,2};

%time = ALLEEG.times;
time = BackProjStrct.times;

figure; hold on
plot(time(200:450),mean(Rel_ERP_C (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_C (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_C (200:450,:)')','color','k','LineWidth',2); %


figure; hold on
plot(time(200:450),mean(Rel_ERP_P (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_P (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_P (200:450,:)')','color','k','LineWidth',2); %



%% Run stats point by point

% define timerange between 300 and 600 ms
winStart = min(find(-200 < time ));
winEnd   = max(find(time  < 800));

erp11 = Rel_ERP_C(winStart:winEnd,:)';
erp12 = Rel_ERP_P(winStart:winEnd,:)';
erp21 = NRel_ERP_C(winStart:winEnd,:)';
erp22 = NRel_ERP_P(winStart:winEnd,:)';
erp31 = PM_ERP_C(winStart:winEnd,:)';
erp32 = PM_ERP_P(winStart:winEnd,:)';


% run stats with std_stats
% [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
%     std_stat( {erp11' erp12'; erp21' erp22'; erp31' erp32'}, 'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','on','alpha',0.001);%  
% line 136
% opt.paired = {'on' 'on'}
% opt.paired = {'on' 'off'}
% pinter{1} - condition stat
% pinter{2} - group stat
% pinter{3} - intraction

[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat( {erp11' erp12'; erp31' erp32'}, 'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','off','alpha',0.001);%  

RelPM_C = pcond{1};
RelPM_P = pcond{2};


[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat( {erp21' erp22'; erp31' erp32'}, 'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','off','alpha',0.001);%  

NRelPM_C = pcond{1};
NRelPM_P = pcond{2};

% 
% Xf=0:1000;
% figure('Color','w');hold on
% ha=area(time(winStart:winEnd),pinter{2}'*0.3,'LineWidth',1);
% set(ha(1),'FaceColor',[.9 .9 .9],'EdgeColor',[.5 .5 .5]);

timewin = time(winStart:winEnd);
figure; hold on
% indicate significat values
scatter(timewin(find(RelPM_C)),ones(1,length(timewin(find(RelPM_C))))*-0.1,50,'filled','g')
scatter(timewin(find(NRelPM_C)),ones(1,length(timewin(find(NRelPM_C))))*-0.3,50,'filled','r')
% plor ERP
plot(time(200:450),mean(Rel_ERP_C (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_C (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_C (200:450,:)')','color','k','LineWidth',2); %plot([-200,800],[0 0],'k','LineWidth',0.5); 
plot([0,0],[-4 4],'k','LineWidth',0.5); 
plot([-200,1000],[0 0],'k','LineWidth',0.5); 
axis([-200 800 -4 4])
print( '-depsc2', '/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/RelvsNonRelvsPM/RelNRelPM_C_ERP_Ch62_001')

figure; hold on
% indicate significat values
scatter(timewin(find(RelPM_P)),ones(1,length(timewin(find(RelPM_P))))*-0.1,50,'filled','g')
scatter(timewin(find(NRelPM_P)),ones(1,length(timewin(find(NRelPM_P))))*-0.3,50,'filled','r')
% plot ERP
plot(time(200:450),mean(Rel_ERP_P (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_P (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_P (200:450,:)')','color','k','LineWidth',2); %
plot([-200,1000],[0 0],'k','LineWidth',0.5); 
plot([0,0],[-4 4],'k','LineWidth',0.5); 
axis([-200 800 -4 4])
print( '-depsc2', '/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/RelvsNonRelvsPM/RelNRelPM_P_ERP_Ch62_001')
%print( '-depsc2', ['/Users/gabycruz/experiments/EEG_timebased_PM/Figures_TBPM/MPT_figures_010814/erps_dom' num2str(domainNumber)])

%%
load('/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/RelvsNonRelvsPM/BckPr_Ch6_RelNRelPM_allCls')


Rel_ERP_C  = BckPr_Ch6_RelNRelPM_allCls{3,1};
NRel_ERP_C =  BckPr_Ch6_RelNRelPM_allCls{1,1};
PM_ERP_C   =  BckPr_Ch6_RelNRelPM_allCls{2,1};

Rel_ERP_P  = BckPr_Ch6_RelNRelPM_allCls{3,2};
NRel_ERP_P =  BckPr_Ch6_RelNRelPM_allCls{1,2};
PM_ERP_P   =  BckPr_Ch6_RelNRelPM_allCls{2,2};

%time = ALLEEG.times;
time = BackProjStrct.times;
figure; hold on
plot(time(200:450),mean(Rel_ERP_C (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_C (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_C (200:450,:)')','color','k','LineWidth',2); %


figure; hold on
plot(time(200:450),mean(Rel_ERP_P (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_P (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_P (200:450,:)')','color','k','LineWidth',2); %



%% Run stats point by point

% define timerange between 300 and 600 ms
winStart = min(find(-200 < time ));
winEnd   = max(find(time  < 800));

erp11 = Rel_ERP_C(winStart:winEnd,:)';
erp12 = Rel_ERP_P(winStart:winEnd,:)';
erp21 = NRel_ERP_C(winStart:winEnd,:)';
erp22 = NRel_ERP_P(winStart:winEnd,:)';
erp31 = PM_ERP_C(winStart:winEnd,:)';
erp32 = PM_ERP_P(winStart:winEnd,:)';


% run stats with std_stats
% [pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
%     std_stat( {erp11' erp12'; erp21' erp22'; erp31' erp32'}, 'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','on','alpha',0.001);%  
% line 136
% opt.paired = {'on' 'on'}
% opt.paired = {'on' 'off'}
% pinter{1} - condition stat
% pinter{2} - group stat
% pinter{3} - intraction

[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat( {erp11' erp12'; erp31' erp32'}, 'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','off','alpha',0.001);%  

RelPM_C = pcond{1};
RelPM_P = pcond{2};


[pcond, pgroup, pinter, statscond, statsgroup, statsinter] = ...
    std_stat( {erp21' erp22'; erp31' erp32'}, 'method','permutation', 'condstats', 'on','mcorrect', 'fdr' , 'groupstats','off','alpha',0.001);%  

NRelPM_C = pcond{1};
NRelPM_P = pcond{2};

% 
% Xf=0:1000;
% figure('Color','w');hold on
% ha=area(time(winStart:winEnd),pinter{2}'*0.3,'LineWidth',1);
% set(ha(1),'FaceColor',[.9 .9 .9],'EdgeColor',[.5 .5 .5]);

figure; hold on
% indicate significat values
scatter(timewin(find(RelPM_C)),ones(1,length(timewin(find(RelPM_C))))*-0.1,50,'filled','g')
scatter(timewin(find(NRelPM_C)),ones(1,length(timewin(find(NRelPM_C))))*-0.3,50,'filled','r')
% plor ERP
plot(time(200:450),mean(Rel_ERP_C (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_C (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_C (200:450,:)')','color','k','LineWidth',2); %plot([-200,800],[0 0],'k','LineWidth',0.5); 
plot([0,0],[-4 4],'k','LineWidth',0.5); 
plot([-200,1000],[0 0],'k','LineWidth',0.5); 
axis([-200 800 -4 4])
print( '-depsc2', '/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/RelvsNonRelvsPM/RelNRelPM_C_ERP_Ch6_001')

figure; hold on
% indicate significat values
scatter(timewin(find(RelPM_P)),ones(1,length(timewin(find(RelPM_P))))*-0.1,50,'filled','g')
scatter(timewin(find(NRelPM_P)),ones(1,length(timewin(find(NRelPM_P))))*-0.3,50,'filled','r')
% plot ERP
plot(time(200:450),mean(Rel_ERP_P (200:450,:)'),'--','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(NRel_ERP_P (200:450,:)')','color',[0.5 0.5 0.5],'LineWidth',2); %
plot(time(200:450),mean(PM_ERP_P (200:450,:)')','color','k','LineWidth',2); %
plot([-200,1000],[0 0],'k','LineWidth',0.5); 
plot([0,0],[-4 4],'k','LineWidth',0.5); 
axis([-200 800 -4 4])
print( '-depsc2', '/Users/gabycruz/experiments/EEG_eventbased_PM/backProjData_EBPM/RelvsNonRelvsPM/RelNRelPM_P_ERP_Ch6_001')


%% code to shade area


% shade significant area
% B = bar(time(winStart:winEnd),RelPM_C'*4,'edgecolor','none','FaceColor',[.3 .3 .3]); ch = get(B,'child'); set(ch,'facea',.2);%set(ch,'edgea',.2)
% B = bar(time(winStart:winEnd),RelPM_C'*-4,'edgecolor','none','FaceColor',[.3 .3 .3]); ch = get(B,'child'); set(ch,'facea',.2);%set(ch,'edgea',.2)
% B = bar(time(winStart:winEnd),NRelPM_C'*4,'edgecolor','none','FaceColor',[.5 .5 .5]); ch = get(B,'child'); set(ch,'facea',.2);%set(ch,'edgea',.2)
% B = bar(time(winStart:winEnd),NRelPM_C'*-4,'edgecolor','none','FaceColor',[.5 .5 .5]); ch = get(B,'child'); set(ch,'facea',.2);%set(ch,'edgea',.2)

% shade significant area
% bar(time(winStart:winEnd),RelPM_C'*4,'edgecolor','none','FaceColor',[.3 .3 .3]); %ch = get(B,'child'); set(ch,'facea',.2);%set(ch,'edgea',.2)
% bar(time(winStart:winEnd),RelPM_C'*-4,'edgecolor','none','FaceColor',[.3 .3 .3]); %ch = get(B,'child'); set(ch,'facea',.2);%set(ch,'edgea',.2)
% bar(time(winStart:winEnd),NRelPM_C'*4,'edgecolor','none','FaceColor',[.5 .5 .5]); %ch = get(B,'child'); set(ch,'facea',.2);%set(ch,'edgea',.2)
% bar(time(winStart:winEnd),NRelPM_C'*-4,'edgecolor','none','FaceColor',[.5 .5 .5]); %ch = get(B,'child'); set(ch,'facea',.2);%set(ch,'edgea',.2)

