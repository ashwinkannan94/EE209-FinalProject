function example2
    close all;
    rng(2) % random seed to produce same results
    fs = 14000; % 14kHz
    
    %% Generate rangefinder sensor data from simulation
    load('front_sensor_data_ex2.mat');
    load('right_sensor_data_ex2.mat');
    [front_sensor_data, right_sensor_data] = resample_and_add_noise(front_sensor_data, right_sensor_data);
    
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
    
    %% Plot results
    figure;
    subplot(2,1,1);
    plot(front_sensor_data);
    xlabel('Samples');
    ylabel('Original Front Sensor Data');
    subplot(2,1,2); 
    plot(right_sensor_data);
    xlabel('Samples');
    ylabel('Original Front Sensor Data');
    title('Original Sensor Data');
    
    figure;
    subplot(2,1,1);
    plot(front_avg_data);
    xlabel('Samples');
    ylabel('Averaged Front Sensor Data');
    subplot(2,1,2); 
    plot(right_avg_data);
    xlabel('Samples');
    ylabel('Averaged Front Sensor Data');
    title('Average Sensor Data');
    
    figure;
    scatter(x_border_positions,y_border_positions);
    title('Generated Map');
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
        
        [~,ix,iy] = dtw(seg1,seg2);
        time_warped_seg1 = seg1(ix); % time warp the first segment
        time_warped_seg2 = seg2(iy); % time warp the second segment
        avg_waveform = (time_warped_seg1*weight + time_warped_seg2)/(weight+1); % compute average
        
        weight = weight + 1; % increment weight
        seg1 = avg_waveform;
    end
    time_warped_avg = avg_waveform;
end