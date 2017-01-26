function [] = main()

disp('loading paths')
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))
addpath(genpath('/N/u/hayashis/BigRed2/git/afq'))

% load my own config.json
config = loadjson('config.json');

%% run the network generation process - condensed to a funcion

[ emat, cmat, pconn, out, nmat, imat ] = feMatrixFromTensor_clean(config.fe, config.fsdir, config.cachedir, config.ncores);

% save the outputs
save('emat.mat', emat);
save('cmat.mat', cmat);
save('pconn.mat', pconn);
save('out.mat', out);
save('nmat.mat', nmat);
save('imat.mat', imat);

