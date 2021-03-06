function defaults = getAnnotateDefaults()
% Returns the defaults for annotation
%
% Parameters:
%
%     defaults     a structure with the parameters for the default types
%                  in the form of a structure that has fields
%                     value: default value
%                     classes:   classes that the parameter belongs to
%                     attributes:  attributes of the parameter
%                     description: description of parameter
%

defaults = struct( ...
    'AnnotateBadTrainFiles', ...
    getRules({}, {'char', 'cell'}, {}, ...
    'Cell array specifying training files to exclude.'), ...
    'AnnotateUseAdapativeShift', ...
    getRules(true, {'logical'}, {}, ...
    'If true, use an adaptive cutoff to shift individual training sets.'), ...
    'AnnotateUseAdaptiveCombine', ...
    getRules(true, {'logical'}, {}, ...
    'If true, use adaptive cutoff to determine label of combined score.'), ...
    'AnnotateRescaleBeforeCombine', ...
    getRules(true, {'logical'}, {}, ...
    'If true, rescale training scores before combining.'), ...
    'AnnotateWeights', ...
    getRules([0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5], ...
    {'numeric'}, {'row', 'positive'}, ... 
    'Vector of weights for combining the combined scores.'), ...
    'ARRLSBalanceTrain', ...
    getRules(false, {'logical'}, {}, ...
    'If true, balance the training set using oversampling of minority.'), ...
    'ARRLSGamma', ...
    getRules(1.0, {'numeric'}, ...
    {'positive', 'scalar'}, ...
    'Coefficient multiplying manifold consistency term in loss function.'), ...
    'ARRLSKernel', ...
    getRules('linear', {'char'}, {}, ...
    'Type of kernel used for kernel trick --- currently only linear'), ...
    'ARRLSLambda', ...
    getRules(10, {'numeric'}, ...
    {'positive', 'scalar'}, ...
    'Coefficient multiplying the joint distribution term in loss function.'), ...
    'ARRLSP', ...
    getRules(10, {'numeric'}, ...
    {'positive', 'scalar'}, ...
    'Number of neighbors to use for manifold consistency.'), ...
    'ARRLSSigma', ...
    getRules(0.1, {'numeric'}, ...
    {'positive', 'scalar'}, ...
    'Coefficient for L2 regularization in loss function.'), ...
    'ARRLSimbAdaptiveCutoff', ...
    getRules(true, {'logical'}, {}, ...
    'If true, use fitting to leftovers Gaussian to determine class cutoff.'), ...
    'ARRLSimbBalancePseudoTrain', ...
    getRules(false, {'logical'}, {}, ...
    ['If true, balance the training set for computing initial pseudo ' ...
    'labels using oversampling of minority.']), ...
    'ARRLSimbRiskReweighting', ...
    getRules(true, {'logical'}, {}, ...
    'Use reweighting in risk term to account for unbalanced class data'), ...
    'ARRLSimbClassReweighting', ...
    getRules(true, {'logical'}, {}, ...
    'Use class reweighting to account for unbalanced class data'), ...    
    'ARRLSimbManifoldReweighting', ...
    getRules(true, {'logical'}, {}, ...
    'Use manifold reweighting of graph LaPlacian to account for unbalanced class data'), ...    'ARRLSimbW3', ...
    'featureExcludedChannels', ...
    getRules({}, {'cell'}, {}, ...
    'Cell array of channel labels of channels to explicitly exclude.'), ...    
    'featureExcludeNonEEGChannels', ...
    getRules(true, {'logical'}, {}, ...
    'If true exclude channels whose type is not ''EEG''.'), ... 
    'featureExcludeNonLocatedChannels', ...
    getRules(true, {'logical'}, {}, ...
    'If true exclude channels that do not have channel locations.'), ...    
    'featurePowerSubbands', ...
    getRules([0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32], ...
    {'numeric'}, {'2d', 'nonempty', 'ncols', 2}, ...
    'B x 2 array of the B frequency bands that form the features.'), ...
    'featureSubWindowLength', ...
    getRules(0.125, {'numeric'}, ...
    {'nonnegative'}, ...
    'Subwindow length in seconds.'), ...   
    'featureWindowLength', ...
    getRules(1, {'numeric'}, ...
    {'nonnegative'}, ...
    'Window length in seconds.'), ...
    'featureWindowStep', ...
    getRules(0.125, {'numeric'}, ...
    {'nonnegative'}, ...
    'Window slide length in seconds (multiple of subwindow size).'), ...    
    'LDADiscrimType', ...
    getRules('linear', {'char'}, {}, ...
    ['Type of discriminant analysis: ' ...
    'linear (default), quadratic, diagLinear, diagLinear, ' ...
    'pseudoLinear, pseudoQuadratic.']), ...
    'LDAObj', ...
    getRules([], {'numeric','ClassificationDiscriminant'}, ...
    {}, ...
    'Discriminant object containing trained classifier'), ...
    'LDAPrior', ...
    getRules('empirical', {'char'}, {}, ...
    ['Prior probabilities for each class: ' ...
    'empirical (default), uniform']), ...
    'balanceTrain', ...
    getRules(true, {'logical'}, {}, ...
    'If true, balance the training set using oversampling of minority.'), ...
    'pseudoLabels', ...
    getRules([], {'numeric'}, {}, ...
    'Vector of 0 and 1 giving initial guesses of pseudo labels for target set.'), ...
    'rerankPositive', ...
    getRules(false, {'logical'}, {}, ...
    'If true, do reranking classification samples annotated positive in training only.'), ...
    'reportTimingTolerances', ...
    getRules(0:5, {'numeric'}, ...
    {'row', 'nonnegative', 'integer'}, ...
    'Vector of subwindow timing tolerances for computing validation.'), ...
    'saveTrain', ...
    getRules(true, {'logical'}, {}, ...
    'If true, save the training scores and labels.'), ...
    'saveTrainScore', ...
    getRules(true, {'logical'}, {}, ...
    'If true, save the training scores and labels.'), ...
    'verbose', ...
    getRules(true, {'logical'}, {}, ...
    'If true, output progress messages during classification.'), ...
    'wingBaseThreshold', ...
    getRules(0, {'numeric'}, {'nonnegative', 'scalar'}, ...
    'Lowest score to display in wing plot.'), ...
    'wingPlotSize', ...
    getRules(33, {'numeric'}, {'nonnegative', 'integer', 'scalar', 'odd'}, ...
    'Width of wing plot in subwindows - should be an odd integer.'), ...
    'wingRankCutoff', ...
    getRules(1, {'numeric'}, {'nonnegative', 'scalar'}, ...
    'Rank scores should be greater than or equal to this number.'), ...
    'wingSubwindowTolerance', ...
    getRules(2, {'numeric'}, {'nonnegative', 'integer', 'scalar'}, ...
    'Timing tolerance for determining labels in plot true in wings.') ...
    );
%         'samples', ...
%         getRules(size(signal.data, 2), {'numeric'}, ...
%         {'positive', 'scalar'}, ...
%         'Number of frames to use for computation.'), ...
%         'robustDeviationThreshold', ...
%         getRules(5, {'numeric'}, ...
%         {'positive', 'scalar'}, ...
%         'Z-score cutoff for robust channel deviation.'), ...
%         'highFrequencyNoiseThreshold', ...
%         getRules(5, {'numeric'}, ...
%         {'positive', 'scalar'}, ...
%         'Z-score cutoff for SNR (signal above 50 Hz).'), ...
%         'correlationWindowSeconds', ...
%         getRules(1, {'numeric'}, ...
%         {'positive', 'scalar'}, ...
%         'Correlation window size in seconds.'), ...
%         'correlationThreshold', ...
%         getRules(0.4, {'numeric'}, ...
%         {'positive', 'scalar', '<=', 1}, ...
%         'Max correlation threshold for channel being bad in a window.'), ...
%         'badTimeThreshold', ...
%         getRules(0.01, {'numeric'}, ...
%         {'positive', 'scalar'}, ...
%         ['Threshold fraction of bad correlation windows '...
%         'for designating channel to be bad.']), ...
%         'ransacOff', ...
%         getRules(false, {'logical'}, {}, ...
%         ['If true, RANSAC is not used for bad channel ' ...
%         '(useful for small headsets).']), ...
%         'ransacSampleSize', ...
%         getRules(50, {'numeric'}, ...
%         {'positive', 'scalar', 'integer'}, ...
%         'Number of sample matrices for computing ransac.'), ...
%         'ransacChannelFraction', ...
%         getRules(0.25, {'numeric'}, ...
%         {'positive', 'scalar', '<=', 1}, ...
%         'Fraction of evaluation channels RANSAC uses to predict a channel.'), ...
%         'ransacCorrelationThreshold', ...
%         getRules(0.75, {'numeric'}, ...
%         {'positive', 'scalar', '<=', 1}, ...
%         'Cutoff correlation for unpredictability by neighbors.'), ...
%         'ransacUnbrokenTime', ...
%         getRules(0.4, {'numeric'}, ...
%         {'positive', 'scalar', '<=', 1}, ...
%         'Cutoff fraction of time channel can have poor ransac predictability.'), ...
%         'ransacWindowSeconds', ...
%         getRules(5, {'numeric'}, ...
%         {'positive', 'scalar'}, ...
%         'Size of windows in seconds over which to compute RANSAC predictions.'), ...
%         'referenceType', ...
%         getRules('robust', {'char'}, {}, ...
%         ['Type of reference to be performed: ' ...
%          'robust (default), average, specific, or none.']), ...
%         'interpolationOrder', ...
%         getRules('post-reference', {'char'}, {}, ...
%         ['Specifies when interpolation is performed during referencing: ' ...
%          'post-reference: bad channels are detected again and interpolated after referencing, ' ...
%          'pre-reference: bad channels detected before referencing and interpolated, ' ...
%          'none: no interpolation is performed.']), ...
%         'meanEstimateType', ...
%         getRules('median', {'char'}, {}, ...
%         ['Method for initial estimate of the robust mean: ' ...
%         'median (default), huber, mean, or none']), ...
%         'referenceChannels', ...
%         getRules(1:size(signal.data, 1), {'numeric'}, ...
%         {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
%         'Vector of channel numbers of the channels used for reference.'), ...
%         'evaluationChannels', ...
%         getRules(1:size(signal.data, 1), {'numeric'}, ...
%         {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
%         'Vector of channel numbers of the channels to test for noisiness.'), ...
%         'rereferencedChannels', ...
%         getRules(1:size(signal.data, 1), {'numeric'}, ...
%         {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
%         'Vector of channel numbers of the channels to rereference.'), ...
%         'channelLocations', ...
%         getRules(getFieldIfExists(signal, 'chanlocs'), {'struct'}, ...
%         {'nonempty'}, ...
%         'Structure containing channel locations in EEGLAB chanlocs format.'), ...
%         'channelInformation', ...
%         getRules(getFieldIfExists(signal, 'chaninfo'), ...
%         {'struct'}, {}, ...
%         'Channel information --- particularly nose direction.'), ...
%         'maxReferenceIterations', ...
%         getRules(4,  ...
%         {'numeric'}, {'positive', 'scalar'}, ...
%         'Maximum number of referencing interations.'), ...
%         'reportingLevel', ...
%         getRules('verbose',  ...
%         {'char'}, {}, ...
%         'Set how much information to store about referencing.') ...
   
% switch lower(type)
%     case 'boundary'
%         defaults = struct('ignoreBoundaryEvents', ...
%             getRules(false, {'logical'}, {}, ...
%             ['If false and the signal has boundary events, PREP will abort. ' ...
%              'If true, PREP will temporarily remove boundary events to process ' ...
%              ' and then put boundary events back at the end. This should be ' ...
%              ' done with great care as some EEGLAB ' ...
%             ' functions such as resample, respect boundaries, ' ...
%             'leading to spurious discontinuities.']));
%     case 'resample'
%         defaults = struct( ...
%             'resampleOff', ...
%             getRules(true, {'logical'}, {}, ...
%             'If true, resampling is not used.'), ...
%             'resampleFrequency', ...
%             getRules(512, {'numeric'}, {'scalar', 'positive'}, ...
%             ['Frequency to resample at. If signal already has a ' ...
%             'lower sampling rate, no resampling is done.']), ...
%             'lowPassFrequency', ...
%             getRules(0, {'numeric'}, {'scalar', 'nonnegative'}, ...
%             ['Frequency to low pass or 0 if not performed. '...
%             'The purpose of this low pass is to remove resampling ' ...
%             'artifacts.']));
%     case 'globaltrend'
%         defaults = struct( ...
%             'globalTrendChannels', ...
%             getRules(1:size(signal.data, 1), {'numeric'}, ...
%             {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
%             'Vector of channel numbers of the channels for global detrending.'), ...
%             'doGlobal', ...
%             getRules(false, {'logical'}, {}, ...
%             'If true, do a global detrending operation at before other processing.'), ...
%             'doLocal', ...
%             getRules(true, {'logical'}, {}, ...
%             'If true, do a local linear trend before the global.'), ...
%             'localCutoff', ...
%             getRules(1/200, {'numeric'}, ...
%             {'positive', 'scalar', '<', signal.srate/2}, ...
%             'Frequency cutoff for long term local detrending.'), ...
%             'localStepSize', ...
%             getRules(40,  ...
%             {'numeric'}, {'positive', 'scalar'}, ...
%             'Seconds for detrend window slide.'));
%     case 'detrend'
%         defaults = struct( ...
%             'detrendChannels', ...
%             getRules(1:size(signal.data, 1), {'numeric'}, ...
%             {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
%             'Vector of channel numbers of the channels to detrend.'), ...
%             'detrendType', ...
%             getRules('high pass', {'char'}, {}, ...
%             ['One of {''high pass'', ''linear'', ''none''}' ...
%             ' indicating detrending type.']), ...
%             'detrendCutoff', ...
%             getRules(1, {'numeric'}, ...
%             {'positive', 'scalar', '<', signal.srate/2}, ...
%             'Frequency cutoff for detrending or high pass filtering.'), ...
%             'detrendStepSize', ...
%             getRules(0.02,  ...
%             {'numeric'}, {'positive', 'scalar'}, ...
%             'Seconds for detrend window slide.')  ...
%             );
%     case 'linenoise'
%         defaults = struct( ...
%             'lineNoiseMethod', ...
%             getRules('clean', {'char'}, {}, ...
%             'Method for removing line noise (clean or blasst or none)'), ...
%             'lineNoiseChannels', ...
%             getRules(1:size(signal.data, 1), {'numeric'}, ...
%             {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
%             'Vector of channel numbers of the channels to remove line noise from.'), ...
%             'Fs', ...
%             getRules(signal.srate, {'numeric'}, ...
%             {'positive', 'scalar'}, ...
%             'Sampling rate of the signal in Hz.'), ...
%             'lineFrequencies', ...
%             getRules(lineFrequencies, {'numeric'}, ...
%             {'row', 'positive'}, ...
%             'Vector of frequencies in Hz of the line noise peaks to remove.'), ...
%             'p', ...
%             getRules(0.01,  ...
%             {'numeric'}, {'positive', 'scalar', '<', 1}, ...
%             'Significance cutoff level for removing a spectral peak.'),  ...
%             'fScanBandWidth', ...
%             getRules(2,  ...
%             {'numeric'}, {'positive', 'scalar'}, ...
%             ['Half of the width of the frequency band centered ' ...
%             'on each line frequency.']),  ...
%             'taperBandWidth', ...
%             getRules(2,  ...
%             {'numeric'}, {'positive', 'scalar'}, ...
%             'Bandwidth in Hz for the tapers.'),  ...
%             'taperWindowSize', ...
%             getRules(4,  ...
%             {'numeric'}, {'positive', 'scalar'}, ...
%             'Taper sliding window length in seconds.'),  ...
%             'taperWindowStep', ...
%             getRules(1,  ...
%             {'numeric'}, {'positive', 'scalar'}, ...
%             'Taper sliding window step size in seconds. '),  ...
%             'tau', ...
%             getRules(100,  ...
%             {'numeric'}, {'positive', 'scalar'}, ...
%             'Window overlap smoothing factor.'),  ...
%             'pad', ...
%             getRules(0,  ...
%             {'numeric'}, {'integer', 'scalar'}, ...
%             ['Padding factor for FFTs (-1= no padding, 0 = pad ' ...
%             'to next power of 2, 1 = pad to power of two after, etc.).']),  ...
%             'fPassBand', ...
%             getRules([0 signal.srate/2], {'numeric'}, ...
%             {'nonnegative', 'row', 'size', [1, 2], '<=', signal.srate/2}, ...
%             'Frequency band used (default [0, Fs/2])'),  ...
%             'maximumIterations', ...
%             getRules(10,  ...
%             {'numeric'}, {'positive', 'scalar'}, ...
%             ['Maximum number of times the cleaning process ' ...
%             'applied to remove line noise.']) ...
%             );
%     case 'reference'
%         defaults = struct( ...
%             'srate', ...
%             getRules(signal.srate, {'numeric'}, ...
%             {'positive', 'scalar'}, ...
%             'Sampling rate of the signal in Hz.'), ...
%             'samples', ...
%             getRules(size(signal.data, 2), {'numeric'}, ...
%             {'positive', 'scalar'}, ...
%             'Number of frames to use for computation.'), ...
%             'robustDeviationThreshold', ...
%             getRules(5, {'numeric'}, ...
%             {'positive', 'scalar'}, ...
%             'Z-score cutoff for robust channel deviation.'), ...
%             'highFrequencyNoiseThreshold', ...
%             getRules(5, {'numeric'}, ...
%             {'positive', 'scalar'}, ...
%             'Z-score cutoff for SNR (signal above 50 Hz).'), ...
%             'correlationWindowSeconds', ...
%             getRules(1, {'numeric'}, ...
%             {'positive', 'scalar'}, ...
%             'Correlation window size in seconds.'), ...
%             'correlationThreshold', ...
%             getRules(0.4, {'numeric'}, ...
%             {'positive', 'scalar', '<=', 1}, ...
%             'Max correlation threshold for channel being bad in a window.'), ...
%             'badTimeThreshold', ...
%             getRules(0.01, {'numeric'}, ...
%             {'positive', 'scalar'}, ...
%             ['Threshold fraction of bad correlation windows '...
%             'for designating channel to be bad.']), ...
%             'ransacOff', ...
%             getRules(false, {'logical'}, {}, ...
%             ['If true, RANSAC is not used for bad channel ' ...
%             '(useful for small headsets).']), ...
%             'ransacSampleSize', ...
%             getRules(50, {'numeric'}, ...
%             {'positive', 'scalar', 'integer'}, ...
%             'Number of sample matrices for computing ransac.'), ...
%             'ransacChannelFraction', ...
%             getRules(0.25, {'numeric'}, ...
%             {'positive', 'scalar', '<=', 1}, ...
%             'Fraction of evaluation channels RANSAC uses to predict a channel.'), ...
%             'ransacCorrelationThreshold', ...
%             getRules(0.75, {'numeric'}, ...
%             {'positive', 'scalar', '<=', 1}, ...
%             'Cutoff correlation for unpredictability by neighbors.'), ...
%             'ransacUnbrokenTime', ...
%             getRules(0.4, {'numeric'}, ...
%             {'positive', 'scalar', '<=', 1}, ...
%             'Cutoff fraction of time channel can have poor ransac predictability.'), ...
%             'ransacWindowSeconds', ...
%             getRules(5, {'numeric'}, ...
%             {'positive', 'scalar'}, ...
%             'Size of windows in seconds over which to compute RANSAC predictions.'), ...
%             'referenceType', ...
%             getRules('robust', {'char'}, {}, ...
%             ['Type of reference to be performed: ' ...
%              'robust (default), average, specific, or none.']), ...
%             'interpolationOrder', ...
%             getRules('post-reference', {'char'}, {}, ...
%             ['Specifies when interpolation is performed during referencing: ' ...
%              'post-reference: bad channels are detected again and interpolated after referencing, ' ...
%              'pre-reference: bad channels detected before referencing and interpolated, ' ...
%              'none: no interpolation is performed.']), ...
%             'meanEstimateType', ...
%             getRules('median', {'char'}, {}, ...
%             ['Method for initial estimate of the robust mean: ' ...
%             'median (default), huber, mean, or none']), ...
%             'referenceChannels', ...
%             getRules(1:size(signal.data, 1), {'numeric'}, ...
%             {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
%             'Vector of channel numbers of the channels used for reference.'), ...
%             'evaluationChannels', ...
%             getRules(1:size(signal.data, 1), {'numeric'}, ...
%             {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
%             'Vector of channel numbers of the channels to test for noisiness.'), ...
%             'rereferencedChannels', ...
%             getRules(1:size(signal.data, 1), {'numeric'}, ...
%             {'row', 'positive', 'integer', '<=', size(signal.data, 1)}, ...
%             'Vector of channel numbers of the channels to rereference.'), ...
%             'channelLocations', ...
%             getRules(getFieldIfExists(signal, 'chanlocs'), {'struct'}, ...
%             {'nonempty'}, ...
%             'Structure containing channel locations in EEGLAB chanlocs format.'), ...
%             'channelInformation', ...
%             getRules(getFieldIfExists(signal, 'chaninfo'), ...
%             {'struct'}, {}, ...
%             'Channel information --- particularly nose direction.'), ...
%             'maxReferenceIterations', ...
%             getRules(4,  ...
%             {'numeric'}, {'positive', 'scalar'}, ...
%             'Maximum number of referencing interations.'), ...
%             'reportingLevel', ...
%             getRules('verbose',  ...
%             {'char'}, {}, ...
%             'Set how much information to store about referencing.') ...
%             );
%     case 'report'
%         [~, EEGbase] = fileparts(signal.filename);
%         defaults = struct( ...
%            'reportMode', ...
%             getRules('normal', {'char'}, {}, ...
%             ['Select whether or how report should be generated: ' ...
%             'normal (default) means report generated after PREP, ' ...
%             'skip means report not generated at all, ' ...
%             'reportOnly means PREP is skipped and report generated.']), ...
%             'summaryFilePath', ...
%             getRules(['.' filesep EEGbase 'Summary.html'], {'char'}, {}, ...
%             'File name (including necessary path) for html summary file.'), ...
%             'sessionFilePath', ...
%             getRules(['.' filesep EEGbase 'Report.pdf'], {'char'}, {}, ...
%             'File name (including necessary path) pdf detail report.'), ...
%             'consoleFID', ...
%             getRules(1, {'numeric'}, {'positive', 'integer'}, ...
%             'Open file desriptor for displaying report messages.'), ...
%             'publishOn', ...
%             getRules(true, {'logical'}, {}, ...
%             'If true, use MATLAB publish to publish the results.') ...
%             );
%     case 'postprocess'
%         defaults = struct(...
%             'keepFiltered', ...
%             getRules(false, {'logical'}, {}, ...
%             'If true, apply a final filter to remove low frequency trend.'), ...
%             'removeInterpolatedChannels', ...
%             getRules(false, {'logical'}, {}, ...
%             'If true, remove channels interpolated by Prep.'), ...
%             'cleanupReference', ...
%             getRules(false, {'logical'}, {}, ...
%             ['If true, remove many fields in .etc.noiseDetection.reference '...
%             'resulting in smaller dataset. ' ...
%             'The Prep report cannot be generated in this case.']));
%     otherwise
% end
end

function s = getRules(value, classes, attributes, description)
% Construct the default structure
s = struct('value', [], 'classes', [], ...
    'attributes', [], 'description', []);
s.value = value;
s.classes = classes;
s.attributes = attributes;
s.description = description;
end