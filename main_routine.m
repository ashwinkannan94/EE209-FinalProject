function main_routine
    close all;
    dbstop if error;
    [env, env_size_x, env_size_y] = get_environment_from_image('2D_drawing2.png'); % load map from PNG
    
    env_info = {env, env_size_x, env_size_y};
    initial_x = 700;
    initial_y = 600;

    
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
    [x_border_positions,y_border_positions] = generate_border_points(distance, degrees, 550, 550);
    
    figure;
    scatter(x_border_positions,y_border_positions);
    title('Generated Map');

end