function [] = main()

disp('loading paths')
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))
addpath(genpath('/N/u/hayashis/BigRed2/git/mba'))

% load my own config.json
config = loadjson('config.json');

% run the network generation process - condensed to a funcion
[ emat, cmat, pconn, out, nmat, imat ] = feMatrixFromTensor_clean(config.fe, 'rois', config.cachedir, 16);

% save the outputs
mkdir('output');
save('output/emat.mat', emat);
save('output/cmat.mat', cmat);
save('output/pconn.mat', pconn);
save('output/out.mat', out);
save('output/mat.mat', nmat);
save('output/imat.mat', imat);

%% create and save some plots

% uncleaned streamline count
figure();
colormap('hot');
imagesc(log(emat(:,:,2)));
axis('square'); axis('equal'); axis('tight');
title('Log Streamline Density');
xlabel('FS DK Regions');
ylabel('FS DK Regions');
y = colorbar;
ylabel(y, 'Log Density of Streamlines');
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 'YTick', []);
line([34.5 34.5], [0.5 68.5], 'Color', [0 0 1]);
line([0.5 68.5], [34.5 34.5], 'Color', [0 0 1]);
line([68.5 0.5], [68.5 0.5], 'Color', [0 0 1]);
saveas(gcf, './uncleaned_edge_density.png');
close all;

% cleaned streamline count
figure();
colormap('hot');
imagesc(log(cmat(:,:,2)));
axis('square'); axis('equal'); axis('tight');
title('Cleaned Log Streamline Density');
xlabel('FS DK Regions');
ylabel('FS DK Regions');
y = colorbar;
ylabel(y, 'Log Density of Streamlines');
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 'YTick', []);
line([34.5 34.5], [0.5 68.5], 'Color', [0 0 1]);
line([0.5 68.5], [34.5 34.5], 'Color', [0 0 1]);
line([68.5 0.5], [68.5 0.5], 'Color', [0 0 1]);
saveas(gcf, './cleaned_edge_density.png');
close all;

% uncleaned EMD
figure();
colormap('hot');
imagesc(log(emat(:,:,10)));
axis('square'); axis('equal'); axis('tight');
title('EMD');
xlabel('FS DK Regions');
ylabel('FS DK Regions');
y = colorbar;
ylabel(y, 'Log Scanner Units');
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 'YTick', []);
line([34.5 34.5], [0.5 68.5], 'Color', [0 0 1]);
line([0.5 68.5], [34.5 34.5], 'Color', [0 0 1]);
line([68.5 0.5], [68.5 0.5], 'Color', [0 0 1]);
saveas(gcf, './uncleaned_edge_emd.png');
close all;

% cleaned EMD
figure();
colormap('hot');
imagesc(log(cmat(:,:,10)));
axis('square'); axis('equal'); axis('tight');
title('Cleaned EMD');
xlabel('FS DK Regions');
ylabel('FS DK Regions');
y = colorbar;
ylabel(y, 'Log Scanner Units');
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 'YTick', []);
line([34.5 34.5], [0.5 68.5], 'Color', [0 0 1]);
line([0.5 68.5], [34.5 34.5], 'Color', [0 0 1]);
line([68.5 0.5], [68.5 0.5], 'Color', [0 0 1]);
saveas(gcf, './cleaned_edge_emd.png');
close all;

