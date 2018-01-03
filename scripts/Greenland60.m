%**************************************************************************
% GREENLAND 60 - expand spherical harmonics of bandwidth L=60 into the
% bandwidth L=60 slepian basis for Greenland.
%
% NOTE: this script makes use of the functions GRACE2SLEPT_INPROGRESS and
% GRACE2PLMT_INPROGRESS which are modified to handle the CSR RL05 96X96
% data product.
%
% Greenland60 is a script that saves
%       1) the slepian expansion coefficients in kg/m^2
%       2) the area integrated slepian eigentapers on a unit sphere
%       3) the slepian modeled signal of the GRACE time-series scaled to
%       an Earth sized spheroid in Gt. 
%
% The new files are located in the directory datadir with the names
%       1) slepcoffs60.m
%       2) basis60INT.m
%       3) intmass60.m
%
% Last modified by bgetraer@princeton.edu, 1/3/2017
%**************************************************************************
addpath('/Users/benjamingetraer/Documents/JuniorPaper/slepian_bgetraer/functions')
setworkspace('/Users/benjamingetraer/Documents/JuniorPaper/SH_Workspace');
datadir = '/Users/benjamingetraer/Documents/JuniorPaper/slepian_bgetraer/datafiles';

% load the spherical harmonic coefficients
Ldata = 60; % bandwidth of the GRACE data
[dcoffs,sh_calerrors,~]=grace2plmt_inprogress('CSR','RL05','SD',0,Ldata);
% expand into the first N eigentapers of the Greenland 60x60 basis
L = 60; % bandwidth of the basis into which we want to expand
J = 'N';    % how many eigentapers we want
[slepcoffs60,slep_calerrors,thedates,TH,G,CC,V,N] = ...
    grace2slept_inprogress('CSRRL05_60','greenland',[],L,[],[],[],J,'SD',0);

save(sprintf('%s/slep_greenland_%i_slepcoffs.mat',datadir,L),sprintf('slepcoffs%i',L)); %save coefficients

% The important bits in going from coefficients to integrated mass
% basis60INT=integratebasis(G,'greenland'); %integrated contribution to a unit sphere
% save(sprintf('%s/intslep_greenland_%i_N.mat',sprintf('basis%iINT',L),L))  %save basis60INT
load(sprintf('%s/intslep_greenland_%i_N.mat',datadir,L)) %load basis60INT
area_scaling = 4*pi*fralmanac('a_EGM96','Earth')^2; %scale area on a unit sphere to Earth
mass_scaling = 10^(-12); %scale kg/m^2 to Gt/m^2

intmass60 = sum(basis60INT*area_scaling.*slepcoffs60*mass_scaling,2); %the unaltered slepian time-series
save(sprintf('%s/slep_greenland_%i_timeseries.mat',datadir,L),sprintf('intmass%i',L)); %save time-series