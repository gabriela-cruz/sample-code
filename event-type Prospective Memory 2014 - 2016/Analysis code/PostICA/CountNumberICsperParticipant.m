%% Count number of participants per cluster

% Look in all the other clusters

NumICsPerSubject = nan(length(STUDY.subject),length(STUDY.cluster));

for cl = 3:length(STUDY.cluster) % do not include parent cluster
        
    CountSubj           = unique(STUDY.cluster(1,cl).sets);
    ICsPerSubject       = STUDY.cluster(1,cl).sets;
    
    
    for s = 1:length(CountSubj)
         NumICsPerSubject(CountSubj(s),cl) =  sum(ICsPerSubject(:) == CountSubj(s));    
    end
       
end

TotalICsperSubjectSession = nansum(NumICsPerSubject,2);

E = TotalICsperSubjectSession(2:2:end,:);
O = TotalICsperSubjectSession(1:2:end,:);

TotalICsperSubject = E+O;

min(TotalICsperSubject)
max(TotalICsperSubject)

clear NumICsPerSubject 

% 36 - 150
% 18 - 75
% 18 - 64