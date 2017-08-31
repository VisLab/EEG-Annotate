function [currentVersion, changeLog, markdown] = getAnnotateVersion()

    changeLog = getChangeLog();
    currentVersion = ['EEG-Annotate' changeLog(end).version]; 
    markdown = getMarkdown(changeLog);
end

function changeLog = getChangeLog()
   changeLog(1) = ...
     struct('version', '0', 'status', 'Released', 'date', '', 'changes', '');

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