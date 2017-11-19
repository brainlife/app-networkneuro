function [] = main()

disp('loading paths')
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/fine'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))
addpath(genpath('/N/u/hayashis/BigRed2/git/mba'))

% load my own config.json
config = loadjson('config.json');

% create output directory
mkdir('output');

% create cache dir
mkdir('cache');

% create the labels
labels = fsInflateDK('./aparc+aseg.nii.gz', 3, 'vert', './output/aparc+aseg_labels.nii.gz');

% run the network generation process
[ pconn, rois, omat, olab ] = fnBuildNetworks_brainlife(config.fe, labels, 4, 'cache')

% save the outputs
save('output/omat.mat', 'omat');
save('output/olab.mat', 'olab');
save('output/pconn.mat', 'pconn');
save('output/rois.mat', 'rois');

% save text outputs
dlmwrite('./output/count.csv', omat(:,:,1), ',');
dlmwrite('./output/density.csv', omat(:,:,2), ',');
dlmwrite('./output/emd.csv', omat(:,:,10), ',');

%% create and save some plots

% uncleaned streamline count
figure();
colormap('hot');
imagesc(log10(omat(:,:,2)));
axis('square'); axis('equal'); axis('tight');
title('Log_{10} Streamline Density');
xlabel('FS DK Regions');
ylabel('FS DK Regions');
y = colorbar;
ylabel(y, 'Log_{10} Density of Streamlines');
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 'YTick', []);
line([34.5 34.5], [0.5 68.5], 'Color', [0 0 1]);
line([0.5 68.5], [34.5 34.5], 'Color', [0 0 1]);
line([68.5 0.5], [68.5 0.5], 'Color', [0 0 1]);
saveas(gcf, './output/edge_density.png');
close all;

% cleaned streamline count
figure();
colormap('hot');
imagesc(log10(omat(:,:,10)));
axis('square'); axis('equal'); axis('tight');
title('Log_{10} LiFE');
xlabel('FS DK Regions');
ylabel('FS DK Regions');
y = colorbar;
ylabel(y, 'Log_{10} of LiFE EMD');
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 'YTick', []);
line([34.5 34.5], [0.5 68.5], 'Color', [0 0 1]);
line([0.5 68.5], [34.5 34.5], 'Color', [0 0 1]);
line([68.5 0.5], [68.5 0.5], 'Color', [0 0 1]);
saveas(gcf, './output/edge_LiFE.png');
close all;

