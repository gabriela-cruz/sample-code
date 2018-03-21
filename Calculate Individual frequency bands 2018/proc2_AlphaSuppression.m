
% ===================================================================================
% Calculate individual Alpha peak

        % Calculate Individual Frequency Bands usinf IAF at Pz (channel = 15)
        % The bandwidth for the theta, alpha, and beta bands were defined
        % using IAF as anchor point and the Golden Mean, g = 1.618 (Klimesch 2012):
        % "Golden mean frequencies (relative to alpha) allow one to define the
        % frequency separation between frequency domains, as well as the width
        % of each band." (Klimesch 2012, p.8)
        % center frequencies:
        % delta = IAF / 4
        % theta = IAF / 2
        % alpha = IAF
        % beta = IAF * 2
        % gamma = IAF * 4
        
% ===================================================================================      

FilePath = '/Volumes/Data HD/experiments/NF/EEGdata/';

SubID = '01';

% Load PSD Eyes Open and Eyes Closed

load([ FilePath 'S' SubID '/ECdata.mat'])
load([ FilePath 'S' SubID '/EOdata.mat'])

% Substract EO from EC data and plot
channels = [14 15 16 18 19];
channelsName = {'P3' 'Pz' 'P4' 'O1' 'O2'};
ASup = nan(5,length(EC.logPSD));

for i = 1:length(channels)
    
    ASup(i,:) = EC.logPSD(i,:) - EO.logPSD(i,:);
    
    [a b] = max(ASup(i,:));
    
    IAF = EO.Freqs(b);
    
    figure; hold on;
    plot(EO.Freqs,EC.logPSD(i,:),'k');
    plot(EO.Freqs,EO.logPSD(i,:),'color',[0.5 0.5 0.5]);
    legend('Amplitude Eyes Closed','Amplitude Eyes Open');
    plot([IAF IAF], [-10 15],'--','color',[0.5 0.5 0.5]);
    
    title([channelsName{i} ': Alpha Suppression'])
    xlabel('Frequency (Hz)','FontSize',10);
    ylabel('Power 10*log10(µV^2/Hz)','FontSize',10);
    axis([2 30 -10 15])
    
    text(IAF + 1, a + 1 , ['IAF   '  num2str(IAF) ' Hz'])
    print( '-depsc2', [ FilePath 'S' SubID '/AlphaSuppressionAt' channelsName{i}])
    
    if i == 2

        
        g = 1.618; % Golden mean
                
        Cdelta = IAF/4;
        Ctheta = IAF/2;
        Calpha = IAF;
        Cbeta = IAF*2;
        Cgamma = IAF*4;
        
        theta = [Cdelta*g  IAF/g];
        alpha = [Ctheta*g Cbeta/g];
        beta  = [IAF*g Cgamma/g];
        
        axes = axis;
        plot([alpha(1) alpha(1)], [-10 15],'--','color',[0.5 0.5 0.5]);
        plot([alpha(2) alpha(2)], [-10 15],'--','color',[0.5 0.5 0.5]);
        text(alpha(1) - 2, axes(3) + 1 ,  [num2str(alpha(1)) '  Hz'])
        text(alpha(2) +0.5, axes(3) + 1 , [num2str(alpha(2)) '  Hz'])
        print( '-depsc2', [ FilePath 'S' SubID '/AlphaBandAt' channelsName{i}])
        
    end
end

% Save results
IndividualFrequencies.IAF = IAF;
IndividualFrequencies.Cdelta = Cdelta;
IndividualFrequencies.Ctheta = Ctheta;
IndividualFrequencies.Cbeta = Cbeta;
IndividualFrequencies.Cgamma = Cgamma;
IndividualFrequencies.thetaBand = theta;
IndividualFrequencies.alphaBand = alpha;
IndividualFrequencies.betaBand = beta;

save([ FilePath 'S' SubID '/IndividualFrequencies.mat'],'IndividualFrequencies');


