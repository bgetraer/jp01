function [ thevardata, thetimedata, thespacelim, thelevdata ] = getMerra2VAR( thedate, thevar, merra_dir )
%GETMERRA2VAR Retrieve variable data for a given date.
%   If multiple dates are selected, we assume time is the fourth dimension
%   of the variable matrix, and concatenate across files.
%
% INPUT
%   thedate     datenum of the date you want
%   thevar      string of the variable you want (i.e. 'T')
% OUTPUT
%   thevardata  the matrix of data associated with that variable
%   thetimedata cell array of datestring for each image of the matrix
%   thespacedata    limits of lon (row 1) and lat (row 2) of the matrix
%   thelevdata  the pressure level data
% Last modified by bgetraer@princeton.edu 3/5/2018

defval('merra_dir',['/Users/benjamingetraer/Documents/IndependentWork/'...
    'slepian_bgetraer/datafiles/MERRA2']);

% initialize
thevardata = [];
thetimedata = {};
thespacelim = [];
% pull the files you want
for i = 1:length(thedate)   %for each date
    % netCDF file directory
    filename = fileNameMERRA2(thedate(i),merra_dir);
    the_ncdf = fullfile(merra_dir,filename);
    finfo = ncinfo(the_ncdf);

    % check the file's variables
    if ~any(strcmp({finfo.Variables.Name},thevar))
        error('Variable \"%s\" does not exist in ncdf!',thevar);
    end
    % return the data of the specific file
    %   concatenated along the 4th dimension (time, for us)
    thevardata = cat(4, thevardata, ncread(the_ncdf,thevar));
    
    % get the time data
    time_data = ncread(the_ncdf,'time');

    for t = 1:size(time_data)
        timerange = ncdf_timerange(the_ncdf);
        if double(time_data(t))==540
            eachdate = [datestr(datenum(year(timerange(1)),month(timerange(1)),...
        day(timerange(1)),hour(timerange(1)),double(time_data(t)),0),'dd-mmm-yyyy') ...
        ' MEAN'];
        else
        eachdate = datestr(datenum(year(timerange(1)),month(timerange(1)),...
        day(timerange(1)),hour(timerange(1)),double(time_data(t)),0),'dd-mmm-yyyy HHMM');
        end
        thetimedata = cat(1,thetimedata,eachdate);
    end
end
thespacelim(1,:) = minmax(ncread(the_ncdf,'lon'));
thespacelim(2,:) = minmax(ncread(the_ncdf,'lat'));
thelevdata = ncread(the_ncdf,'lev');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ fname ] = fileNameMERRA2( thedate, dir)
%FILENAMEMERRA2 Formats the filename for requested dates, and confirms it
%   exists in the directory.
% Last modified by bgetraer@princeton.edu 3/5/2018

yr = year(thedate);
if yr < 1992
        version = 'MERRA2_100';
else if yr < 2001
        version = 'MERRA2_200';
    else if yr < 2011
        version = 'MERRA2_300';
        else if yr >= 2011
        version = 'MERRA2_400';
            end
        end
    end
end

datatype = 'inst6_3d_ana_Np';
thedatestr = datestr(thedate,'yyyymmdd');

fname = sprintf('%s.%s.%s.%s',version,datatype,thedatestr,'SUB.nc');

if ~exist(fullfile(dir,fname),'file')
    error('requested MERRA2 netCDF file does not exist in the directory')
end

end
