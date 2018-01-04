%**************************************************************************
% Integrated Mass trend 
% Last modified by bgetraer@princeton.edu, 1/3/2017
%**************************************************************************
addpath('/Users/benjamingetraer/Documents/JuniorPaper/slepian_bgetraer/functions')
setworkspace('/Users/benjamingetraer/Documents/JuniorPaper/SH_Workspace');
datadir = '/Users/benjamingetraer/Documents/JuniorPaper/slepian_bgetraer/datafiles';
% Get 'slepcoffs60','thedates','G','basis60INT','intmass60' from GREENLAND60.m
load(fullfile(datadir,'Greenland60data'));

L = 60;
%date domains:
Harig2013 = 1:monthnum(6,2013,thedates);
Getraer2018 = monthnum(6,2013,thedates):length(thedates);
all = 1:length(thedates);
%% MODELS
%   s = K*m for data s, linear operator K, and model parameters m

t = ((thedates(Harig2013)-thedates(Harig2013(1)))/365)'; % time in years
s = intmass60(Harig2013);

% M1: 1st degree polynomial regression
%   s(t) = m(1) + m(2)*t
%   s = K*m
K1 = ones(length(t),2);	% constant
K1(:,2) = t;              % linear
% model parameters
m1 = (K1'*K1)\K1'*s;

% M2: 2nd degree polynomial regression
%   s(t) = m(1) + m(2)*t + 1/2*m(3)*t^2
K2 = ones(length(t),3);	% constant
K2(:,2) = t;              % linear
K2(:,3) = 1/2.*t.^2;     % quadratic
% model parameters
m2 = (K2'*K2)\K2'*s;



%AGU 2016 polynomial
% acceleration2016=-28;
%% PLOT
figure(1)
clf
hold on
data = plot(thedates(all),intmass60(all),'linewidth',1.5);
model1 = plot(thedates(Harig2013),K1*m1,'k:','linewidth',2);
model2 = plot(thedates(Harig2013),K2*m2,'--','linewidth',2);

%axes format
datetick
xlim([thedates(1)-100,thedates(all(end))+100]); ylim([-2000 1500]);
xlabel('Year');ylabel('Mass (Gt)');set(gca,'fontsize',12);



% accessory plotting
%new axes for text plotting
a = axes;
axis off

%legend
ltextmodel_1 = strcat('\def\du#1{\underline{\underline{#1}}}',...
    '\begin{tabular}{l}',...
    '1$^{st}$ order polynomial regression \\',... 
    '$\underline{m}_{1}=(\du{G}^{T}_{1}*\du{G}_{1})^{-1}\du{G}^{T}_{1}*\underline{d}$',...
    ' \end{tabular}');
ltextmodel_2 = strcat('\def\du#1{\underline{\underline{#1}}}',...
    '\begin{tabular}{l}',...
    '2$^{nd}$ order polynomial regression \\',... 
    '$\underline{m}_{2}=(\du{G}^{T}_{2}*\du{G}_{2})^{-1}\du{G}^{T}_{2}*\underline{d}$',...
    ' \end{tabular}');
ltextdata = strcat('\begin{tabular}{l}',...
    'monthly GRACE observations',...
    ' \end{tabular}');
lgd = legend([data model1 model2] ,ltextdata,ltextmodel_1,ltextmodel_2);
set(lgd,'Interpreter','latex')


% text block of some interesting values
range = sprintf('Range $\\approx%i$ Gt',round(max(s)-min(s),-2));
m1slope = sprintf('$\\underline{m}_{1}$ Slope $=%i$ Gt per year',round(m1(2)));
% Average modeled mass loss per year 2003-2013
    jan2003 = monthnum(1,2003,thedates);
    jan2013 = monthnum(1,2013,thedates);
    totalloss = K2(jan2013,:)*m2-K2(jan2003,:)*m2;
m2slope = sprintf('$\\underline{m}_{2}$ Avg. mass change 1/2003--1/2013 $=%i$ Gt per year',...
    round(totalloss/10));
m2acceleration = sprintf('$\\underline{m}_{2}$ Acceleration $=%i$ Gt per year$^{2}$',round(m2(3)));
text(a,0.05,0.2,...
    sprintf('\\begin{tabular}{l} %s %s %s %s %s %s %s \\end{tabular}',...
    range,'\\',m1slope,'\\',m2slope,'\\',m2acceleration),'interpreter','latex','fontsize',12)

% title
line1 = 'Greenland GRACE signal, 2003--2014';
line2 = 'Recreation of Harig~\&~Simons, 2016, their Figure 4c';
title(sprintf('\\begin{tabular}{c} \\textbf{%s} %s %s \\end{tabular}',line1,'\\',line2),...
    'interpreter','latex','fontsize',12)
