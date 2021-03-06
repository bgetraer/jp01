addpath('/Users/benjamingetraer/Documents/JuniorPaper/slepian_bgetraer/functions')
datadir = '/Users/benjamingetraer/Documents/JuniorPaper/slepian_bgetraer/datafiles';
addpath(datadir)
setworkspace('/Users/benjamingetraer/Documents/JuniorPaper/SH_Workspace');

order = 10;
load(fullfile(datadir,sprintf('boxGL%d.mat',order)))
load(fullfile(datadir,sprintf('ptsGL%d.mat',order)))


%% Image of Greenland mass and image basis
figure(2)
clf
im1 = imagesc(lond); % the image of Greenland
hold on
axis image
colormap(bluewhitered(1000,0));
colorbar

% the number of x and y points
xpts = im1.XData(2);
ypts = im1.YData(2);

% the limits of the image axis
xylim = axis;

% the grid of x and y coordinates of the image basis
xp = linspace(xylim(1),xylim(2),xpts);
yp = linspace(xylim(3),xylim(4),ypts);
[xp,yp] = ndgrid(xp,yp);
xp=xp';
yp=yp';

%% Interpolant functions for (lon,lat) to x and y
Fx = scatteredInterpolant(lond(:),latd(:),xp(:));
Fy = scatteredInterpolant(lond(:),latd(:),yp(:));
%% Project Lat/Lon onto the Image
% Greenland lat lon
gxy = greenland(10);
% Greenland xy in the image basis
gx = Fx(gxy(:,1),gxy(:,2));
gy = Fy(gxy(:,1),gxy(:,2));

% endpoints
x1=Fx(lond(1,1),latd(1,1));
y1=Fy(lond(1,1),latd(1,1));
x2=Fx(lond(1,end),latd(1,end));
y2=Fy(lond(1,end),latd(1,end));
x3=Fx(lond(end,1),latd(end,1));
y3=Fy(lond(end,1),latd(end,1));
x4=Fx(lond(end,end),latd(end,end));
y4=Fy(lond(end,end),latd(end,end));


figure(2)
clf
im1 = imagesc(lond);
axis image

colormap(bluewhitered(1000,0));
colorbar
hold on
% endpoints
plot([x1,x2,x3,x4],[y1,y2,y3,y4],'o',...
    'MarkerF','r','MarkerE','k');
% Greenland
plot(gx,gy,'k-')

%% save interpolant functions
save(fullfile(datadir,sprintf('im_tools%d.mat',order)),'Fx','Fy','gx','gy')
%% WD = wavedec2(Dim,

figure(2)
plot(gxy(:,1),gxy(:,2))
hold on
plot(gxy(1,1),gxy(1,2),'o')
figure(3)
surface(lond,latd,'edgecolor','none','FaceColor','texture','Cdata',D);

% cutoff = 1E2;
% Dft = fft2(Dim);
% Dft1 = abs(fftshift(Dft));
% Dft(Dft>cutoff) = Dft(Dft>cutoff);
% Dft(Dft<cutoff) = 0;
% Dtest = ifft2(Dft);
% imagesc(Dtest)
% caxis('auto')
% colormap(bluewhitered(1000,0))
% axis image