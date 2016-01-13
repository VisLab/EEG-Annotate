% EEG = pop_interpmont() - Collect inputs for intrpmont. Interpolate current
%      data to coordinates from a specified coordinate file.
%
% Usage:
%   >>  com= pop_interpmont(EEG, coordfname, varargin);
%
% Inputs:
%   EEG         - input EEG structure
%   coordfname  - name of sfp file containing new channel coordinates.
%   varargin    - key/val pairs. See Options.
%
% Options:
%   nfids        - Number of coordinates at the begining of the coordinate file that
%                  should be treated as fiducials.
%   coreglndmrks - Cell array of channel labels to be used as input to the
%                  the 'warp' option in coregister.m. See help coregister.
%   manual       - ['on'|'off'] 
% Outputs:
%   EEG       - EEG structure updated with new coordinates.
%               input to 'manual' option of coregister.m. See help coregister.
% See also:
%   pop_interpmont

% Copyright (C) <2010>  <James Desjardins>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [EEG com] = pop_warplocs(EEG, coordfname, varargin)

%options = struct(varargin{:});
try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) & ~iscell(options{index}{1}), options{index} = { options{index} }; end;
    end;
    if ~isempty( varargin ), g=struct(options{:});
    else g= []; end;
catch
    disp('ce_eegplot() error: calling convention {''key'', value, ... } error'); return;
end;

if ~isempty(g)
    optstr='';
    try g.nfids;        catch, g.nfids      = 3;       end;
    optstr=['''nfids'', ', num2str(g.nfids)];
end

% the command output is a hidden output that does not have to
% be described in the header
com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            

% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_intrpmont;
	return;
end;	

% pop up window
% -------------

if nargin < 2
    
    results=inputgui( ...
    {1 1 1 [8 1] 1 1 1}, ...
    {...
        {'Style', 'text', 'string', 'Select coordinate file.', 'FontWeight', 'bold'}, ...
        {}, ...
        {'Style', 'text', 'string', 'File:'}, ...
        {'Style', 'edit', 'tag', 'fnameedt', 'string', ''}, ...
        {'Style', 'pushbutton', 'string', '...', ...
        'callback', '[fname,fpath] = uigetfile({''*.sfp;*.elp;*.locs;*.elc''},''Select coordinate file:''); set(findobj(gcbf,''tag'', ''fnameedt''), ''string'', fullfile(fpath,fname));'}, ...
        {'Style', 'text', 'string', 'Optional inputs:'}, ...
        {'Style', 'edit', 'tag', 'optedt', 'string', ''}, ...
        {} ...
    }, ...   
     'pophelp(''pop_intrpmont'');', 'Select coordinate file -- pop_warplocs()' ...
     );

     if isempty(results);return;end;
 
     coordfname        = results{1};
     optstr            = results{2};
end;


% return the string command
% -------------------------

if isempty(optstr);
    com = sprintf('EEG = pop_warplocs( %s, ''%s'');', inputname(1), coordfname)
else
    com = sprintf('EEG = pop_warplocs( %s, ''%s'', %s);', inputname(1), coordfname, optstr)
end

% call function sample either on raw data or ICA data
% ---------------------------------------------------

if isempty(optstr);
    execcom = sprintf('EEG = eeg_warplocs( %s, ''%s'');', inputname(1), coordfname);
else
    execcom = sprintf('EEG = eeg_warplocs( %s, ''%s'', %s);', inputname(1), coordfname, optstr)
end

eval(execcom);

