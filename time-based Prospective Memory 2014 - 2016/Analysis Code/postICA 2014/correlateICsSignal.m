%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Components per subject
%%%%%%%%%%%%%%%%%%%%%%%%%%%

SubjsICs{1}  = [1 3 4 5 8 13 14 17]; 
SubjsICs{2}  = [1 2 3 4 5 6 7 8 9 10 12 13 17 18]; 
SubjsICs{3}  = [1 2 3 4 5 6 7 8 11 12 13 15]; 
SubjsICs{4}  = [1 2 6 7 8 10 34]; 
SubjsICs{5}  = [1 2 3 4 5 6 9 12 13 14 20]; 
SubjsICs{6}  = [1 2 3 4 5 6 7 19 24]; 
SubjsICs{7}  = [1 2 3 4 5 6 10 11 12 13 34]; 
SubjsICs{8}  = [1 2 3 7 10 12 13 14 17 18 19 33]; 
SubjsICs{9}  = [1 2 3 4 5 6 7 8 9 10 12 14 32 34]; 
SubjsICs{10} = [1 2 3 4 5 6 7 8 9 10 11 12 14 14 15 16 17 18 20 21 23];
SubjsICs{11} = [1 2 3 4 6 7 8 10 12 14]; 
SubjsICs{12} = [1 2 3 4 5 6 7 8 10 21]; 
SubjsICs{13} = [1 2 3 4 10 12 22 32 34]; %seems it has strong visual component 
SubjsICs{14} = [1 2 3 5 6 7 8 9 10 13 14 15 17 19 27 32]; 
SubjsICs{15} = [1 2 3 4 5 6 7 8 12 13 15 19 25 30 32]; 
SubjsICs{16} = [1 2 3 4 17 27]; 
SubjsICs{17} = [1 2 3 4 11 18 19 20]; 
SubjsICs{18} = [1 2 3 5 6 7 8 9 10 11];
SubjsICs{19} = [1 2 3 4 6 8 9 13]; 
SubjsICs{20} = [2 3 4 5 6 7 8 9 11 13 17 28]; 
SubjsICs{21} = [1 7 8 9 10 14 16 17 18 25];
SubjsICs{22} = [1 2 3 4 5 6 9 14 17];
SubjsICs{23} = [1 2 3 4 5 6 7 8 18]; 
SubjsICs{24} = [1 2 3 4 5 6 7 8 9 10 15 18 19 20 21]; 

%%

AllEvents = {EEG.event.type};
unique(AllEvents)

%%
ICnumb = 5; %select components of interest ICnumb


NbEpochs       = length(EEG.epoch);
TimePointsTag  = zeros(1,NbEpochs*500);
TimePointsData = nan(1,NbEpochs*500); 

EpochCount=0;

datapoints = 125;

for i=1:length(EEG.epoch)% infor for each epoch
    EpochCount = EpochCount + 1;
    beg = (500*EpochCount-1)+1;
    fin = (500*EpochCount-1)+500;
    mid = (500*EpochCount-1)+250;
    
    if strcmp(EEG.epoch(i).eventtype,'DCBL');
        TimePointsTag(beg:fin)  = ones(1,500)*2;
        TimePointsData(1,beg:fin) = EEG.data(ICnumb,:,EpochCount);
    elseif strcmp(EEG.epoch(i).eventtype,'DC');
        TimePointsTag(beg:fin)  = ones(1,500)*0;
        TimePointsData(1,beg:fin) = EEG.data(ICnumb,:,EpochCount);
    elseif strcmp(EEG.epoch(i).eventtype,'TCheck');
        TimePointsTag(beg+datapoints:mid)    = ones(1,datapoints)*-1;
        TimePointsTag(mid+1:fin-datapoints)  = ones(1,datapoints)*1;
        TimePointsData(1,beg:fin)= EEG.data(ICnumb,:,EpochCount);
    end
    
    
end

%r = corr(TimePointsTag,TimePointsData);

P = anova1(TimePointsData,TimePointsTag); 

 [B,BINT,R,RINT,STATS] = regress(TimePointsData',TimePointsTag');








