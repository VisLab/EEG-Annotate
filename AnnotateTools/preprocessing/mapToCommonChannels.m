function [EEG, omittedLabels, nonMappedLabels] = mapToCommonChannels(EEG, baselocs)


chanlocs = EEG.chanlocs;
chanLabels = {chanlocs.labels};
baseLabels = {baselocs.labels};
omittedMask = false(1, length(chanLabels));
urValues = zeros(1, length(baseLabels));
for k = 1:length(chanlocs)
    pos = find(strcmpi(baseLabels, chanLabels{k}));
    if isempty(pos)
        omittedMask(k) = true;
        continue;
    end
    baselocs(pos).urchan = k;
    urValues(pos) = k;
end
omittedLabels = chanLabels(omittedMask);
nonMappedLabels = baseLabels(urValues == 0);
baselocs = baselocs(urValues ~= 0);
urValues = urValues(urValues ~= 0);
EEG.data = EEG.data(urValues, :);
EEG.icawinv = [];
EEG.icaweights = [];
EEG.icasphere = [];
EEG.icachansind = [];
EEG.chanlocs = baselocs;
EEG.nbchan = length(baselocs);