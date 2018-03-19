% Plot ERP for all conditions

ChanName = {'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'E10' 'E11' 'E12' 'E13'...
    'E14' 'E15' 'E16' 'E17' 'E18' 'E19' 'E20' 'E21' 'E22' 'E23' 'E24'...
    'E25' 'E26' 'E27' 'E28' 'E29' 'E30' 'E31' 'E32' 'E33' 'E34' 'E35'...
    'E36' 'E37' 'E38' 'E39' 'E40' 'E41' 'E42' 'E43' 'E44' 'E45' 'E46'...
    'E47' 'E48' 'E49' 'E50' 'E51' 'E52' 'E53' 'E54' 'E55' 'E56' 'E57'...
    'E58' 'E59' 'E60' 'E61' 'E62' 'E63' 'E64' 'E65' 'E66' 'E67' 'E68'...
    'E69' 'E70' 'E71' 'E72' 'E73' 'E74' 'E75' 'E76' 'E77' 'E78' 'E79'...
    'E80' 'E81' 'E82' 'E83' 'E84' 'E85' 'E86' 'E87' 'E88' 'E89' 'E90'...
    'E91' 'E92' 'E93' 'E94' 'E95' 'E96' 'E97' 'E98' 'E99' 'E100' 'E101'...
    'E102' 'E103' 'E104' 'E105' 'E106' 'E107' 'E108' 'E109' 'E110' 'E111'...
    'E112' 'E113' 'E114' 'E115' 'E116' 'E117' 'E118' 'E119' 'E120' 'E121'...
    'E122' 'E123' 'E124' 'E125' 'E126' 'E127' 'E128'};

ChanERPdata = cell(5,2);

ERPlabels = {'UnrO+PM Concep' 'UnrOng Concep' 'PM Concep' 'RelO+PM Concep' 'RelOng Concep ' ;'UnrO+PM Percep' 'UnrOng Percep' 'PM Percep' 'RelO+PM Percep' 'RelOng Percep '}';

for chan = 1:length(STUDY.changrp)
    % Obtain ERP data per channel
    [STUDY erpdata erptimes] = std_erpplot(STUDY,ALLEEG,'channels',{ChanName{chan}},'noplot','on');
    
    for Session = 1:size(erpdata,2)
        for Condition = 1:size(erpdata,1);
            ChanERPdata{Condition,Session}(chan,:) = mean(erpdata{Condition,Session},2);
        end
    end
    
end

% plot all Sessions & conditions

for Session = 1:size(erpdata,2)
    for Condition = 1:size(erpdata,1);
        figure; hold on
        plot(erptimes,ChanERPdata{Condition,Session}');
        title(ERPlabels(Condition,Session) )
        axis([-200 800 -4 4])
        line([0,0],xlim,'color','k','LineWidth',.5)
        line(xlim,[0 0],'color','k','LineWidth',1)
        print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{Condition,Session}])

    end
end


% Calculate differences and plot

% Monitoring Effect
tmpERP = ChanERPdata{4,1} - ChanERPdata{5,1};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(4,1) ' minus ' ERPlabels(5,1) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{4,1} ' minus ' ERPlabels{5,1}])

tmpERP = ChanERPdata{4,2} - ChanERPdata{5,2};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(4,2) ' minus ' ERPlabels(5,2) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{4,2} ' minus ' ERPlabels{5,2}])


tmpERP = ChanERPdata{1,1} - ChanERPdata{2,1};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(1,1) ' minus ' ERPlabels(2,1) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{1,1} ' minus ' ERPlabels{2,1}])


tmpERP = ChanERPdata{1,2} - ChanERPdata{2,2};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(1,2) ' minus ' ERPlabels(2,2) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{1,2} ' minus ' ERPlabels{2,2}])


% PM effect
tmpERP = ChanERPdata{3,1} - ChanERPdata{4,1};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(3,1) ' minus ' ERPlabels(4,1) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{3,1} ' minus ' ERPlabels{4,1}])

tmpERP = ChanERPdata{3,2} - ChanERPdata{4,2};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(3,2) ' minus ' ERPlabels(4,2) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{3,2} ' minus ' ERPlabels{4,2}])

tmpERP = ChanERPdata{3,1} - ChanERPdata{1,1};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(3,1) ' minus ' ERPlabels(1,1) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{3,1} ' minus ' ERPlabels{1,1}])

tmpERP = ChanERPdata{3,2} - ChanERPdata{1,2};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(3,2) ' minus ' ERPlabels(1,2) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{3,2} ' minus ' ERPlabels{1,2}])


% average Ongoing BL Con

tmpERP1 = (ChanERPdata{2,1} + ChanERPdata{5,1})/2;
figure; plot(erptimes,tmpERP')

tmpERP2 = (ChanERPdata{1,1} + ChanERPdata{4,1})/2;
figure; plot(erptimes,tmpERP')


DiffERP = tmpERP2 - tmpERP1;
figure; plot(erptimes,DiffERP')


% average Ongoing BL Perc

tmpERP1 = (ChanERPdata{2,2} + ChanERPdata{5,2})/2;
figure; plot(erptimes,tmpERP')

tmpERP2 = (ChanERPdata{1,2} + ChanERPdata{4,2})/2;
figure; plot(erptimes,tmpERP')


DiffERP = tmpERP2 - tmpERP1;
figure; plot(erptimes,DiffERP')



% average Ongoing PM Con

tmpERP1 = (ChanERPdata{1,1} + ChanERPdata{4,1})/2;
figure; plot(erptimes,tmpERP')

DiffERP = ChanERPdata{3,1} - tmpERP1;
figure; plot(erptimes,DiffERP')


% average Ongoing PM Perc

tmpERP1 = (ChanERPdata{1,2} + ChanERPdata{4,2})/2;
figure; plot(erptimes,tmpERP')

DiffERP = ChanERPdata{3,2} - tmpERP1;
figure; plot(erptimes,DiffERP')


% Related versus Unrelated
tmpERP = ChanERPdata{5,1} - ChanERPdata{2,1};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(5,1) ' minus ' ERPlabels(2,1) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{5,1} ' minus ' ERPlabels{2,1}])


tmpERP = ChanERPdata{5,2} - ChanERPdata{2,2};
figure; plot(erptimes,tmpERP')
axis([-200 800 -4 4])
line([0,0],xlim,'color','k','LineWidth',.5)
line(xlim,[0 0],'color','k','LineWidth',1)
title([ERPlabels(5,2) ' minus ' ERPlabels(2,2) ] )
print( '-depsc2',[ '/Users/gabycruz/experiments/EEG_eventbased_PM/CleanDataStudy/ERPfigs/Condition' ERPlabels{5,2} ' minus ' ERPlabels{2,2}])




title(' Perceptual PM - Related')





axis([-200 800 -4 3])

a =  ChanERPdata{1,1};

plot(a')

% Plotchannel ERP per condition

% Create cell array Condition x session




for chan = 1:length(STUDY.changrp)
        
    tmpData = STUDY.changrp(1,chan).erpdata; %
    
    for Session = 1:size(ChanERPdata,2)
        for Condition = 1:size(ChanERPdata,1);
            ChanERPdata{Condition,Session}(chan,:) = mean(tmpData{Condition,Session},2)'; 
        end
    end
end

figure; plot(ChanERPdata{1,1})




figure; plot(ChanERPdata{1,2})


figure; plot(ChanERPdata{1,2})

% 
% % use chanlocs structure of subject number 50, who has the all 128 channels
% chan_locs = EEG(1,50).chanlocs;
% data = ALLEEG(1,50).data;
% 
% timtopo(data,chan_locs);
% 
% 
% 
% figure; pop_timtopo(EEG, [-200  800], [180  300  400  600],...
%     'ERP data and scalp maps of S3_P_AMICA_cleanJointProbComp pruned with ICA');
% 
% a = EEG.times;
% 
% erpList = zeros(length(ALLEEG),length(a));
% 
% 
% for subj = 1:length(ALLEEG)
%     erpList(subj,:) = mean(ALLEEG(1,subj).data(:,:,:),3);
% end
% figure; plot(mean(erpList)')
% 
% 
% timtopo(data,'chan_locs');
% 
% 
% b = mean(ALLEEG(1,subj).data(:,:,:),3);
% 
% 
% 


% STUDY = std_erpplot(STUDY,ALLEEG,'channels',...
%     {'E1' 'E2' 'E3' 'E4' 'E5' 'E6' 'E7' 'E8' 'E9' 'E10' 'E11' 'E12' 'E13'...
%     'E14' 'E15' 'E16' 'E17' 'E18' 'E19' 'E20' 'E21' 'E22' 'E23' 'E24'...
%     'E25' 'E26' 'E27' 'E28' 'E29' 'E30' 'E31' 'E32' 'E33' 'E34' 'E35'...
%     'E36' 'E37' 'E38' 'E39' 'E40' 'E41' 'E42' 'E43' 'E44' 'E45' 'E46'...
%     'E47' 'E48' 'E49' 'E50' 'E51' 'E52' 'E53' 'E54' 'E55' 'E56' 'E57'...
%     'E58' 'E59' 'E60' 'E61' 'E62' 'E63' 'E64' 'E65' 'E66' 'E67' 'E68'...
%     'E69' 'E70' 'E71' 'E72' 'E73' 'E74' 'E75' 'E76' 'E77' 'E78' 'E79'...
%     'E80' 'E81' 'E82' 'E83' 'E84' 'E85' 'E86' 'E87' 'E88' 'E89' 'E90'...
%     'E91' 'E92' 'E93' 'E94' 'E95' 'E96' 'E97' 'E98' 'E99' 'E100' 'E101'...
%     'E102' 'E103' 'E104' 'E105' 'E106' 'E107' 'E108' 'E109' 'E110' 'E111'...
%     'E112' 'E113' 'E114' 'E115' 'E116' 'E117' 'E118' 'E119' 'E120' 'E121'...
%     'E122' 'E123' 'E124' 'E125' 'E126' 'E127' 'E128'});

[STUDY erpdata erptimes] = std_erpplot(STUDY,ALLEEG,'channels',{'E62'},'noplot','off');
for Session = 1:size(ChanERPdata,2)
    for Condition = 1:size(ChanERPdata,1);
        plot(erptimes,mean(erpdata{Condition,Session},2)');
        axis([-200 800 -2 5])
        title(['Condition ' num2str(Condition) ' Session ' num2str(Session) ])
    end
end
