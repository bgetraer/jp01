function varargout=grace2slept_inprogress(Dataproduct,TH,XY_buffer,Lwindow,phi,theta,omega,J,units,forcenew)
% [slepcoffs,slepcalerrors,thedates,TH,G,CC,V]
%                 =GRACE2SLEPT_INPROGRESS(Dataproduct,TH,XY_buffer,Lwindow,phi,theta,omega,J,units,forcenew)
%
% IN PROGRESS: edits to this function were begun by bgetraer@princeton.edu in
% order to maintain compatibility with available data.  
% See GRACE2PLMT_INPROGRESS for similar issues and resolutions.
% ISSUES:
%   JPL center not supported
%   incorporate the degree 96 coefficients offered by CSR RL05
%   Lwindow is supposedly defaulted to the bandwidth of the data, but
%       really is defaulted to 18.
%   ddir1 is referencing a directory that is never used in the function
% CURRENT SOLUTIONS:
%   Allow JPL RL05 to be requested, but throw warning as in GRACE2PLMT_INPROGRESS
%   Allow new argument for Dataproduct that distinguishes bandwidth
%   Call GRACE2PLMT_INPROGRESS 
%   get rid of the old ddir1, and make ddir2 ddir1.
%   
%
% This program reads in the Level-2 GRACE geoid products from either the CSR or
% GFZ data centers, does some processing, and saves them as a slept matrix
% in a .mat file.  In particular, the coefficients are reordered to our
% prefered lmcosi format, they are referenced to the WGS84 ellipsoid, 
% the C2,0 coefficients are replaced with more accurate measurements from
% satellite laser ranging (see Cheng et al., 2013), and the degree one coefficients are 
% substituted with those from Swenson et al. (2008). You have the option of leaving them as geopotential 
% or converting them to surface mass density using the method of 
% Wahr et al. 1998, based on Love numbers (see PLM2POT).  They are then 
% projected into a chosen Slepian basis.  All output is SORTED by the 
% global eigenvalue.
%
% INPUT:
% 
% Dataproduct   'CSRRL04' Release level 04 data from the data center 
%                  at the Center for Space Research
%               'CSRRL05_96' Release level 05 data from the data center 
%                  at the Center for Space Research, 96X96
%               'CSRRL05_60' OR 'CSRRL05' Release level 05 data from the 
%                  data center at the Center for Space Research, 60X60
%               'GFZRL04' Release level 04 data from the data center
%                  at the GeoForschungsZentrum Potsdam
%               'GFZRL05' Release level 05 data from the data center
%                  at the GeoForschungsZentrum Potsdam
%               'JPLRL05' Release level 05 data from the data center
%                  at the Jet Propulsion Laboratory
% TH         Radius of the concentration region (degrees) OR
%              'england', 'eurasia',  'namerica', 'australia', 'greenland'
%              'africa', 'samerica', 'amazon', 'orinoco', in which case 
%              you must have phi,theta,omega all equal to zero OR
%              [lon lat] an ordered list defining a closed curve [degrees]
% XY_buffer  Distance in degrees that the region outline will be enlarged
%              by BUFFERM [default: 0]
% Lwindow    Bandwidth of the window [default: bandwidth of the data], 
%              or bandpass (two degrees)
% phi        Longitude of the center of the tapers (degrees)
% theta      Colatitude of the center of the tapers (degrees)
% omega      Anticlockwise azimuthal rotation of the tapers (degrees)
% J          Number of largest eigenfunctions in which to expand 
%             [default: all of them]  Can give the string 'N' if you want
%             the rounded Shannon number.
% units      'POT' or 'SD' for whether you want geopotential or surface
%            mass density
% forcenew    Wether or not you want to force new generation of a save file
%              (1) or just use the one we already have (0) [default].
%
% OUTPUT:
% 
% Returns these variables and saves the first three in a .mat 
% file (kernels are not saved):
%  slepcoffs    The expansion coefficients of the geopotential (or surface 
%                   density) into the Slepian basispotential Slepian coefficients 
%                   [nmonths x addmoff(Ldata)]
%  slepcalerrors  The expansion coefficients of the calibrated errors 
%                   into the Slepian basis calibrated errors 
%                   [nmonths x addmoff(Ldata)]
%  thedates     Time stamps in Matlab time
%  TH           The region back to you.  If there was buffering, this will
%                 be a XY array of coordinates, which you can use with 
%                 SPHAREA to get the Shannon number.
%  G            The unitary matrix of localization coefficients
%  CC           A cell array with cosine/sine coefficients eigenfunctions
%  V            The eigenvalues in this ordering
%  N            The Shannon number
%
% SEE ALSO: PLM2SLEP
%
% Last modified by charig-at-princeton.edu, 03/16/2016
% Last modified by fjsimons-at-alum.mit.edu, 06/26/2012
% Last modified by bgetraer@princeton.edu, 12/25/2017

% Determine parameters and set defaults
defval('Dataproduct','CSRRL05')
defval('TH','greenland')
defval('Lwindow',18)
defval('phi',0)
defval('theta',0)
defval('omega',0)
defval('forcenew',0)
defval('XY_buffer',0)
defval('pars',10);
defval('units','POT')
defval('inout','out')
Pcenter = Dataproduct(1:3);
Rlevel = Dataproduct(4:7);

%bgetraer: we need to sort out the bandwidth issue and stick to
%the same filing system as GRACE2PLMT_INPROGRESS
% We know a priori what the bandwidth of the coefficients can be for each 
% release.
if strcmp(Dataproduct,'GFZRL04'),Ldata = 120;
elseif strcmp(Dataproduct,'GFZRL05'),Ldata = 90;
elseif strcmp(Dataproduct,'CSRRL04'),Ldata = 60;
elseif strcmp(Dataproduct(1:7),'CSRRL05')
    if strcmp(Dataproduct,'CSRRL05'),Ldata = 60;
    elseif contains(Dataproduct,'60'),Ldata = 60;
    elseif contains(Dataproduct,'96'),Ldata = 96;
    end
elseif strcmp(Dataproduct,'JPLRL05'),Ldata = 90;
    % bgetraer: here is my warning on the JPL RL05.1 issue
    if Lwindow<=60, warning='<=';else warning='>';end
    fprintf('[\b%s\n%s\n%s\n]\b%s\n',...
        'WARNING: JPL RL05 is not of uniform bandwidth for the entire period of record.',...
        '90x90 2002-Sept 2014, 60x60 Oct 2014-2017',...
        sprintf('Bandwidth of requested expandsion is %s60',warning),...
        'Press any key to continue')
    pause
end

% Figure out if it's lowpass or bandpass
lp=length(Lwindow)==1;
bp=length(Lwindow)==2;
maxL=max(Lwindow);
% The spherical harmonic dimension
ldim=(Lwindow(2-lp)+1)^2-bp*Lwindow(1)^2;
defval('J',ldim)

% Where you would like to save the new .mat file
defval('ddir1',fullfile(getenv('IFILES'),'GRACE','SlepianExpansions'));

% Get the remaining file names
if ~isstr(TH) && length(TH)==1 % POLAR CAPS
    % Check if you want the Shannon number of eigenfunctions
    if strcmp(J,'N')
       J = round((Lwindow+1)^2*spharea(TH));
    end
    if lp
        fnpl=sprintf('%s/grace2slept-%s-CAP-%i-%i-%i-%s.mat',...
            ddir1,Dataproduct,TH,Lwindow,J,units);
    elseif bp
        fnpl=sprintf('%s/grace2sleptbl-%s-CAP-%i-%i-%i-%i-%s.mat',...
            ddir1,Dataproduct,TH,Lwindow(1),Lwindow(2),J,units);
    else
        error('The degree range is either one or two numbers')       
    end 
        
else % GEOGRAPHICAL REGIONS and XY REGIONS
    % Check if you want the Shannon number of eigenfunctions
    if strcmp(J,'N')
       J = round((Lwindow+1)^2*spharea(TH));
    end
    if isstr(TH) % Geographic
        % Here, TH gets passed to glmalpha, and glmalpha will interpret
        % either the cell of the region
        if XY_buffer ~= 0
            TH = {TH XY_buffer};
            h = [TH{1} num2str(XY_buffer)];
        else
            h=TH;
        end
    else % Closed coordinates (make a hash)
        h=hash(TH,'sha1');
    end
    % The name of the save file
    if lp
        fnpl=sprintf('%s/grace2slept-%s-%s-%i-%i-%s.mat',...
            ddir1,Dataproduct,h,Lwindow,J,units);
    elseif bp
        fnpl=sprintf('%s/grace2sleptbl-%s-%s-%i-%i-%i-%s.mat',...
            ddir1,Dataproduct,h,Lwindow(1),Lwindow(2),J,units);
    else
        error('The degree range is either one or two numbers')
    end

end

% GET THE SLEPIAN BASIS WE WANT
[~,~,~,lmcosiW,~,~,~,~,~,ronmW]=addmon(maxL);
% NOTE: a) Could have used PLM2SLEP but since we need the same operation for many
%         months, slightly better to load the Slepian basis once, and repeatedly
%         multiply by G.  Mostly copied from PLM2SLEP.
%       b) The kernel and eigenfunctions are large to save for large Lwindow.  
%          So instead just load them from either GLMALPHA or GLMALPHAPTO.
%       c) GLMALPHA now handles bandpass

% If it is the standard North-Polar cap or a geographic region, it's easy
if phi==0 && theta==0 && omega==0    
   % Get the Slepian basis; definitely not block-sorted as for the rotated
   % versions this will make no sense at all anymore
   [G,V,EL,EM,N,GM2AL,MTAP,IMTAP]=glmalpha(TH,Lwindow,[],0,[],[],J);
else
   % Need to get a complete GLMALPHA but for the rotated basis
   % Definitely, "single-order" has lost its meaning here, but the MTAP
   % will still identify what the order of the unrotated original was
   [G,V,EL,EM,N,GM2AL,MTAP,IMTAP]=glmalphapto(TH,Lwindow,phi,theta,omega);
   % Since GLMALPHAPTO currently has no option to limit a basis to J, do it here
   G = G(:,1:J);
end
% Sort by decreasing eigenvalue
[V,vi]=sort(V,'descend');
G=G(:,vi); if ~isnan(MTAP); MTAP=MTAP(vi); end
% If you don't do this, the eigenfunctions are ordered in the way
%   that they correspond to single-orders back when, unrotated, they
%   belonged to a polar cap, and the eigenvalues are sorted within
%   these blocks. This is useful for, e.g. SPIE2009_1 a la SDSNEEUW. 
% Collect the eigenvector output into a format that PLM2XYZ knows how to interpret
for j=1:size(G,2)
   % Create the blanks
   cosi=lmcosiW(:,3:4);
   % Stick in the coefficients of the 1st eigentaper
   cosi(ronmW)=G(:,j);
   % Construct the full matrix
   CC{j} = [lmcosiW(:,1:2) cosi]; 
end


% INITILIZATION COMPLETE

% If this expansion already exists, load it.  Otherwise, or if we force 
% it, make a new one (e.g. if you added extra months to the database).
if exist(fnpl,'file')==2 && forcenew==0
     load(fnpl)
     fprintf('%s loaded by GRACE2SLEPT_INPROGRESS\n',fnpl)
else
    % bgetraer: here we are using the bandwidth using the system for 
    % GRACE2PLMT_INPROGRESS.
    % Use GRACE2PLMT to get the GRACE data.  This way, if we have it saved,
    % there is no need to scan the month files again.  GRACE2PLMT takes 
    % care of the WGS84 adjustment, the degree 1 correction, and the C20 correction. 
    [potcoffs,cal_errors,thedates]=grace2plmt_inprogress(Pcenter,Rlevel,units,0,Ldata);
    % *** Here I changed this. Run grace2plmt once to update your data, and
    % then when you call forcenew=1 from now on it will just update the
    % expansion
    
    % Initialize new coefficients
    nmonths=length(thedates);
    slepcoffs=nan(nmonths,J);
    slepcalerrors=nan(nmonths,J);

    % Limit everything to the window bandwidth
    potcoffsW = potcoffs(:,1:size(lmcosiW,1),1:4);
    cal_errorsW = cal_errors(:,1:size(lmcosiW,1),1:4);

    % Loop over the months and perform expansion
    %   bgetraer: Expansion G'*a where a is a vector of the real spherical
    %   harmonic coefficients for a month, ordered corresponding to G and
    %   going up to the desired bandlimit. G'*a=a'*G, but I prefer G'*a as
    %   standard form to PLM2SLEP.m for clarity.
    for index = 1:nmonths
        % Expand this month's POTENTIAL into the Slepian basis
        potcoffs_month=squeeze(potcoffsW(index,:,:));
        slepcoffs(index,:) = ...
            G'*potcoffs_month(2*size(potcoffs_month,1)+ronmW(1:(maxL+1)^2));
        
        % Expand this month of CALIBRATED ERRORS into the Slepian basis
        calerrors_month=squeeze(cal_errorsW(index,:,:));
        slepcalerrors(index,:) = ...
            G'*calerrors_month(2*size(calerrors_month,1)+ronmW(1:(maxL+1)^2));
    end
        
    % SAVE
    % Don't save the kernel and eigenfunctions because we already have 
    % this info saved and can load from GLMALPHA
    % save(fnpl,'slepcoffs','calerrors','thedates','G','CC','V');
    save(fnpl,'slepcoffs','slepcalerrors','thedates');

end % End if we have a save file already

% Collect output
varns={slepcoffs,slepcalerrors,thedates,TH,G,CC,V,N};
varargout=varns(1:nargout);
