function [] = main()

disp('loading paths')
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))

% load my own config.json
config = loadjson('config.json');

% run the network generation process - condensed to a funcion
[ emat, cmat, pconn, out, nmat, imat ] = feMatrixFromTensor_clean(config.fe, 'rois', config.cachedir, config.ncores);

% save the outputs
mkdir('output');
save('output/emat.mat', emat);
save('output/cmat.mat', cmat);
save('output/pconn.mat', pconn);
save('output/out.mat', out);
save('output/mat.mat', nmat);
save('output/imat.mat', imat);

