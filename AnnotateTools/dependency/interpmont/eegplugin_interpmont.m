% eegplugin_intrpmont() - EEGLAB plugin for interpolating data to locations
%                       found in coordinate file recognized by readlocs.
%
% Usage:
%   >> eegplugin_intrpmont(fig, try_strings, catch_stringss);
%
% Inputs:
%   fig            - [integer]  EEGLAB figure
%   try_strings    - [struct] "try" strings for menu callbacks.
%   catch_strings  - [struct] "catch" strings for menu callbacks.
%
%
% Copyright (C) <2010> <James Desjardins> Brock University
%
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

% $Log: eegplugin_intrpmont.m

function eegplugin_interpmont(fig,try_strings,catch_strings)


% Find "Tools" menu.
toolsmenu=findobj(fig,'label','Tools');

% Create cmd for warping chanlocs structure to corrdinate file location.
cmd='[EEG LASTCOM] = pop_warplocs( EEG );';
finalcmdwl=[try_strings.no_check cmd catch_strings.store_and_hist];

% Create cmd for interpolating currentlocations to sites in coordinate file.
cmd='[EEG LASTCOM] = pop_interpmont( EEG );';
finalcmdim=[try_strings.no_check cmd catch_strings.store_and_hist];

% Create cmd for rereferencing current data to the average of sites from a coordinate file.
cmd='[EEG LASTCOM] = pop_interpref( EEG );';
finalcmdir=[try_strings.no_check cmd catch_strings.store_and_hist];

% add "interpolate to coordinate file" submenu to "Tools" menu.
interpmenu=uimenu(toolsmenu,'label','Interpolate to coordinate file');

% add submenus to interpmenu.
uimenu(interpmenu,'label','Warp montage to the surface of sites in a coordinate file','callback',finalcmdwl);
uimenu(interpmenu,'label','Interpolate the data to sites in a coordinate file','callback',finalcmdim);
uimenu(interpmenu,'label','Rereference the data to the average of sites in a coordinate file','callback',finalcmdir);
