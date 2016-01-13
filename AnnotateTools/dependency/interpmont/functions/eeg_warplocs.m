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


function EEG = eeg_warplocs(EEG,coord_fname,varargin)

%g=struct(varargin{:});

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

try g.landmarks; catch, g.landmarks = {};end
try g.transform; catch, g.transform = [0 0 0 0 0 0 1 1 1];end
try g.manual; catch, g.maual = 'off';end


if isempty(EEG.chanlocs(1).X)
    disp(sprintf('%s\n','No coordinate information found in the current dataset... doing nothing'));
    return
end

[newlocs] = coregister(EEG.chanlocs, ...
    coord_fname, ...
    'chaninfo1',EEG.chaninfo, ...
    'warp', g.landmarks, ...
    'transform',g.transform, ...
    'manual', g.manual);

ndatch=length(EEG.chanlocs);
nndatch=size(newlocs.pnt,1)-ndatch;

for i=1:ndatch;
    EEG.chanlocs(i).X=newlocs.pnt(i,1);
    EEG.chanlocs(i).Y=newlocs.pnt(i,2);
    EEG.chanlocs(i).Z=newlocs.pnt(i,3);
end

for i=1:nndatch;
    EEG.chaninfo.nodatchans(i).X=newlocs.pnt(ndatch+i,1);
    EEG.chaninfo.nodatchans(i).Y=newlocs.pnt(ndatch+i,2);
    EEG.chaninfo.nodatchans(i).Z=newlocs.pnt(ndatch+i,3);
end

EEG = pop_chanedit(EEG,'convert','cart2all');

