function myLog = batch_drivingData(testPath, trainPath, trainName, outPath)

    if isdir(outPath)
        warning([outPath ' is existed, and data will be overwritten.']);
    else
        fprintf('%s is being created\n', outPath);
        mkdir(outPath);
    end    

    % process all set files in the testPath
    % it is not recursive process!
    setList = dir([testPath filesep '*.set']);
    
    myLog = {};
    for i=1:length(setList)
        testName = setList(i).name;

        % load a test dataset
        % make sure the double precision data
        EEG = pop_loadset('filepath', testPath, 'filename', testName);
        EEG.data = double(EEG.data);

        tic
        % PREP 
        % assume the PREPed data

        % remove external channel
        noExEEG = removeExternal(EEG, 1);

        % remove artifacts
        cleanEEG = cleanASR3_drivingData(noExEEG, 20);
        delete('temp.sfp'); % remove a temporary file (optional)

        % extract feature
        %  avearge power in a window
        %  (apply 8 sub-bands and 8 sub-windows)
        subbands = [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32];
        filterOrder = 844;
        windowLength = 1.0;     % the length of a window
        subLength = 0.125;      % in Second, the length of sub-windows (to keep temporal information)
        subStep = 0.125;       
        [testSample, testLabel] = extractFeature_averagePower(cleanEEG, subbands, filterOrder, windowLength, subLength, subStep);

        % estimate score 
        % using ARRLS
        targetClass = '35';     % in the training set, which class is a target?
        % ARRLS option
        options.p = 10;             % keep default
        options.sigma = 0.1;        % keep default
        options.lambda = 10.0;      % keep default
        options.gamma = 1.0;        % [0.1,10]
        options.ker = 'linear';        % 'rbf' | 'linear'
        [scores, predLabels] = estimateScores(testSample, trainPath, trainName, targetClass, options);
        elapsedTime = toc;
        myLog = cat(1, myLog, [testName(1:end-4) ', done, elapsed time, ' num2str(elapsedTime)]);
        save([outPath filesep testName(1:end-4) '.mat'], 'testLabel', 'scores', 'predLabels');

        % plot results (optional)
        % after weighting and zero-out for each training subject
        weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]';
        position = 8;    % weights 
        cutOffPercent= 1;
        plot_prediction_n_true_events_cutOffPercent(scores, weights, position, trainName, testLabel, cutOffPercent, outPath);
    end
end
