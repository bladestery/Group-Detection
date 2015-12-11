% test.m: converts CUHK dataset with Groundtruths(Number of Groups) to netCDF files
% Authored by Ben Ruktantichoke

clc;clear;close all
files = dir;
directoryNames = {files([files.isdir]).name};
directoryNames = directoryNames(~ismember(directoryNames,{'.','..'}));
num = xlsread([pwd, '/../video_info_t0.xls'], 'Sheet3');
max_len = 0;
for i = 1 : length(directoryNames)
    folder = directoryNames{i};
    load([pwd, '/../ground_truth_grDetect/', folder, '_gt.mat'], 'groups');
    if max_len < length(groups)
       max_len = length(groups);
    end
end
max_len = 4;
target_str = zeros(3,max_len);
for j = 1 : max_len
    [Q,R] = quorem(sym(j),sym(10));
    if Q > 0
        target_str(1,j) = Q+48;
        target_str(2,j) = R+48;
    else
        target_str(1,j) = R+48;
    end
end
target_str = char(target_str);

for i = 1 : length(directoryNames)
    folder = directoryNames{i};
    fprintf('Processing: %s\n', folder);
    x_dim = num(i, 1);
    y_dim = num(i, 2);
    startframe = num(i, 3);
    stopframe = num(i, 4);
    %% Load Tracklets
    load([pwd, '/', folder, '/trks_1_smooth.mat'], 'trks');
    %% Load Groundtruths
    load([pwd, '/../ground_truth_grDetect/', folder, '_gt.mat'], 'groups');
    if length(groups) > 4
       continue; 
    end
    %% Find Groundtruths Tracklet and Separate them into their Groups
    idxs = ones(length(groups), 1);
    group_len = zeros(length(groups), 1);
    grp_trks(1:length(groups)) = struct;
    for j = 1: length(groups)
        grp_trks(j).x = {trks.x};
        grp_trks(j).y = {trks.y};
        grp_trks(j).t = {trks.t};
        group_len(j, 1) = length(groups{j});
    end
    accu = 1;
    len = length({trks.x});
    while accu <= len
        % fprintf('Processing Tracklet:%d\n', accu);
        for j = 1 : length(groups)
            % fprintf('Group: %d\taccu:%d\tidx:%d\tval:%d\n', j, accu, idxs(j), groups{j}(idxs(j)));
            if idxs(j) <= length(groups{j})
                if groups{j}(idxs(j)) == accu
                    matx = cell2mat(grp_trks(j).x(idxs(j)));
                    maty = cell2mat(grp_trks(j).y(idxs(j)));
                    grp_trks(j).x(idxs(j)) = mat2cell(round(matx / x_dim * 227), length(matx), 1);
                    grp_trks(j).y(idxs(j)) = mat2cell(round(maty / y_dim * 227), length(maty), 1);
                    idxs(j) = idxs(j) + 1;
                    % fprintf('Not Evict from group %d:\n', j);
                else
                    if accu == 1
                        grp_trks(j).x = grp_trks(j).x(1, 2:end);
                        grp_trks(j).y = grp_trks(j).y(1, 2:end);
                        grp_trks(j).t = grp_trks(j).t(1, 2:end);
                    elseif accu == len
                        grp_trks(j).x = grp_trks(j).x(1, 1:idxs(j)-1);
                        grp_trks(j).y = grp_trks(j).y(1, 1:idxs(j)-1);
                        grp_trks(j).t = grp_trks(j).t(1, 1:idxs(j)-1);
                    else
                        grp_trks(j).x = grp_trks(j).x(1, [1:idxs(j)-1, idxs(j)+1:end]);
                        grp_trks(j).y = grp_trks(j).y(1, [1:idxs(j)-1, idxs(j)+1:end]);
                        grp_trks(j).t = grp_trks(j).t(1, [1:idxs(j)-1, idxs(j)+1:end]);
                    end
                    % fprintf('Evicted from group %d:\n', j);
                end
            else
                if accu == 1
                    grp_trks(j).x = grp_trks(j).x(1, 2:end);
                    grp_trks(j).y = grp_trks(j).y(1, 2:end);
                    grp_trks(j).t = grp_trks(j).t(1, 2:end);
                elseif accu == len
                    grp_trks(j).x = grp_trks(j).x(1, 1:idxs(j)-1);
                    grp_trks(j).y = grp_trks(j).y(1, 1:idxs(j)-1);
                    grp_trks(j).t = grp_trks(j).t(1, 1:idxs(j)-1);
                else
                    grp_trks(j).x = grp_trks(j).x(1, [1:idxs(j)-1, idxs(j)+1:end]);
                    grp_trks(j).y = grp_trks(j).y(1, [1:idxs(j)-1, idxs(j)+1:end]);
                    grp_trks(j).t = grp_trks(j).t(1, [1:idxs(j)-1, idxs(j)+1:end]);
                end
                % fprintf('Evicted from group %d:\n', j);
            end
        end
        accu = accu + 1;
    end
    
    %% Build Data structures to be used in netCDF
    % fprintf('building dataset\n');
    x_dim = 227;
    y_dim = 227;
    res = x_dim*y_dim;
    len_seqs = (stopframe-startframe);
    num_seqs = 1;
    tot_len = res*len_seqs*num_seqs;
    seq_dims = zeros(3,num_seqs);
    seq_tags = cell(1,num_seqs);
    seq_lens = zeros(1,num_seqs);
    seq_tags(1,1) = cellstr(folder);
    seq_tags = char(seq_tags);
    seq_tags = seq_tags.';
    seq_lens(1,1) = res*len_seqs;
    seq_dims(1,1) = y_dim;
    seq_dims(2,1) = x_dim;
    seq_dims(3,1) = len_seqs;
    trcklets = zeros(1,tot_len);
    target = zeros(3,num_seqs);
    [Q,R] = quorem(sym(length(groups)),sym(10));
    if Q > 0
        target(1,1) = Q+48;
        target(2,1) = R+48;
    else
        target(1,1) = R+48;
    end
    target = char(target);
    for j = 1 : length(groups)
        % fprintf('processing group: %d\n', j+1);
        t = 0;
        while t < len_seqs
            t_offset = res*t;
            for z = 1 : length(grp_trks(j).t)
                entx = grp_trks(j).x;
                enty = grp_trks(j).y;
                entt = grp_trks(j).t;
                entxx = entx(z);
                entyy = enty(z);
                enttt = entt(z);
                idx = find([enttt{:}] == t);
                if ~isempty(idx)
                    x = [entxx{:}];
                    y = [entyy{:}];
                    xx = x(idx);
                    yy = y(idx);
                    %fprintf('tracklet: %d\n', idx_offset + t_offset + (yy-1)*x_dim + xx);
                    trcklets(1,t_offset + (yy-1)*x_dim + xx) = 1;
                end
            end
            t = t+1;
        end
    end
    
    %% Create Dimensions and Variables
    % fprintf('Creating variable\n');
    nccreate(['../dotnc/', folder, '.nc'],'seqTags', ...
        'Datatype', 'char', ...
        'Dimensions', {'maxSeqTagLength',70,'numSeqs',num_seqs}, ...
        'Format','classic');
    nccreate(['../dotnc/', folder, '.nc'],'labels', ...
        'Datatype', 'char', ...
        'Dimensions', {'maxLabelLength',3,'numLabels',max_len}, ...
        'Format','classic');
    nccreate(['../dotnc/', folder, '.nc'],'targetStrings', ...
        'Datatype', 'char', ...
        'Dimensions', {'maxTargStringLength',3,'numSeqs',num_seqs}, ...
        'Format','classic');
    nccreate(['../dotnc/', folder, '.nc'],'seqLengths', ...
        'Datatype', 'int32', ...
        'Dimensions', {'numSeqs',num_seqs}, ...
        'Format','classic');
    nccreate(['../dotnc/', folder, '.nc'],'seqDims', ...
        'Datatype', 'int32', ...
        'Dimensions', {'numDims',3,'numSeqs',num_seqs}, ...
        'Format','classic');
    nccreate(['../dotnc/', folder, '.nc'],'inputs', ...
        'Datatype', 'single', ...
        'Dimensions', {'inputPattSize',1,'numTimesteps',tot_len}, ...
        'Format','classic');
    
    % Write to Variables
    % fprintf('Writing data to file\n');
    ncwrite(['../dotnc/', folder, '.nc'],'inputs',trcklets);
    ncwrite(['../dotnc/', folder, '.nc'],'seqDims',seq_dims);
    ncwrite(['../dotnc/', folder, '.nc'],'seqLengths',seq_lens);
    ncwrite(['../dotnc/', folder, '.nc'],'labels',target_str);
    ncwrite(['../dotnc/', folder, '.nc'],'targetStrings',target);
    ncwrite(['../dotnc/', folder, '.nc'],'seqTags',seq_tags);
   
    % Close File
    % ncdisp(['../dotnc/', folder, '.nc']);
    clear trks;
    clear groups;
    clear grp_trks;
end