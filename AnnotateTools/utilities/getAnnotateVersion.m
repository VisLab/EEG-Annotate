function [currentVersion, changeLog, markdown] = getAnnotateVersion()

    changeLog = getChangeLog();
    currentVersion = ['EEG-Annotate' changeLog(end).version]; 
    markdown = getMarkdown(changeLog);
end

function changeLog = getChangeLog()
    changeLog(6) = ...
     struct('version', '0', 'status', 'Released', 'date', '', 'changes', '');

    changeLog(6).version = '1.0.6';
    changeLog(6).status = 'Released';
    changeLog(6).date = '11/27/2017';
    changeLog(6).changes = { ...
       'Modified the batch comparison naming'};
   
    changeLog(5).version = '1.0.5';
    changeLog(5).status = 'Released';
    changeLog(5).date = '11/15/2017';
    changeLog(5).changes = { ...
       'Added publication information to README';
       'Added additional documentation to various functions';
       'Added getSampleTiming in preparation for report refactor';
       'Added reportComparison to compare two different annotations'};
    
    changeLog(4).version = '1.0.4';
    changeLog(4).status = 'Released';
    changeLog(4).date = '10/18/2017';
    changeLog(4).changes = { ...
       'Revised the parameter names for computing power features';
       'Added covariance features'};

    changeLog(3).version = '1.0.3';
    changeLog(3).status = 'Released';
    changeLog(3).date = '10/03/2017';
    changeLog(3).changes = { ...
       'Added non-parametric bootstrap test for statistical significance';
       'Began verifying package works for versions later than 2014a'};
 
    changeLog(2).version = '1.0.2';
    changeLog(2).status = 'Released';
    changeLog(2).date = '09/19/2017';
    changeLog(2).changes = { ...
       'Fixed ARRLS to have correct parameter settings'};

    changeLog(1).version = '1.0.1';
    changeLog(1).status = 'Released';
    changeLog(1).date = '08/31/2017';
    changeLog(1).changes = { ...
       'Added getAnnotateVersion'; ...
       'Added powerFeatures aned batchPowerFeatures for consistent process'; ...
       'Cleaned up some of the header documentation'};

end

function markdown = getMarkdown(changeLog)
   markdown = '';
   for k = length(changeLog):-1:1
       tString = sprintf('Version %s %s %s\n', changeLog(k).version, ...
           changeLog(k).status, changeLog(k).date);
       changes = changeLog(k).changes;
       for j = 1:length(changes)
           cString = sprintf('* %s\n', changes{j});
           tString = [tString cString]; %#ok<*AGROW>
       end
       markdown = [markdown tString sprintf('  \n')];
   end
end