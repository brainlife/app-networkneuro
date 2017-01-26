function [ emat, cmat, pconn, out, nmat, imat ] = feMatrixFromTensor_clean(feStruc, roiDir, cacheDir, nclust) 
%% development of tensor based matrix construction that performs cleaning on edges
% Brent McPherson
% 20170125
% 
% removed hard-coded paths to generalize for release
% statistics calculation removed for better compartmentalization
% return the 12 networks I use along with intermediary outputs of extra analyses
% still use a folder of ROIs
%
% need to point / link ROIs to a single folder by subject
% insert cleaning of edge w/ vistasoft
% update virtual lesion call
%
% example:
% feStruc  = '/N/dc2/projects/lifebid/glue/subjects/100063/fibers/fe_100063_prob_lmax8_500000.mat';
% roiDir   = '/N/dc2/projects/lifebid/glue/subjects/100063/anat/DKAtlas';
% cacheDir = '/N/dc2/projects/lifebid/glue/matlab/parCache';
% nclust   = 8;

%% check for fxns on path?
% parpool
% dtiImportRoiFromNifti
% mrAnatXformCoords
% BCT
% arguments for cleaning parameters, 3 default

%% load data / ROIs

display('Loading fe structure...');
load(feStruc);

display('Indexing ROIs...');

% index ROI folder
findx = dir(roiDir);

% find any nested folders to ignore (catchs ./, ../)
fldrs = ~cell2mat({findx.isdir});

% pull file names
fname = {findx.name};

% index ROI names correctly
roiNames = fname(fldrs);

%% start parallel pool

% start parallel pool for fefgGet
display(['Opening parallel pool with ', num2str(nclust), ' cores...']);

% create parallel cluster object
c = parcluster;

% set number of cores from arguments
c.NumWorkers = nclust;

% set temporary cache directory
t = tempname(cacheDir);

% make cache dir
OK = mkdir(t);

% check and set cachedir location
if OK
    % set local storage for parpool
    c.JobStorageLocation = t;
end

% start parpool
parpool(c, nclust, 'IdleTimeout', 720);

% convert all fiber nodes to voxel coord indices in tensor
display('Finding nodes...');

%% pull fiber properties for endpoint assignment 

fibNodeIndices = fefgGet(fe.fg, 'nodes2voxels', fe.roi.coords); % ~2 hours
fibLength = fefgGet(fe.fg, 'length'); % instantly

%% find fibers in each loaded ROI

display('Finding ROI fibers...');

% for every roi 
for ii = 1:length(roiNames)
    
    % put ROI name in output
    out{ii}.name = roiNames{ii};
    
    % load ROI
    roi = dtiImportRoiFromNifti(fullfile(roiDir, roiNames{ii}));
    
    % grab size of ROI fibers in output object
    out{ii}.vxsize = size(roi.coords, 1);
    
    % transform roi coordinates into image space for tensor
    vx.coords = mrAnatXformCoords(fe.life.xform.acpc2img, roi.coords);
    
    % round xformed coords like dtiExportRoiToNifti
    vx.coords = ceil(vx.coords);
    % CAUSES OVERLAP IN ROIS AND SUBSEQUENTLY FIBERS
    % USE APARC+ASEG IMAGE DIRECTLY - next improvement
    % OR COMPROMISE FIBER ASSIGNMENT - fix this post hoc
    
    % keep coordinates to speed up fiber check
    out{ii}.vxroi = vx.coords;
    
    % find the transformed ROI coordinates in the fe object and return the
    % indices. These are the fe.roi.coords' indices to find fibers in tensor
    % the coordinate logical (c)index
    vx.cindex = ismember(fe.roi.coords, vx.coords, 'rows');
    
    % convert logical of fe.roi.coords to indices of fe.roi.coords for
    % subsetting fibers in sptensor
    vx.index = find(vx.cindex);
    
    % create sub-index of sptensor for fibers to keep
    [ inds1, ~ ] = find(fe.life.M.Phi(:, vx.index, :));
    
    % This failed one job - why?
    % pull unique intersecting fiber indices into output object
    if size(inds1) > 0
        out{ii}.int.fibers = unique(inds1(:, 3));
    else
        out{ii}.int.fibers = [];
    end
    
    % pull fiber node indices for subset of fibers intersecting ROI
    vx.nodes = fibNodeIndices(out{ii}.int.fibers);
    
    % for every fiber intersecting the ROIs, find the 2 end points
    % able to back-track end points by +/- indices into endpoint cell-array
    
    for jj = 1:length(vx.nodes)
        vx.ep(jj, 1) = vx.nodes{jj}(1);
        vx.ep(jj, 2) = vx.nodes{jj}(length(vx.nodes{jj}));
    end
    
    % redo the logic above w/ endpoint indices
    
    % fiber endpoints of indices found within ROI
    % must do separately to maintain logical order
    vx.ep1indx = ismember(vx.ep(:,1), vx.index, 'rows');
    vx.ep2indx = ismember(vx.ep(:,2), vx.index, 'rows');
    
    % convert logical of endpoint indices to index value of int.fibers
    vx.lep1 = find(vx.ep1indx);
    vx.lep2 = find(vx.ep2indx);
    
    % find unique end point indices
    vx.uep = unique([vx.lep1; vx.lep2]);
    
    % combine unique fiber endpoint indices to id fiber indices
    % index into out{ii}.int.fibers to pull right fiber indices
    out{ii}.end.fibers = out{ii}.int.fibers(vx.uep);
    
    % id non-endpoint intersecting fibers
    out{ii}.nid.fibers = setdiff(out{ii}.int.fibers, out{ii}.end.fibers);
    
    % additional info (fiber length / fiber weights)
    
    % catch output number of nodes in each fiber
    out{ii}.int.lengths = fibLength(out{ii}.int.fibers);
    out{ii}.end.lengths = fibLength(out{ii}.end.fibers);
    out{ii}.nid.lengths = fibLength(out{ii}.nid.fibers);
    
    % weights of fibers
    out{ii}.int.weights = fe.life.fit.weights(out{ii}.int.fibers);
    out{ii}.end.weights = fe.life.fit.weights(out{ii}.end.fibers);
    out{ii}.nid.weights = fe.life.fit.weights(out{ii}.nid.fibers);
    
    % weighted fibers
    
    % weighted fiber intersections
    nzint = out{ii}.int.weights > 0;
    out{ii}.int.nzfibs = out{ii}.int.fibers(nzint);
    out{ii}.int.nzleng = out{ii}.int.lengths(nzint);
    out{ii}.int.nzwght = out{ii}.int.weights(nzint);
    
    % weighted endpoint intersections
    nzend = out{ii}.end.weights > 0;
    out{ii}.end.nzfibs = out{ii}.end.fibers(nzend);
    out{ii}.end.nzleng = out{ii}.end.lengths(nzend);
    out{ii}.end.nzwght = out{ii}.end.weights(nzend);
    
    % weighted non-endpoint intersections
    nzend = out{ii}.nid.weights > 0;
    out{ii}.nid.nzfibs = out{ii}.nid.fibers(nzend);
    out{ii}.nid.nzleng = out{ii}.nid.lengths(nzend);
    out{ii}.nid.nzwght = out{ii}.nid.weights(nzend);
    
    clear roi vx inds1 jj nzint nzend 
end

% clean up workspace
clear ii roi vx inds1 jj nzint nzend

%% for every unique combinations' intersection, find fiber indices

display('Finding edge between each ROI pairing...');

% create combinations
pairs = nchoosek(1:length(roiNames), 2);

% for every unique pair, find intersecting fibers
for ii = 1:length(pairs)
    
    % pull output regions into tmp objects for clarity of code
    reg1 = out{pairs(ii, 1)};
    reg2 = out{pairs(ii, 2)};
    
    % grab roi names
    pconn{ii}.roi1 = strrep(reg1.name, '.nii.gz', '');
    pconn{ii}.roi2 = strrep(reg2.name, '.nii.gz', '');
    
    % do the rois intersect
    pconn{ii}.intersect = size(intersect(reg1.vxroi, reg2.vxroi, 'rows'), 1) > 0;
    
    % grab roi coords
    % this is a lot of info - necessary?
    pconn{ii}.roi1vx = size(reg1.vxroi, 1);
    pconn{ii}.roi2vx = size(reg2.vxroi, 1);
    pconn{ii}.roisvx = pconn{ii}.roi1vx + pconn{ii}.roi2vx;
    %pconn{ii}.roisvx = [reg1.vxroi; reg2.vxroi];
    
    % find fiber intersections
    [ pconn{ii}.int.fibers, ind, ~ ] = intersect(reg1.int.fibers, reg2.int.fibers);
    pconn{ii}.int.lengths = reg1.int.lengths(ind);
    pconn{ii}.int.weights = reg1.int.weights(ind);
    
    % find non-zero fiber intersections
    [ pconn{ii}.int.nzfibs, ind, ~ ] = intersect(reg1.int.nzfibs, reg2.int.nzfibs);
    pconn{ii}.int.nzleng = reg1.int.nzleng(ind);
    pconn{ii}.int.nzwght = reg1.int.nzwght(ind);
    
    % find endpoint intersections
    [ pconn{ii}.end.fibers, ind, ~ ] = intersect(reg1.end.fibers, reg2.end.fibers);
    pconn{ii}.end.lengths = reg1.end.lengths(ind);
    pconn{ii}.end.weights = reg1.end.weights(ind);
    
    % find non-zero endpoint intersections
    [ pconn{ii}.end.nzfibs, ind, ~ ] = intersect(reg1.end.nzfibs, reg2.end.nzfibs);
    pconn{ii}.end.nzleng = reg1.end.nzleng(ind);
    pconn{ii}.end.nzwght = reg1.end.nzwght(ind);
    
    % find endpoint to non-endpoint intersections
    [ pconn{ii}.nid1.fibers, ind, ~ ] = intersect(reg1.end.fibers, reg2.nid.fibers);
    pconn{ii}.nid1.lengths = reg1.end.lengths(ind);
    pconn{ii}.nid1.weights = reg1.end.weights(ind);
    
    % find non-zero endpoint to non-endpoint intersections
    [ pconn{ii}.nid1.nzfibs, ind, ~ ] = intersect(reg1.end.nzfibs, reg2.nid.nzfibs);
    pconn{ii}.nid1.nzleng = reg1.end.lengths(ind);
    pconn{ii}.nid1.nzwght = reg1.end.weights(ind);
    
    % find endpoint to non-endpoint intersections
    [ pconn{ii}.nid2.fibers, ind, ~ ] = intersect(reg2.end.fibers, reg1.nid.fibers);
    pconn{ii}.nid2.lengths = reg2.end.lengths(ind);
    pconn{ii}.nid2.weights = reg2.end.weights(ind);
    
    % find non-zero endpoint to non-endpoint intersections
    [ pconn{ii}.nid2.nzfibs, ind, ~ ] = intersect(reg2.end.nzfibs, reg1.nid.nzfibs);
    pconn{ii}.nid2.nzleng = reg2.end.lengths(ind);
    pconn{ii}.nid2.nzwght = reg2.end.weights(ind);
    
end

clear reg1 reg2

%% remove fibers identified multiple times within each pair

display('Removing duplicate fibers...');

% for every unique pair of pairs
comb = nchoosek(1:length(pairs), 2);

for ii = 1:size(comb, 1)
    [ ~, pt1, pt2 ] = setxor(pconn{comb(ii,1)}.int.fibers, pconn{comb(ii,2)}.int.fibers);
    pconn{comb(ii,1)}.int.fibers = pconn{comb(ii,1)}.int.fibers(pt1);
    pconn{comb(ii,1)}.int.lengths = pconn{comb(ii,1)}.int.lengths(pt1);
    pconn{comb(ii,1)}.int.weights = pconn{comb(ii,1)}.int.weights(pt1);
    pconn{comb(ii,2)}.int.fibers = pconn{comb(ii,2)}.int.fibers(pt2);
    pconn{comb(ii,2)}.int.lengths = pconn{comb(ii,2)}.int.lengths(pt2);
    pconn{comb(ii,2)}.int.weights = pconn{comb(ii,2)}.int.weights(pt2);
    
    [ ~, pt1, pt2 ] = setxor(pconn{comb(ii,1)}.int.nzfibs, pconn{comb(ii,2)}.int.nzfibs);
    pconn{comb(ii,1)}.int.nzfibs = pconn{comb(ii,1)}.int.nzfibs(pt1);
    pconn{comb(ii,1)}.int.nzleng = pconn{comb(ii,1)}.int.nzleng(pt1);
    pconn{comb(ii,1)}.int.nzwght = pconn{comb(ii,1)}.int.nzwght(pt1);
    pconn{comb(ii,2)}.int.nzfibs = pconn{comb(ii,2)}.int.nzfibs(pt2);
    pconn{comb(ii,2)}.int.nzleng = pconn{comb(ii,2)}.int.nzleng(pt2);
    pconn{comb(ii,2)}.int.nzwght = pconn{comb(ii,2)}.int.nzwght(pt2);
    
    % find indices of each non overlapping end fiber and keep just the unique indices
    [ ~, pt1, pt2 ] = setxor(pconn{comb(ii,1)}.end.fibers, pconn{comb(ii,2)}.end.fibers);
    pconn{comb(ii,1)}.end.fibers = pconn{comb(ii,1)}.end.fibers(pt1);
    pconn{comb(ii,1)}.end.lengths = pconn{comb(ii,1)}.end.lengths(pt1);
    pconn{comb(ii,1)}.end.weights = pconn{comb(ii,1)}.end.weights(pt1);
    pconn{comb(ii,2)}.end.fibers = pconn{comb(ii,2)}.end.fibers(pt2);
    pconn{comb(ii,2)}.end.lengths = pconn{comb(ii,2)}.end.lengths(pt2);
    pconn{comb(ii,2)}.end.weights = pconn{comb(ii,2)}.end.weights(pt2);
    
    [ ~, pt1, pt2 ] = setxor(pconn{comb(ii,1)}.end.nzfibs, pconn{comb(ii,2)}.end.nzfibs);
    pconn{comb(ii,1)}.end.nzfibs = pconn{comb(ii,1)}.end.nzfibs(pt1);
    pconn{comb(ii,1)}.end.nzleng = pconn{comb(ii,1)}.end.nzleng(pt1);
    pconn{comb(ii,1)}.end.nzwght = pconn{comb(ii,1)}.end.nzwght(pt1);
    pconn{comb(ii,2)}.end.nzfibs = pconn{comb(ii,2)}.end.nzfibs(pt2);
    pconn{comb(ii,2)}.end.nzleng = pconn{comb(ii,2)}.end.nzleng(pt2);
    pconn{comb(ii,2)}.end.nzwght = pconn{comb(ii,2)}.end.nzwght(pt2);
    
    % find indices of each non overlapping nid1 fiber and keep just the unique indices
    [ ~, pt1, pt2 ] = setxor(pconn{comb(ii,1)}.nid1.fibers, pconn{comb(ii,2)}.nid1.fibers);
    pconn{comb(ii,1)}.nid1.fibers = pconn{comb(ii,1)}.nid1.fibers(pt1);
    pconn{comb(ii,1)}.nid1.lengths = pconn{comb(ii,1)}.nid1.lengths(pt1);
    pconn{comb(ii,1)}.nid1.weights = pconn{comb(ii,1)}.nid1.weights(pt1);
    pconn{comb(ii,2)}.nid1.fibers = pconn{comb(ii,2)}.nid1.fibers(pt2);
    pconn{comb(ii,2)}.nid1.lengths = pconn{comb(ii,2)}.nid1.lengths(pt2);
    pconn{comb(ii,2)}.nid1.weights = pconn{comb(ii,2)}.nid1.weights(pt2);
    
    [ ~, pt1, pt2 ] = setxor(pconn{comb(ii,1)}.nid1.nzfibs, pconn{comb(ii,2)}.nid1.nzfibs);
    pconn{comb(ii,1)}.nid1.nzfibs = pconn{comb(ii,1)}.nid1.nzfibs(pt1);
    pconn{comb(ii,1)}.nid1.nzleng = pconn{comb(ii,1)}.nid1.nzleng(pt1);
    pconn{comb(ii,1)}.nid1.nzwght = pconn{comb(ii,1)}.nid1.nzwght(pt1);
    pconn{comb(ii,2)}.nid1.nzfibs = pconn{comb(ii,2)}.nid1.nzfibs(pt2);
    pconn{comb(ii,2)}.nid1.nzleng = pconn{comb(ii,2)}.nid1.nzleng(pt2);
    pconn{comb(ii,2)}.nid1.nzwght = pconn{comb(ii,2)}.nid1.nzwght(pt2);
    
    % find indices of each non overlapping nid2 fiber and keep just the unique indices
    [ ~, pt1, pt2 ] = setxor(pconn{comb(ii,1)}.nid2.fibers, pconn{comb(ii,2)}.nid2.fibers);
    pconn{comb(ii,1)}.nid2.fibers = pconn{comb(ii,1)}.nid2.fibers(pt1);
    pconn{comb(ii,1)}.nid2.lengths = pconn{comb(ii,1)}.nid2.lengths(pt1);
    pconn{comb(ii,1)}.nid2.weights = pconn{comb(ii,1)}.nid2.weights(pt1);
    pconn{comb(ii,2)}.nid2.fibers = pconn{comb(ii,2)}.nid2.fibers(pt2);
    pconn{comb(ii,2)}.nid2.lengths = pconn{comb(ii,2)}.nid2.lengths(pt2);
    pconn{comb(ii,2)}.nid2.weights = pconn{comb(ii,2)}.nid2.weights(pt2);
    
    [ ~, pt1, pt2 ] = setxor(pconn{comb(ii,1)}.nid2.nzfibs, pconn{comb(ii,2)}.nid2.nzfibs);
    pconn{comb(ii,1)}.nid2.nzfibs = pconn{comb(ii,1)}.nid2.nzfibs(pt1);
    pconn{comb(ii,1)}.nid2.nzleng = pconn{comb(ii,1)}.nid2.nzleng(pt1);
    pconn{comb(ii,1)}.nid2.nzwght = pconn{comb(ii,1)}.nid2.nzwght(pt1);
    pconn{comb(ii,2)}.nid2.nzfibs = pconn{comb(ii,2)}.nid2.nzfibs(pt2);
    pconn{comb(ii,2)}.nid2.nzleng = pconn{comb(ii,2)}.nid2.nzleng(pt2);
    pconn{comb(ii,2)}.nid2.nzwght = pconn{comb(ii,2)}.nid2.nzwght(pt2);
end

clear comb ii pt1 pt2

% run all the cleaning in a loop

display('Cleaning outlier fibers from individual connections...');

for ii = 1:length(pconn)
    
    % clean fibers in a connection - all fibers / non-zero fibers
    tafg = fgCreate('name', 'cnFG', 'colorRgb', [0 1 0], 'fibers', {fe.fg.fibers{pconn{ii}.end.fibers}}');
    tzfg = fgCreate('name', 'nzFG', 'colorRgb', [0 1 0], 'fibers', {fe.fg.fibers{pconn{ii}.end.nzfibs}}');
    
    % if the whole connection is empty, set as 0 and skip
    if isempty(tafg.fibers)
        
        % assign empty connections as 0
        pconn{ii}.vxend = double.empty(0, 3);
        pconn{ii}.vxcln = double.empty(0, 3);
        pconn{ii}.cln.fibers  = double.empty(0, 1);
        pconn{ii}.cln.lengths = double.empty(0, 1);
        pconn{ii}.cln.weights = double.empty(0, 1);
        pconn{ii}.cln.nzfibs  = double.empty(0, 1);
        pconn{ii}.cln.nzleng  = double.empty(0, 1);
        pconn{ii}.cln.nzwght  = double.empty(0, 1);
        continue;
        
    end
    
    % otherwise perform cleaning - replace default 3 with a parameter
    [ tafg, akeep ] = mbaComputeFibersOutliers(tafg, 3, 3, 100, 'mean', 0, 10);
    
    % catch the indices here
    pconn{ii}.vxend = fefgGet(tafg, 'unique image coords');
    
    % catch indices of all cleaned fibers
    pconn{ii}.cln.fibers  = pconn{ii}.end.fibers(akeep);
    pconn{ii}.cln.lengths = pconn{ii}.end.lengths(akeep);
    pconn{ii}.cln.weights = pconn{ii}.end.weights(akeep);
    
    % if the non-zero fibers are empty, set to 0 and skip
    if isempty(tzfg.fibers)
        
        % assign empty connections as 0
        pconn{ii}.vxcln = double.empty(0, 3);
        pconn{ii}.cln.nzfibs  = double.empty(0, 1);
        pconn{ii}.cln.nzleng  = double.empty(0, 1);
        pconn{ii}.cln.nzwght  = double.empty(0, 1);
        continue;
        
    end
    
    % otherwise perform cleaning
    [ tzfg, zkeep ] = mbaComputeFibersOutliers(tzfg, 3, 3, 100, 'mean', 0, 10);
    
    % catch the indices here
    pconn{ii}.vxcln = fefgGet(tzfg, 'unique image coords');
    
    % catch indices of cleaned non-zero fibers
    pconn{ii}.cln.nzfibs = pconn{ii}.end.nzfibs(zkeep);
    pconn{ii}.cln.nzleng = pconn{ii}.end.nzleng(zkeep);
    pconn{ii}.cln.nzwght = pconn{ii}.end.nzwght(zkeep);
    
    clear tafg tzfg akeep zkeep
    
end

clear ii tafg tzfg akeep zkeep

% emat is endpoints (fixed), imat is intersection (old) 
% [e|i]mat will be 16:
% count/dens/leng/denLeng
% nzLiFE of count/dens/leng/denLeng
% wghtSum/wghtWght/wghtDens/wghtLeng
% SOE/EMD/VL1/VL2
% 
% nmat is 1 asym-matrix of endpoints to non-endpoint intersection
%

% run virtual - catch relevant outputs; ~ 3 hours
display('Running virtual lesion...');

% add cleaning before estimation of virtual lesion
% drop VL of intersect connections, add cleaned
% 

for ii = 1:length(pconn)
   
    % virtual lesion on end points
    try
        [ ewVL, ewoVL ] = feComputeVirtualLesion(fe, pconn{ii}.end.nzfibs);
        pconn{ii}.end.vl = feComputeEvidence(ewoVL, ewVL);
        
    catch  
        pconn{ii}.end.vl.s.mean = 0;
        pconn{ii}.end.vl.em.mean = 0;
        pconn{ii}.end.vl.j.mean = 0;
        pconn{ii}.end.vl.kl.mean = 0;
    end
    
    % virtual lesion on cleaned fibers
    try
        
        % run VL only on the cleaned NZ fibers
        [ cwVL, cwoVL ] = feComputeVirtualLesion(fe, pconn{ii}.cln.nzfibs);
        pconn{ii}.cln.vl = feComputeEvidence(cwoVL, cwVL);
        
    catch
        
        pconn{ii}.cln.vl.s.mean = 0;
        pconn{ii}.cln.vl.em.mean = 0;
        pconn{ii}.cln.vl.j.mean = 0;
        pconn{ii}.cln.vl.kl.mean = 0;
    end
    
    clear ewVL ewoVL cwVL cwoVL
    
end

display('Create output matrices...');

% create empty output matrix
emat = zeros(size(roiNames, 2), size(roiNames, 2), 12);
cmat = zeros(size(roiNames, 2), size(roiNames, 2), 12); % add cleaned matrices 
imat = zeros(size(roiNames, 2), size(roiNames, 2), 8); % loses VL output
nmat = zeros(size(roiNames, 2), size(roiNames, 2), 1);

% create matrix outputs
for ii = 1:length(pairs)
    
    % 01. fiber count
    ifc = length(pconn{ii}.int.fibers);
    imat(pairs(ii, 1), pairs(ii, 2), 1) = ifc;
    imat(pairs(ii, 2), pairs(ii, 1), 1) = ifc;

    efc = length(pconn{ii}.end.fibers);
    emat(pairs(ii, 1), pairs(ii, 2), 1) = efc;
    emat(pairs(ii, 2), pairs(ii, 1), 1) = efc;
    
    cfc = length(pconn{ii}.cln.fibers);
    cmat(pairs(ii, 1), pairs(ii, 2), 1) = cfc;
    cmat(pairs(ii, 2), pairs(ii, 1), 1) = cfc;
    
    % 02. fiber density
    ifd = 2 * ifc / pconn{ii}.roisvx;
    imat(pairs(ii, 1), pairs(ii, 2), 2) = ifd;
    imat(pairs(ii, 2), pairs(ii, 1), 2) = ifd;

    efd = 2 * efc / pconn{ii}.roisvx;
    emat(pairs(ii, 1), pairs(ii, 2), 2) = efd;
    emat(pairs(ii, 2), pairs(ii, 1), 2) = efd;
    
    cfd = 2 * cfc / pconn{ii}.roisvx;
    cmat(pairs(ii, 1), pairs(ii, 2), 2) = cfd;
    cmat(pairs(ii, 2), pairs(ii, 1), 2) = cfd;
    
    % 03. fiber length
    ifl = (1 / ifc) * sum(pconn{ii}.int.lengths);
    imat(pairs(ii, 1), pairs(ii, 2), 3) = ifl;
    imat(pairs(ii, 2), pairs(ii, 1), 3) = ifl;

    efl = (1 / efc) * sum(pconn{ii}.end.lengths);
    emat(pairs(ii, 1), pairs(ii, 2), 3) = efl;
    emat(pairs(ii, 2), pairs(ii, 1), 3) = efl;
    
    cfl = (1 / cfc) * sum(pconn{ii}.cln.lengths);
    cmat(pairs(ii, 1), pairs(ii, 2), 3) = cfl;
    cmat(pairs(ii, 2), pairs(ii, 1), 3) = cfl;
    
    % 04. fiber density * length
    ifdl = (2 / pconn{ii}.roisvx) * sum(1 / pconn{ii}.int.lengths);
    imat(pairs(ii, 1), pairs(ii, 2), 4) = ifdl;
    imat(pairs(ii, 2), pairs(ii, 1), 4) = ifdl;

    efdl = (2 / pconn{ii}.roisvx) * sum(1 / pconn{ii}.end.lengths);
    emat(pairs(ii, 1), pairs(ii, 2), 4) = efdl;
    emat(pairs(ii, 2), pairs(ii, 1), 4) = efdl;
    
    cfdl = (2 / pconn{ii}.roisvx) * sum(1 / pconn{ii}.cln.lengths);
    cmat(pairs(ii, 1), pairs(ii, 2), 4) = cfdl;
    cmat(pairs(ii, 2), pairs(ii, 1), 4) = cfdl;
    
    % 05. nz fiber count
    wifc = length(pconn{ii}.int.nzfibs);
    imat(pairs(ii, 1), pairs(ii, 2), 5) = wifc;
    imat(pairs(ii, 2), pairs(ii, 1), 5) = wifc;

    wefc = length(pconn{ii}.end.nzfibs);
    emat(pairs(ii, 1), pairs(ii, 2), 5) = wefc;
    emat(pairs(ii, 2), pairs(ii, 1), 5) = wefc;
    
    wcfc = length(pconn{ii}.cln.nzfibs);
    cmat(pairs(ii, 1), pairs(ii, 2), 5) = wcfc;
    cmat(pairs(ii, 2), pairs(ii, 1), 5) = wcfc;
    
    % 06. nz fiber density
    wifd = 2 * wifc / pconn{ii}.roisvx;
    imat(pairs(ii, 1), pairs(ii, 2), 6) = wifd;
    imat(pairs(ii, 2), pairs(ii, 1), 6) = wifd;

    wefd = 2 * wefc / pconn{ii}.roisvx;
    emat(pairs(ii, 1), pairs(ii, 2), 6) = wefd;
    emat(pairs(ii, 2), pairs(ii, 1), 6) = wefd;
    
    wcfd = 2 * wcfc / pconn{ii}.roisvx;
    cmat(pairs(ii, 1), pairs(ii, 2), 6) = wcfd;
    cmat(pairs(ii, 2), pairs(ii, 1), 6) = wcfd;
    
    % 07. nz fiber length
    wifl = (1 / wifc) * sum(pconn{ii}.int.nzleng);
    imat(pairs(ii, 1), pairs(ii, 2), 7) = wifl;
    imat(pairs(ii, 2), pairs(ii, 1), 7) = wifl;

    wefl = (1 / wefc) * sum(pconn{ii}.end.nzleng);
    emat(pairs(ii, 1), pairs(ii, 2), 7) = wefl;
    emat(pairs(ii, 2), pairs(ii, 1), 7) = wefl;
    
    wcfl = (1 / wcfc) * sum(pconn{ii}.cln.nzleng);
    cmat(pairs(ii, 1), pairs(ii, 2), 7) = wcfl;
    cmat(pairs(ii, 2), pairs(ii, 1), 7) = wcfl;
    
    % 08. nz fiber density * length
    wifdl = (2 / pconn{ii}.roisvx) * sum(1 / pconn{ii}.int.nzleng);
    imat(pairs(ii, 1), pairs(ii, 2), 8) = wifdl;
    imat(pairs(ii, 2), pairs(ii, 1), 8) = wifdl;

    wefdl = (2 / pconn{ii}.roisvx) * sum(1 / pconn{ii}.end.nzleng);
    emat(pairs(ii, 1), pairs(ii, 2), 8) = wefdl;
    emat(pairs(ii, 2), pairs(ii, 1), 8) = wefdl;
    
    wcfdl = (2 / pconn{ii}.roisvx) * sum(1 / pconn{ii}.cln.nzleng);
    cmat(pairs(ii, 1), pairs(ii, 2), 8) = wcfdl;
    cmat(pairs(ii, 2), pairs(ii, 1), 8) = wcfdl;
    
    % 9. SOE
    %imat(pairs(ii, 1), pairs(ii, 2), 9) = pconn{ii}.int.vl.s.mean;
    %imat(pairs(ii, 2), pairs(ii, 1), 9) = pconn{ii}.int.vl.s.mean;
    
    emat(pairs(ii, 1), pairs(ii, 2), 9) = pconn{ii}.end.vl.s.mean;
    emat(pairs(ii, 2), pairs(ii, 1), 9) = pconn{ii}.end.vl.s.mean;
    
    cmat(pairs(ii, 1), pairs(ii, 2), 9) = pconn{ii}.cln.vl.s.mean;
    cmat(pairs(ii, 2), pairs(ii, 1), 9) = pconn{ii}.cln.vl.s.mean;
    
    % 10. EMD
    %imat(pairs(ii, 1), pairs(ii, 2), 10) = pconn{ii}.int.vl.em.mean;
    %imat(pairs(ii, 2), pairs(ii, 1), 10) = pconn{ii}.int.vl.em.mean;
    
    emat(pairs(ii, 1), pairs(ii, 2), 10) = pconn{ii}.end.vl.em.mean;
    emat(pairs(ii, 2), pairs(ii, 1), 10) = pconn{ii}.end.vl.em.mean;
    
    cmat(pairs(ii, 1), pairs(ii, 2), 10) = pconn{ii}.cln.vl.em.mean;
    cmat(pairs(ii, 2), pairs(ii, 1), 10) = pconn{ii}.cln.vl.em.mean;
    
    % 11. Jeffery's Divergence
    %imat(pairs(ii, 1), pairs(ii, 2), 11) = pconn{ii}.int.vl.j.mean;
    %imat(pairs(ii, 2), pairs(ii, 1), 11) = pconn{ii}.int.vl.j.mean;
    
    emat(pairs(ii, 1), pairs(ii, 2), 11) = pconn{ii}.end.vl.j.mean;
    emat(pairs(ii, 2), pairs(ii, 1), 11) = pconn{ii}.end.vl.j.mean;
    
    cmat(pairs(ii, 1), pairs(ii, 2), 11) = pconn{ii}.cln.vl.j.mean;
    cmat(pairs(ii, 2), pairs(ii, 1), 11) = pconn{ii}.cln.vl.j.mean;
    
    % 12. Kullback-Leibler Divergence
    %imat(pairs(ii, 1), pairs(ii, 2), 12) = pconn{ii}.int.vl.kl.mean;
    %imat(pairs(ii, 2), pairs(ii, 1), 12) = pconn{ii}.int.vl.kl.mean;
    
    emat(pairs(ii, 1), pairs(ii, 2), 12) = pconn{ii}.end.vl.kl.mean;
    emat(pairs(ii, 2), pairs(ii, 1), 12) = pconn{ii}.end.vl.kl.mean;
    
    cmat(pairs(ii, 1), pairs(ii, 2), 12) = pconn{ii}.cln.vl.kl.mean;
    cmat(pairs(ii, 2), pairs(ii, 1), 12) = pconn{ii}.cln.vl.kl.mean;
    
    % create matrix output for endpoint to non-endpoint connectivity
    nmat(pairs(ii, 1), pairs(ii, 2), 1) = length(pconn{ii}.nid1.fibers);
    nmat(pairs(ii, 2), pairs(ii, 1), 1) = length(pconn{ii}.nid2.fibers);
    
    % clear temporary objects
    clear ifc ifd ifl ifdl wifc wifd wifl wifdl wisum wiwgh widen wwifl wifdl
    clear efc efd efl efdl wefc wefd wefl wefdl wesum wewgh weden wwefl wefdl
    clear cfc cfd cfl cfdl wcfc wcfd wcfl wcfdl wcsum wcwgh wcden wwcfl wcfdl

end

%% clean up matrices

% fix zeros / nan
for ii = 1:size(emat, 3)
    
    %ilen = imat(:,:,ii);
    %ilen(isnan(ilen)) = 0;
    %imat(:,:,ii) = ilen;
    
    elen = emat(:,:,ii);
    elen(isnan(elen)) = 0;
    emat(:,:,ii) = elen;
    
    clen = cmat(:,:,ii);
    clen(isnan(clen)) = 0;
    cmat(:,:,ii) = clen;
    
    %clear ilen elen clen
    clear elen clen
end

% isoe = imat(:,:,9);
% isoe(isoe < 0) = 0;
% imat(:,:,13) = isoe;

esoe = emat(:,:,9);
esoe(esoe < 0) = 0;
emat(:,:,13) = esoe;

csoe = cmat(:,:,9);
csoe(csoe < 0) = 0;
cmat(:,:,13) = csoe;

% ijd = imat(:,:,11);
% ijd(ijd < 0) = 0;
% imat(:,:,15) = ijd;

ejd = emat(:,:,11);
ejd(ejd < 0) = 0;
emat(:,:,15) = ejd;

cjd = cmat(:,:,11);
cjd(cjd < 0) = 0;
cmat(:,:,15) = cjd;

% ikl = imat(:,:,12);
% ikl(ikl < 0) = 0;
% imat(:,:,16) = ikl;

ekl = emat(:,:,12);
ekl(ekl < 0) = 0;
emat(:,:,16) = ekl;

ckl = cmat(:,:,12);
ckl(ckl < 0) = 0;
cmat(:,:,16) = ckl;

%clear isoe esoe csoe ijd ejd cjd ikl ekl ckl
clear esoe csoe ejd cjd ekl ckl

%% create and save some plots

% uncleaned streamline count
figure();
colormap('hot');
imagesc(log(emat(:,:,1)));
axis('square'); axis('equal'); axis('tight');
title('Streamline Count');
xlabel('FS DK Regions');
ylabel('FS DK Regions');
y = colorbar;
ylabel(y, 'Log Number of Streamlines');
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 'YTick', []);
line([34.5 34.5], [0.5 68.5], 'Color', [0 0 1]);
line([0.5 68.5], [34.5 34.5], 'Color', [0 0 1]);
line([68.5 0.5], [68.5 0.5], 'Color', [0 0 1]);
saveas(gcf, './uncleaned_edge_count.png');
close all;

% cleaned streamline count
figure();
colormap('hot');
imagesc(log(cmat(:,:,1)));
axis('square'); axis('equal'); axis('tight');
title('Cleaned Streamline Count');
xlabel('FS DK Regions');
ylabel('FS DK Regions');
y = colorbar;
ylabel(y, 'Log Number of Streamlines');
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'XTick', [], 'YTick', []);
line([34.5 34.5], [0.5 68.5], 'Color', [0 0 1]);
line([0.5 68.5], [34.5 34.5], 'Color', [0 0 1]);
line([68.5 0.5], [68.5 0.5], 'Color', [0 0 1]);
saveas(gcf, './cleaned_edge_count.png');
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

end

