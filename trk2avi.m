%% group detection parameter setting
% Authored by haeyong kang
% Co-author: Ben Ruktantichoke

clear all;
path = './';
path_gr = [path,'../trks2avi/'];
path_img_root = path;
path_img_dir = dir([path_img_root,'*']);

num = xlsread([pwd, '/../video_info_t0.xls'], 'Sheet2');

for file_n = 250 : length(path_img_dir) 
    clear trks;
    v0 = num(file_n-3, 1); % start time
    v1 = num(file_n-3, 2); % stop time
    file_name = path_img_dir(file_n).name;
    path_img = [path_img_root, file_name, '/'];
    
    % load trks
    load([path_img_root, file_name, '/trks_1_smooth.mat'], 'trks');
    
    % load GroundTruths
    load([pwd, '/../ground_truth_grDetect/', file_name, '_gt.mat'], 'groups');
    
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
        fprintf('Processing Tracklet:%d\n', accu);
        for j = 1 : length(groups)
            % fprintf('Group: %d\taccu:%d\tidx:%d\tval:%d\n', j, accu, idxs(j), groups{j}(idxs(j)));
            if idxs(j) <= length(groups{j})
                if groups{j}(idxs(j)) == accu
                    idxs(j) = idxs(j) + 1;
                    fprintf('Not Evict from group %d:\n', j);
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
                    fprintf('Evicted from group %d:\n', j);
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
                fprintf('Evicted from group %d:\n', j);
            end
        end
        accu = accu + 1;
    end
    
    fprintf('Processing:%s\n', file_name);
    frames = dir([path_img, '0*.jpg']);
    for j = 1 :length(groups)
        fprintf('Group: %d\n', j);
        n_trks = struct('x', grp_trks(j).x, 'y', grp_trks(j).y, 't', grp_trks(j).t);
        %% Intialization
        [trkTime, lenTime, nTrks, ~] = fun_trkInfo(n_trks);
        lenTime = min(lenTime,length(frames));

        t_begin = 0;
        t_end = max(max(trkTime));

        % Preallocate movie structure.
        nFrames = t_end + 1;
        mov(1:nFrames) = struct('cdata', [],...
                            'colormap', []);

        curFrame = imread([path_img frames(1).name]);
        img_size = size(curFrame);
        curFrmTrks = zeros(img_size(1),img_size(2), 3,nFrames);

        %% visualization
        f1=figure(1);
        for time = v0 : v1
            curFrame = imread([path_img frames(time).name]);
            imshow(curFrame)
            title(['Frame No.' num2str(time)])
            hold on

            tmp_trk_x = [];
            tmp_trk_y = [];
            for i = 1: length(n_trks)
                tdx = find(n_trks(i).t == time);
                if ~isempty(tdx)
                    tmp_trk_x = [tmp_trk_x; n_trks(i).x(tdx)];
                    tmp_trk_y = [tmp_trk_y; n_trks(i).y(tdx)];
                end
            end

            for trk = 1:length(tmp_trk_x)
                mu = [tmp_trk_x(trk) tmp_trk_y(trk)]; 
                SIGMA = [5.0 0.0; 0.0 5.0]; 
                X = mvnrnd(mu,SIGMA,600); 
                p = 512 * mvnpdf(X,mu,SIGMA); 
                X = uint16(X);
                for c =1: length(X) 
                    if(X(c,2) <= img_size(1) && X(c,2) >= 1)
                        if(X(c,1) <= img_size(2) && X(c,1) >= 1)
                            curFrmTrks(X(c,2), X(c,1),:, time) = uint8(p(c));
                        end
                    end
                end
                color = [0 0.5 0];
                scatter(X(:,1), X(:,2), [], color)
            end

            drawnow
            hold off
        end
    end
    
    fprintf('Done\n');
end