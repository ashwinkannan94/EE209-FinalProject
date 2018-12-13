function [] = minICP(x_borders, y_borders)
% finds min RMSE rotation for ICP
%   ICP only works on up to 60 degrees of rotation. Need to find min RMSE
%   between initial image and ICP rotated image

baseline_x = x_borders{1};
baseline_y = y_borders{1};
baseline_model = [baseline_x; baseline_y];
rotations = {0,90,180,270};
for i = 2:length(x_borders)
    data_x = x_borders{i};
    data_y = y_borders{i};
    data = [data_x; data_y];
    all_rotations = {};
    for j = 1:length(rotations)
        rotations{j}
        R = [cosd(rotations{j}) -sind(rotations{j}); sind(rotations{j}) cosd(rotations{j})];
        data_rotated = R * data;
        [RotMat,TransVec,dataOut]=icp(baseline_model,data_rotated,1000,1000,0,1e-16);
        all_rotations{end+1} = dataOut;
    end
    figure;
    plot(baseline_model(1,:),baseline_model(2,:),'.k');
    axis off;
    for k = 1:numel(all_rotations)
        figure;
        x_positions = all_rotations{k}(1,:);
        y_positions = all_rotations{k}(2,:);
        plot(x_positions,y_positions,'.k')
        axis off;
    end
    FolderName = 'tempdir2';   % Your destination folder
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for k = 1:length(FigList)
        baseFileName = sprintf('figure_%d.jpg',k);
        fullFileName = fullfile('tempdir2', baseFileName);
        saveas(figure(k), fullFileName)
    end
    directory = 'tempdir2';
    data = dir(fullfile(directory, '*.jpg'));
    F = fullfile(directory,'figure_1.jpg');
    I = imread(F);
    I_gray = rgb2gray(I);
    RMSE = zeros(1, numel(data)-1);
    for k = 2:numel(data)
        F2 = fullfile(directory,data(k).name);
        I2 = imread(F2);
        I2_gray = rgb2gray(I2);
        [M,N] = size(I_gray);
        error = I_gray - (I2_gray);
        MSE = sum(sum(error .* error)) / (M * N);
        RMSE(1, k-1) = MSE;
    end
    [M,I] = min(RMSE);
    file_to_move = strcat('figure_',num2str(I+1), '.jpg');
    full_path = strcat('tempdir2/', file_to_move);
    file_moved = strcat('figure_',num2str(i), '.jpg');
    moved_path = strcat('tempdir/', file_moved);
    copyfile(full_path, moved_path);
    copyfile('tempdir2/figure_1.jpg', 'tempdir/figure_1.jpg');
    delete('tempdir2/*.jpg');
    close all
end

