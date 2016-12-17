function varargout = datestr8601(DVN,varargin)
% Convert a Date Vector or Serial Date Number to an ISO 8601 formatted Date String (timestamp).
%
% (c) 2014 Stephen Cobeldick
%
% ### Function ###
%
% Syntax:
%  Str = datestr8601
%  Str = datestr8601(DVN)
%  Str = datestr8601(DVN,Tok)
%  [Str1,Str2,...] = datestr8601(DVN,Tok1,Tok2,...)
%
% Easy conversion of a Date Vector or Serial Date Number to a Date String
% whose style is controlled by (optional) input token/s. The string may
% be an ISO 8601 timestamp or a single date/time value: multiple tokens may
% be used to output multiple strings (faster than multiple function calls).
%
% By default the function uses the current time and returns the basic
% ISO 8601 calendar notation timestamp: this is very useful for naming
% files that can be sorted alphabetically into chronological order!
%
% The ISO 8601 timestamp style options are:
% - Date in calendar, ordinal or week-numbering notation.
% - Basic or extended format.
% - Choice of date-time separator character ( @T_).
% - Full or lower precision (trailing units omitted)
% - Decimal fraction of the trailing unit.
% These style options are illustrated in the tables below.
%
% Note 1: Calls undocumented MATLAB functions "datevecmx" and "datenummx".
% Note 2: Some Date Strings use the ISO 8601 week-numbering year, where the first
%  week of the year includes the first Thursday of the year: please double check!
% Note 3: Out-of-range values are permitted in the input Date Vector.
%
% See also DATENUM8601 DATEROUND CLOCK NOW DATESTR DATENUM DATEVEC
%
% ### Examples ###
%
% Examples use the date+time described by the vector [1999,1,3,15,6,48.0568].
%
% datestr8601
%  ans = '19990103T150648'
%
% datestr8601([],'yn_HM')
%  ans = '1999003_1506'
%
% datestr8601(now-1,'DDDD')
%  ans = 'Saturday'
%
% datestr8601(clock,'*ymdHMS')
%  ans = '1999-01-03T15:06:48'
%
% [A,B,C,D] = datestr8601(clock,'ddd','mmmm','yyyy','*YWD')
% sprintf('The %s of %s %s has the ISO week-date "%s".',A,B,C,D)
%  ans = 'The 3rd of January 1999 has the ISO week-date "1998-W53-7".'
%
% ### Single Value Tokens ###
%
% For date values the case of the token determines the output Date String's
% year-type: lowercase = calendar year, UPPERCASE = week-numbering year.
%
% 'W' = the standard ISO 8601 week number (this is probably what you want).
% 'w' = the weeks (rows) shown on an actual printed calendar (very esoteric).
%
% 'Q' = each quarter is 13 weeks (the last may be 14). Uses week-numbering year.
% 'q' = each quarter is three months long: Jan-Mar, Apr-Jun, Jul-Sep, Oct-Dec.
%
% 'N'+'R' = 7*52 or 7*53 (year dependent).
% 'n'+'r' = 365 (or 366 if a leap year).
%
% Input | Output                                      | Output
% <Tok>:| <Str> Date/Time Representation:             | <Str> Example:
% ------|---------------------------------------------|--------------------
% # Calendar year #                                   |
% 'yyyy'| year, four digit                            |'1999'
% 'n'   | day of the year, variable digits            |'3'
% 'nn'  | day of the year, three digit, zero padded   |'003'
% 'nnn' | day of the year, ordinal and suffix         |'3rd'
% 'r'   | days remaining in year, variable digits     |'362'
% 'rr'  | days remaining in year, three digit, padded |'362'
% 'rrr' | days remaining in year, ordinal and suffix  |'362nd'
% 'q'   | year quarter, 3-month                       |'1'
% 'qq'  | year quarter, 3-month, abbreviation         |'Q1'
% 'qqq' | year quarter, 3-month, ordinal and suffix   |'1st'
% 'w'   | week of the year, one or two digit          |'1'
% 'ww'  | week of the year, two digit, zero padded    |'01'
% 'www' | week of the year, ordinal and suffix        |'1st'
% 'm'   | month of the year, one or two digit         |'1'
% 'mm'  | month of the year, two digit, zero padded   |'01'
% 'mmm' | month name, three letter abbreviation       |'Jan'
% 'mmmm'| month name, in full                         |'January'
% 'd'   | day of the month, one or two digit          |'3'
% 'dd'  | day of the month, two digit, zero padded    |'03'
% 'ddd' | day of the month, ordinal and suffix        |'3rd'
% ------|---------------------------------------------|---------
% # Week-numbering year #                             |
% 'YYYY'| year, four digit,                           |'1998'
% 'N'   | day of the year, variable digits            |'371'
% 'NN'  | day of the year, three digit, zero padded   |'371'
% 'NNN' | day of the year, ordinal and suffix         |'371st'
% 'R'   | days remaining in year, variable digits     |'0'
% 'RR'  | days remaining in year, three digit, padded |'000'
% 'RRR' | days remaining in year, ordinal and suffix  |'0th'
% 'Q'   | year quarter, 13-week                       |'4'
% 'QQ'  | year quarter, 13-week, abbreviation         |'Q4'
% 'QQQ' | year quarter, 13-week, ordinal and suffix   |'4th'
% 'W'   | week of the year, one or two digit          |'53'
% 'WW'  | week of the year, two digit, zero padded    |'53'
% 'WWW' | week of the year, ordinal and suffix        |'53rd'
% ------|---------------------------------------------|---------
% # Weekday #                                         |
% 'D'   | weekday number (Monday=1)                   |'7'
% 'DD'  | weekday name, two letter abbreviation       |'Su'
% 'DDD' | weekday name, three letter abbreviation     |'Sun'
% 'DDDD'| weekday name, in full                       |'Sunday'
% ------|---------------------------------------------|---------
% # Time of day #                                     |
% 'H'   | hour of the day, one or two digit           |'15'
% 'HH'  | hour of the day, two digit, zero padded     |'15'
% 'M'   | minute of the hour, one or two digit        |'6'
% 'MM'  | minute of the hour, two digit, zero padded  |'06'
% 'S'   | second of the minute, one or two digit      |'48'
% 'SS'  | second of the minute, two digit, zero padded|'48'
% 'F'   | deci-second of the second, zero padded      |'0'
% 'FF'  | centisecond of the second, zero padded      |'05'
% 'FFF' | millisecond of the second, zero padded      |'056'
% ------|---------------------------------------------|---------
% 'MANP'| Midnight/AM/Noon/PM (+-0.0005s)             |'PM'
% ------|---------------------------------------------|---------
%
% ### ISO 8601 Timestamps ###
%
% The token consists of one letter for each of the consecutive date/time
% units in the timestamp, thus it defines the date notation (calendar,
% ordinal or week-date) and selects either basic or extended format:
%
% Output   | Basic Format             | Extended Format (token prefix '*')
% Date     | Input  | Output Timestamp| Input   | Output Timestamp
% Notation:| <Tok>: | <Str> Example:  | <Tok>:  | <Str> Example:
% ---------|--------|-----------------|---------|--------------------------
% Calendar |'ymdHMS'|'19990103T150648'|'*ymdHMS'|'1999-01-03T15:06:48'
% ---------|--------|-----------------|---------|--------------------------
% Ordinal  |'ynHMS' |'1999003T150648' |'*ynHMS' |'1999-003T15:06:48'
% ---------|--------|-----------------|---------|--------------------------
% Week     |'YWDHMS'|'1998W537T150648'|'*YWDHMS'|'1998-W53-7T15:06:48'
% ---------|--------|-----------------|---------|--------------------------
%
% Options for reduced precision timestamps, non-standard date-time separator
% character, and the addition of a decimal fraction of the trailing unit:
%
% # Omit leading and/or trailing units (reduced precision), eg:
% ---------|--------|-----------------|---------|--------------------------
%          |'DHMS'  |'7T150648'       |'*DHMS'  |'7T15:06:48'
% ---------|--------|-----------------|---------|--------------------------
%          |'mdH'   |'0103T15'        |'*mdH'   |'01-03T15'
% ---------|--------|-----------------|---------|--------------------------
% # Select the date-time separator character (one of ' ','@','T','_'), eg:
% ---------|--------|-----------------|---------|--------------------------
%          |'n_HMS' |'003_150648'     |'*n_HMS' |'003_15:06:48'
% ---------|--------|-----------------|---------|--------------------------
%          |'YWD@H' |'1998W537@15'    |'*YWD@H' |'1998-W53-7@15'
% ---------|--------|-----------------|---------|--------------------------
% # Decimal fraction of the trailing date/time value, eg:
% ---------|--------|-----------------|---------|--------------------------
%          |'HMS4'  |'150648.0568'    |'*HMS4'  |'15:06:48.0568'
% ---------|--------|-----------------|---------|--------------------------
%          |'YW7'   |'1998W53.9471032'|'*YW7'   |'1998-W53.9471032'
% ---------|--------|-----------------|---------|--------------------------
%          |'y10'   |'1999.0072047202'|'*y10'   |'1999.0072047202'
% ---------|--------|-----------------|---------|--------------------------
%
% Note 4: Token parsing matches Single Value tokens before ISO 8601 tokens.
% Note 5: This function does not check for ISO 8601 compliance: user beware!
% Note 6: Date-time separator character must be one of ' ','@','T','_'.
% Note 7: Date notations cannot be combined: note upper/lower case characters.
%
% ### Input & Output Arguments ###
%
% Inputs:
%  DVN = Date Vector, [year,month,day,hour,minute,second.millisecond].
%      = Serial Date Number, where 1 = start of 1st January of the year 0000.
%      = []*, uses current time (default).
%  Tok = String token, chosen from the above tables (default is 'ymdHMS').
%
% Outputs:
%  Str = Date String, whose representation is controlled by argument <Tok>.
%
% [Str1,Str2,...] = datestr8601(DVN,Tok1,Tok2,...)

DfAr = {'ymdHMS'}; % {Tok1}
DfAr(1:numel(varargin)) = varargin;
%
% Calculate date-vector:
if nargin==0||isempty(DVN) % Default = now
    DtV = clock;
elseif isscalar(DVN)       % Serial Date Number
    DtV = datevecmx(DVN);
elseif isrow(DVN)          % Date Vector
    DtV = datevecmx(datenummx(DVN));
else
    error('First input <DVN> must be a single Date Vector or Date Number.');
end
% Calculate Serial Date Number:
DtN = datenummx(DtV);
% Weekday index (Mon=0):
DtD = mod(floor(DtN(1))-3,7);
% Adjust date to suit week-numbering:
DtN(2,1) = DtN(1)+3-DtD;
DtV(2,:) = datevecmx(floor(DtN(2)));
DtV(2,4:6) = DtV(1,4:6);
% Separate fraction of seconds from seconds:
DtV(:,7) = round(rem(DtV(1,6),1)*10000);
DtV(:,6) = floor(DtV(1,6));
% Date at the end of the year [last,this]:
DtE(1,:) = datenummx([DtV(1)-1,12,31;DtV(1),12,31]);
DtE(2,:) = datenummx([DtV(2)-1,12,31;DtV(2),12,31]);
DtO = 3-mod(DtE(2,:)+1,7);
DtE(2,:) = DtE(2,:)+DtO;
%
varargout = DfAr;
%
APC = {'Midnight','AM','Noon','PM'};
ChO = ['00000000001111111111222222222233333333334444444444555555555566666';...
       '01234567890123456789012345678901234567890123456789012345678901234';...
       'tsnrtttttttttttttttttsnrtttttttsnrtttttttsnrtttttttsnrtttttttsnrt';...
       'htddhhhhhhhhhhhhhhhhhtddhhhhhhhtddhhhhhhhtddhhhhhhhtddhhhhhhhtddh'].';
Err = '%.0f%s input (token) is not recognized: ''%s''';
%
for m = 1:numel(DfAr)
    % Ordinal suffix of input:
    OrS = ChO(1+rem(m+1,10)+10*any(rem(m+1,100)==11:13),3:4); % (also day of the year)
    % Input token:
    Tok = DfAr{m};
    assert(ischar(Tok)&&isrow(Tok),'%.0f%s input must be a string token.',m+1,OrS)
    TkL = numel(Tok);
    TkU = strcmp(upper(Tok),Tok);
    switch Tok
        case {'S','SS','M','MM','H','HH','d','dd','ddd','m','mm'}
            % seconds, minutes, hours, day of the month, month of the year
            Val = DtV(1,strfind('ymdHMS',Tok(1)));
            varargout{m} = ChO(1+Val,1+(TkL~=2&&Val<10):max(2,2*(TkL-1))); % (also week)
        case {'D','DD','DDD','DDDD'}
            % weekday
            varargout{m} = ds8601Day(TkL,DtD);
        case {'mmm','mmmm'}
            % month of the year
            varargout{m} = ds8601Mon(TkL,DtV(1,2));
        case {'F','FF','FFF'}
            % deci/centi/milliseconds
            Tok = sprintf('%04.0f',DtV(1,7));
            varargout{m} = Tok(1:TkL);
        case {'n','nn','nnn','r','rr','rrr','N','NN','NNN','R','RR','RRR'}
            % day of the year, days remaining in the year
            varargout{m} = ds8601DoY(TkL,ChO,...
                abs(floor(DtN(1))-DtE(1+TkU,1+strncmpi('r',Tok,1))));
        case {'y','yyyy','Y','YYYY'}
            % year
            varargout{m} = sprintf('%04.0f',DtV(1+TkU));
        case {'w','ww','www','W','WW','WWW'}
            % week of the year
            Val = floor(max(0,(DtN(1+TkU)-DtE(1+TkU)+DtO(1)*~TkU))/7);
            varargout{m} = ChO(2+Val,1+(TkL~=2&&Val<10):max(2,2*(TkL-1))); % (also S/M/H/d/m)
        case {'q','qq','qqq','Q','QQ','QQQ'}
            % year quarter
            Val = [ceil(DtV(1,2)/3),min(4,1+floor((DtN(2)-DtE(2))/91))];
            varargout{m} = ds8601Qtr(TkL,Val(1+TkU));
        case 'MANP'
            % midnight/am/noon/pm
            Val = 2+2*(DtV(1,4)>=12)-(all(DtV(1,5:7)==0)&&any(DtV(1,4)==[0,12]));
            varargout{m} = APC{Val};
        otherwise % ISO 8601 timestamp
            % Identify format, date, separator, time and digit characters:
            TkU = regexp(Tok,'(^\*?)([ymdnYWD]*)([ @T_]?)([HMS]*)(\d*$)','tokens','once');
            assert(~isempty(TkU),Err,m+1,OrS,Tok)
            TkL = [TkU{2},TkU{4}];
            % Identify timestamp:
            Val = strfind('ymdHMSynHMSYWDHMS',TkL);
            assert(~isempty(Val),Err,m+1,OrS,Tok)
            BeR = [1,2,3,4,5,6,1,3,4,5,6,1,2,3,4,5,6];
            BeN = [1,1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,3];
            BeR = BeR(Val(1)-1+(1:numel(TkL)));
            assert(all(diff(BeR)>0),Err,m+1,OrS,Tok)
            % Create date string:
            varargout{m} = ds8601ISO(DtV,DtN,DtE,DtD,ChO,BeR,...%Bas,Dgt,Ntn,Sep)
                isempty(TkU{1}),sscanf(TkU{5},'%d'),BeN(Val(1)),TkU{3});
    end
end
%
end
%----------------------------------------------------------------------END:datestr8601
function DtS = ds8601Day(TkL,Val)
% weekday
%
if TkL==1
    StT = '1234567';
    DtS = StT(1+Val);
else
    StT = ['Monday   ';'Tuesday  ';'Wednesday';...
           'Thursday ';'Friday   ';'Saturday ';'Sunday   '];
    StE = [6,7,9,8,6,8,6]; % Weekday name lengths
    DtS = StT(1+Val,1:max(TkL,StE(1+Val)*(TkL-3))); % (also month)
end
%
end
%----------------------------------------------------------------------END:ds8601Day
function DtS = ds8601Mon(TkL,Val)
% month
%
StT = ['January  ';'February ';'March    ';'April    ';...
       'May      ';'June     ';'July     ';'August   ';...
       'September';'October  ';'November ';'December '];
StE = [7,8,5,5,3,4,4,6,9,7,8,8]; % Month name lengths
DtS = StT(Val,1:max(TkL,StE(Val)*(TkL-3))); % (also weekday)
%
end
%----------------------------------------------------------------------END:ds8601Mon
function DtS = ds8601DoY(TkL,ChO,Val)
% day of the year, days remaining in the year
%
if TkL<3
    DtS = sprintf('%0*.0f',2*TkL-1,Val);
else
    DtS = sprintf('%.0f%s',Val,ChO(1+rem(Val,10)+10*any(rem(Val,100)==11:13),3:4)); % (also OrS)
end
%
end
%----------------------------------------------------------------------END:ds8601DoY
function DtS = ds8601Qtr(TkL,Val)
% year quarter
%
QT = ['Q1st';'Q2nd';'Q3rd';'Q4th'];
QI = 1+abs(TkL-2):max(2,2*(TkL-1));
DtS = QT(Val,QI);
%
end
%----------------------------------------------------------------------END:ds8601Qtr
function DtS = ds8601ISO(DtV,DtN,DtE,DtD,ChO,BeR,Bas,Dgt,Ntn,Sep)
% ISO 8601 timestamp
%
% For calculating decimal fraction of date/time values:
BeE = BeR(end);
DtK = 1;
DtW = DtV(1,:);
DtZ = [1,1,1,0,0,0,0];
%
if isempty(Sep)
    Sep = 'T';
end
if Bas % Basic-format
    DtC = {'', '', '',Sep, '', '';'','','','','',''};
else
    % Extended-format
    DtC = {'','-','-',Sep,':',':';'','','','','',''};
end
%
% hours, minutes, seconds:
for m = 4:max(BeR)
    DtC{2,m} = ChO(1+DtW(m),1:2);
end
%
switch Ntn
    case 1 % Calendar.
        % month, day of the month:
        for m = max(2,min(BeR)):3
            DtC{2,m} = ChO(1+DtW(m),1:2);
        end
    case 2 % Ordinal.
        % day of the year:
        DtC{2,3} = sprintf('%03.0f',floor(DtN(1))-DtE(1));
    case 3 % Week-numbering
        DtW = DtV(2,:);
        % Decimal fraction of weeks, not days:
        if BeR(end)==2
            BeE = 3;
            DtK = 7;
            DtZ(3) = DtW(3)-DtD;
        end
        % weekday:
        if any(BeR==3)
            DtC{2,3} = ChO(2+DtD,2);
        end
        % week of the year:
        if any(BeR==2)
            DtC{2,2} = ['W',ChO(2+floor((DtN(2)-DtE(2))/7),1:2)];
        end
end
%
if BeR(1)==1
    % year:
    DtC{2,1} = sprintf('%04.0f',DtW(1));
end
%
% Concatenate separator and value strings:
BeN = [BeR*2-1;BeR*2];
DtS = [DtC{BeN(2:end)}];
%
% Decimal fraction of trailing unit (decimal places):
if 0<Dgt
    DcP = 0;
    if BeR(end)==6
        % second
        DcP = 4;
        Str = sprintf('%0*.0f',DcP,DtW(7));
    elseif BeR(end)==3
        % day
        DcP = 10;
        Str = sprintf('%.*f',DcP,rem(DtN(1),1));
        Str(1:2) = [];
    elseif any(DtW(BeR(end)+1:7)>DtZ(BeR(end)+1:7));
        % year/month/week/hour/minute
        DcP = 16;
        % Floor all trailing units:
        DtW(7) = [];
        DtW(BeR(end)+1:6) = DtZ(BeR(end)+1:6);
        DtF = datenummx(DtW);
        % Increment the chosen unit:
        DtW(BeE) = DtW(BeE)+DtK;
        % Decimal fraction of the chosen unit:
        dcf = (DtN(1+(Ntn==3))-DtF)/(datenummx(DtW)-DtF);
        Str = sprintf('%.*f',DcP,dcf);
        Str(1:2) = [];
    end
    Str(1+DcP:Dgt) = '0';
    DtS = [DtS,'.',Str(1:Dgt)];
end
%
end
%----------------------------------------------------------------------END:ds8601ISO