addpath('/Users/benjamingetraer/Documents/IndependentWork/slepian_bgetraer/functions')
setworkspace('/Users/benjamingetraer/Documents/IndependentWork/SH_Workspace');
% radius
r = 15;
L = 20;
% define the center as the North Pacific
centertype = 2;
location_index = 1;
centers = setcircbases(centertype,r,1,0);
c = [centers(1,location_index);centers(2,location_index)];

%% Set up spherical harmonic coefficients
% import the GRACE spherical harmonic coefficients
[potcoffs,cal_errors,thedates]=grace2plmt_inprogress('CSR','RL05','SD',0,96);

%% transform GRACE harmonics into Slepian expansion coefficients
[slepcoffs,calerrors,thedates,TH,G,CC,V2,N2] = grace2slept_inprogress('CSRRL05_96','greenland',[],90,[],[],[],'N','SD',0);
%%
f2=slepcoffs(1,:)';
% Slepian expansion coefficients to the new basis
Gfalpha = G.*slepcoffs(1,:);
%%
hold on
plotslep(sum(Gfalpha,2),1)
setcircbases(centertype,r,1,0);

%%

% transform GRACE harmonics into Slepian expansion coefficients
[falpha,V,N,MTAP,C] = plm2slep(plm_test,radius,L,...
        centers(1,location_index),centers(2,location_index));

%%
figure(3)
hold on

plotslep(sum(Gfalpha,2),1,1,1)

colorbar
% 
% 
% %%
% for i = 1:length(cont_centers)
%     [falpha,V,N,MTAP,C] = plm2slep(plm_test,radius,bandlimit,...
%         cont_centers(1,i),cont_centers(2,i));
%     figure(i)
%     plotplm(falpha.*C)
% end
% %%
% figure(3)
% subplot(1,2,1)
% plotplm(C)
% colorbar
% caxis([-2 2]*1e-1)
% 
% subplot(1,2,2)
% plotplm(G)
% colorbar
% caxis([-2 2]*1e-1)
% %% plot of circular bases in lat/lon cartesian space
% figure(1)
% plotcont;   % plot the continent outlines
% hold on;
% 
% [circLON circLAT] = caploc([316,72],radius,100,1);
% plot(circLON, circLAT,'.k','markersize',0.25);
