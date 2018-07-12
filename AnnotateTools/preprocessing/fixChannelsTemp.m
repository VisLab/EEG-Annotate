%function EEG = fixBaseChannelLocations(EEG, baseLocs)


%%
% chanlocs = EEG.chanlocs;
% theseLabels = {chanlocs.labels};
% baseLabels = {baseLocs.labels};
% baseMask = zeros(1, length(chanlocs));
% 
% for k = 1:length(baseMask)
%     thisLoc =  find(strcmpi(baseLabels, theseLabels{k})
% 
%     
% 
%     

%%
test = load('baseChannelLocs.mat');
baseChannelLocs = test.baseChannelLocs;
for k = 1:length(baseChannelLocs)
    baseChannelLocs(k).urchan = 0;
end
%%
save('baseChannelLocs.mat', 'baseChannelLocs', '-v7.3');