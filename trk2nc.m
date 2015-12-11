
clc;clear;close all
files = dir;
directoryNames = {files([files.isdir]).name};
directoryNames = directoryNames(~ismember(directoryNames,{'.','..'}));

for i = 1 : length(directoryNames)
    folder = directoryNames{i};
    fprintf('Processing: %s\n', folder);
    file = fopen([pwd, '/', folder, '/', folder, '.last.save_weightContainer_hidden_0_0_to_output_collapse_weights'], 'r');
    tline = fgetl(file);
    tline = fgetl(file);
    C = strsplit(tline);
    C = str2double(C);
    data = zeros(4, 15);
    for j = 1 : 4
        for z = 1 : 15
            data(j, z) = C((j-1)*15 + z);
        end
    end
    no_dims = 2;
    initial_dims = 4;
    perplexity = 4;
    mappedX = tsne(data, [], no_dims, initial_dims, perplexity)
    gscatter(mappedX(:,1), mappedX(:,2), [1, 2, 3, 4]);
    hold on;
end