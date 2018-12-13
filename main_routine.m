function main_routine
    close all;
    dbstop if error;
    rng(2)
    scale_factor = 0.5; % reduce size for faster computation
    [env, env_size_x, env_size_y] = get_environment_from_image('new_img.png', scale_factor); % load map from PNG
    env_info = {env, env_size_x, env_size_y};
    
    x_borders = {};
    y_borders = {};
    x_values_all = [175,160,250,200];
    y_values_all = [100,105,80,150];
    for i = 1:length(x_values_all)
        [x_border_positions, y_border_positions] = original_main_routine(env_info, x_values_all(i),y_values_all(i));
        x_borders{end+1} = x_border_positions;
        y_borders{end+1} = y_border_positions;
    end
%     [x_rotated, y_rotated] = find_rotation_between_maps(x_borders, y_borders);
%     for k = 1:numel(x_rotated)
%         figure;
%         x_positions = x_rotated{k};
%         y_positions = y_rotated{k};
%         plot(x_positions,y_positions,'.k')
%         axis off;
%     end
%     FolderName = 'tempdir';   % Your destination folder
%     FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
%     for k = 1:length(FigList)
%         baseFileName = sprintf('figure_%d.jpg',k);
%         fullFileName = fullfile('tempdir', baseFileName);
%         saveas(figure(k), fullFileName)
%     end
    minICP(x_borders, y_borders)
    mean_image = read_images_and_return_average_image;
    image = mean_image(:, :, 1);
    image_thresholded = image;
    image_thresholded(image>202) = 256;
%     image_thresholded(image<202) = 0;
    figure;
    imshow(image_thresholded(:, :, 1),[0 255])

end


function [data_segments, landmarks_per_seg] = segment_data(data, landmarks)
    seg_ref_loc = landmarks(1,:);
    landmarks_per_seg = []; % adjust landmark location for each segment
    data_segments = {};
    for iter = 1:length(seg_ref_loc)-1
        start_idx = seg_ref_loc(iter);
        end_idx = seg_ref_loc(iter+1);
        curr_seg = data(start_idx:end_idx);
        data_segments{end+1} = curr_seg;
        for landmark_idx = 1:size(landmarks, 1)
            landmarks_per_seg(landmark_idx, iter) = landmarks(landmark_idx, iter) - start_idx + 1;
        end
    end
end


function time_warped_avg = avg_waveforms_thru_time_warp(data_segments)
    weight = 1; % weight for averaging. initially 1
    seg1 = data_segments{1};
    for iter = 2:length(data_segments)
        seg2 = data_segments{iter};
        
        if isempty(seg1) || isempty(seg2)
            continue;
        end
        
        [~,ix,iy] = dtw(seg1,seg2);
        time_warped_seg1 = seg1(ix); % time warp the first segment
        time_warped_seg2 = seg2(iy); % time warp the second segment
        avg_waveform = (time_warped_seg1*weight + time_warped_seg2)/(weight+1); % compute average
        
        weight = weight + 1; % increment weight
        seg1 = avg_waveform;
    end
    time_warped_avg = avg_waveform;
end

function [x_border_positions, y_border_positions] = original_main_routine(env_info, initial_x, initial_y)
    [front_sensor_data, right_sensor_data] = get_noisy_sensor_data(initial_x, initial_y, env_info);
    
    %% Find landmarks in sensor data
    [front_landmarks, right_landmarks] = clusterLandmarks(front_sensor_data, right_sensor_data);
    front_landmarks = front_landmarks(:,all(front_landmarks)); % remove columns with zeros
    right_landmarks = right_landmarks(:,all(right_landmarks)); % remove columns with zeros

    %% Segment sensor data into 360 degree turns
    front_data_segments = segment_data(front_sensor_data, front_landmarks);
    right_data_segments = segment_data(right_sensor_data, front_landmarks); % it needs landmarks from front sensor data
    
    %% Get average waveform using Dynamic Time Warping
    front_avg_data = avg_waveforms_thru_time_warp(front_data_segments);
    right_avg_data = avg_waveforms_thru_time_warp(right_data_segments);
    right_avg_data = resample(right_avg_data, length(front_avg_data), length(right_avg_data)); % match data length

    %% Approximate sensor orientation for each sample in average sensor data
    [degrees, distance] = get_degrees_from_sensor_data(front_avg_data, right_avg_data);
  
    %% Find environment map
    [x_border_positions,y_border_positions] = generate_border_points(distance, degrees, initial_x, initial_y);
    
%     figure;
%     scatter(x_border_positions,y_border_positions);
%     title('Generated Map');
end

function [x_rotated, y_rotated] = find_rotation_between_maps(x_borders, y_borders)
    x_values_1 = x_borders{1};
    y_values_1 = y_borders{1};
    x_rotated = {};
    y_rotated = {};
    x_rotated{end+1} = x_values_1;
    y_rotated{end+1} = y_values_1;
    for i=2:length(x_borders)
        if i == 2
            x_vals = x_borders{i};
            y_vals = y_borders{i};
            mat = [x_vals;y_vals];
            R = [cosd(180) -sind(180); sind(180) cosd(180)];
            mat_rotated = R*mat;
            x_borders{i} = mat_rotated(1,:);
            y_borders{i} = mat_rotated(2,:);
        end
        if i == 3
            x_vals = x_borders{i};
            y_vals = y_borders{i};
            mat = [x_vals;y_vals];
            R = [cosd(180) -sind(180); sind(180) cosd(180)];
            mat_rotated = R*mat;
            x_borders{i} = mat_rotated(1,:);
            y_borders{i} = mat_rotated(2,:);
        end
        x_values_2 = x_borders{i};
        y_values_2 = y_borders{i};
        model = [x_values_1;y_values_1];
        data = [x_values_2; y_values_2];
        [RotMat,TransVec,dataOut]=icp(model,data,1000,1000,0,1e-16);
        x_rotated{end+1} = dataOut(1,:);
        y_rotated{end+1} = dataOut(2,:);
%         figure(6)
%         plot(model(1,:),model(2,:),'r.',dataOut(1,:),dataOut(2,:),'b.'), axis equal
%         hold on
    end
end

function mean_image = read_images_and_return_average_image
    images = {};
    directory = 'tempdir';
    data = dir(fullfile(directory, '*.jpg'));
    sum_image = 0;
    for k = 1:numel(data)
        F = fullfile(directory,data(k).name);
        I = imread(F);
        I_gray = rgb2gray(I);
        sum_image = sum_image + double(I_gray);
        images{k} = I_gray;
    end
    mean_image = sum_image/numel(images);  
end