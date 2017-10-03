function [currentVersion, changeLog, markdown] = getAnnotateVersion()

    changeLog = getChangeLog();
    currentVersion = ['EEG-Annotate' changeLog(end).version]; 
    markdown = getMarkdown(changeLog);
end

function changeLog = getChangeLog()
    changeLog(3) = ...
     struct('version', '0', 'status', 'Released', 'date', '', 'changes', '');

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