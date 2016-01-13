% pop_interpref() - collects inputs for interpref.
%
% Usage:
%   >>  com= pop_interpref(EEG, coordfname, optstr);
%
% Inputs:
%   EEG         - input EEG structure
%   coordfname  - file name of sfp file containing new reference channels
%   optstr      - string containing writesLORcoord key/val pairs for
%               varargin. See Options.
%
% Options:
%   nfids     - number of inital channels in sfp file to be handled as
%               fiducials.
%
% Outputs:
%   com         - pop_interpref command string
%
% See also:
%   interpref 

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

function [EEG com] = pop_interpref(EEG, coordfname, varargin)

g = struct(varargin{:});

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
	help pop_intrpref;
	return;
end;	

% pop up window
% -------------

if nargin < 2
    
    results=inputgui( ...
    {1 1 1 [8 1] 1 1 1}, ...
    {...
        {'Style', 'text', 'string', 'Select sfp coordinate file containing reference locations:.', 'FontWeight', 'bold'}, ...
        {}, ...
        {'Style', 'text', 'string', 'File:'}, ...
        {'Style', 'edit', 'tag', 'fnameedt', 'string', ''}, ...
        {'Style', 'pushbutton', 'string', '...', ...
        'callback', '[fname,fpath] = uigetfile({''*.sfp''},''Select sfp coordinate file:''); set(findobj(gcbf,''tag'', ''fnameedt''), ''string'', fullfile(fpath,fname));'}, ...
        {'Style', 'text', 'string', 'Optional inputs:'}, ...
        {'Style', 'edit', 'tag', 'optedt', 'string', ''}, ...
        {} ...
    }, ...   
     'pophelp(''pop_intrpref'');', 'Select sfp coordinate file containing reference locations -- pop_intrpref()' ...
     );

     if isempty(results);return;end;
 
     coordfname        = results{1};
     optstr            = results{2};
end;


% return the string command
% -------------------------

if isempty(optstr);
    com = sprintf('EEG = pop_interpref( %s, ''%s'');', inputname(1), coordfname);
else
    com = sprintf('EEG = pop_interpref( %s, ''%s'', %s);', inputname(1), coordfname, optstr);
end

% call function sample either on raw data or ICA data
% ---------------------------------------------------

if isempty(optstr);
    execcom = sprintf('EEG = intrperef( %s, ''%s'');', inputname(1), coordfname);
else
    execcom = sprintf('EEG = intrperef( %s, ''%s'', %s);', inputname(1), coordfname, optstr);
end

eval(execcom);

