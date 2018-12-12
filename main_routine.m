function main_routine
    close all;
    dbstop if error;
    rng(2)
    
    x_borders = {};
    y_borders = {};
    for i = 1:3
        [x_border_positions, y_border_positions] = call_this;
        x_borders{end+1} = x_border_positions;
        y_borders{end+1} = y_border_positions;
    end

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

function [x_border_positions, y_border_positions] = call_this
    scale_factor = 0.2; % reduce size for faster computation
    initial_x = 700*scale_factor;
    initial_y = 600*scale_factor;
    [env, env_size_x, env_size_y] = get_environment_from_image('2D_drawing2.png', scale_factor); % load map from PNG
    
    env_info = {env, env_size_x, env_size_y};
    
    [front_sensor_data, right_sensor_data] = get_noisy_sensor_data(initial_x, initial_y, env_info);
    
    %% Find landmarks in sensor data
    [front_landmarks, right_landmarks] = clusterLandmarks(front_sensor_data, right_sensor_data);
    front_landmarks = front_landmarks(:,any(front_landmarks)); % remove columns with zeros
    right_landmarks = right_landmarks(:,any(right_landmarks)); % remove columns with zeros

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
    
    figure;
    scatter(x_border_positions,y_border_positions);
    title('Generated Map');
end