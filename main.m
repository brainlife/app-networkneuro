function [] = main()

disp('loading paths')
addpath(genpath('/N/u/hayashis/BigRed2/git/encode'))
addpath(genpath('/N/u/hayashis/BigRed2/git/vistasoft'))
addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))
addpath(genpath('/N/u/hayashis/BigRed2/git/afq'))

% load my own config.json
config = loadjson('config.json');

% Load an FE strcuture specified in the config.fe
load(config.fe);

fprintf('TODO - freesurfer outdir: %s\n', config.freesurfer);

% Extract the fascicle weights from the fe structure
% Dependency "encode".
w = feGet(fe,'fiber weights');

% Extract the fascicles
fg = feGet(fe,'fibers acpc');        

% Eliminte the fascicles with non-zero entries
% Dependency "vistasoft"
fg = fgExtract(fg, w > 0, 'keep');

