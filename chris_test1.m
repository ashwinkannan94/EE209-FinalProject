function chris_test1 
    clear all;
    close all;
    rng(2)
    fs = 14000; % 14kHz
%     [front_sensor_data, right_sensor_data] = resample_and_add_noise;
    
    load('front_sensor_data_ex2.mat');
    load('right_sensor_data_ex2.mat');
    [front_sensor_data, right_sensor_data] = resample_and_add_noise(front_sensor_data, right_sensor_data);

%     denoised_front_sensor_data = wdenoise(front_sensor_data);
%     denoised_right_sensor_data = wdenoise(right_sensor_data);
    
%     plot(new_sensor_data1);
    
    fc = 100;
    [b,a] = butter(6,fc/(fs/2));
    denoised_front_sensor_data = filtfilt(b,a,front_sensor_data);
    denoised_right_sensor_data = filtfilt(b,a,right_sensor_data);

    [front_landmarks, right_landmarks] = clusterLandmarks(denoised_front_sensor_data, denoised_right_sensor_data);
    
    front_landmarks = front_landmarks(:,any(front_landmarks));
    right_landmarks = right_landmarks(:,any(right_landmarks));
%     first_peak_loc1 = [155, 1459, 3245, 5664, 8009, 9644];
%     second_peak_loc1 = [552, 1956, 4064, 6463, 8609, 10090];
%     first_peak_loc2 = [222, 1546, 3407, 5827, 8139, 9746];

    [front_data_segments, landmarks_per_seg] = segment_data(front_sensor_data, front_landmarks);
    right_data_segments = segment_data(right_sensor_data, front_landmarks);
    
    
    %{
    front_time_warped_avg = time_warpping(front_data_segments, landmarks_per_seg);
    right_time_warped_avg = time_warpping(right_data_segments, landmarks_per_seg);


%     plot(time_warped_avg);
    right_time_warped_avg = resample(right_time_warped_avg, length(front_time_warped_avg), length(right_time_warped_avg));
    [degrees, distance] = get_degrees_from_sensor_data(front_time_warped_avg, right_time_warped_avg);
    %}
    avg_degrees = [];
    avg_distance = [];
    weight = 1;
    for iter = 1:length(front_data_segments)
        curr_front_seg = front_data_segments{iter};
        curr_right_seg = right_data_segments{iter};
%         curr_front_seg = wdenoise(curr_front_seg);
%         curr_right_seg = wdenoise(curr_right_seg);
        [degrees, distance] = get_degrees_from_sensor_data(curr_front_seg, curr_right_seg);
        [x_border_positions,y_border_positions] = generate_border_points(distance, degrees, 550, 550);
        disp(y_border_positions(1));
        figure;
        scatter(x_border_positions,y_border_positions);
        hold on;
        scatter(x_border_positions(1),y_border_positions(1),'filled','r');
        
        distance = wdenoise(distance);
        [x_border_positions,y_border_positions] = generate_border_points(distance, degrees, 550, 550);
        p1 = plot(x_border_positions,y_border_positions,'.m');
        
        curr_front_seg_d = wdenoise(curr_front_seg);
        curr_right_seg_d = wdenoise(curr_right_seg);
        [degrees, distance] = get_degrees_from_sensor_data(curr_front_seg_d, curr_right_seg_d);
        [x_border_positions,y_border_positions] = generate_border_points(distance, degrees, 550, 550);
%         scatter(x_border_positions,y_border_positions,'filled','g','MarkerFaceAlpha',.2,'size',1);
        p2 = plot(x_border_positions,y_border_positions,'.g');
        p1.Color(4) = 0.2;
        p2.Color(4) = 0.2;
        hold off;
        
        figure;
        plot(curr_front_seg);
        hold on;
        plot(curr_right_seg);
        hold off;
        if iter == 1
            avg_degrees = degrees;
            avg_distance = distance;
        else
            resampled_degrees = resample(degrees, length(avg_degrees), length(degrees));
            resampled_distance = resample(distance, length(avg_distance), length(distance));
            avg_degrees = (avg_degrees*weight+resampled_degrees)/(weight+1);
            avg_distance = (avg_distance*weight+resampled_distance)/(weight+1);
            weight = weight+1;
        end
    end    
    
    distance = avg_distance;
    degrees = avg_degrees;

    
%     order = 3;
%     framelen = 11;
%     sgf = sgolayfilt(time_warped_avg,order,framelen);
    
%     XDEN = wdenoise(time_warped_avg,9,'NoiseEstimate','LevelIndependent');
    
%     load('denoised_front_sensor_segment.mat');
%     load('denoised_right_sensor_segment.mat');
%     

    [x_border_positions,y_border_positions] = generate_border_points(distance, degrees, 550, 550);
    
%     figure;
%     subplot(2,1,1);
%     plot(front_time_warped_avg);
%     xlabel('time');
%     ylabel('front sensor measurement');
% 
%     subplot(2,1,2); 
%     plot(right_time_warped_avg);
%     xlabel('time');
%     ylabel('right sensor measurement');
    
%     figure;
%     scatter(x_border_positions,y_border_positions);
%     
%     [dist,ix,iy] = dtw(denoised_front_sensor_segment, denoised_right_sensor_segment, 'absolute');
%     dtw(denoised_front_sensor_segment, denoised_right_sensor_segment, 'absolute');
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


function time_warped_avg = time_warpping(data_segments, landmarks)
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


% 
% function [time_warped_avg, new_sampling_rate, new_landmarks] = time_warpping(data_segments, fs, landmarks)
%     weight = 1; % weight for averaging. initially 1
%     seg1 = data_segments{1};
%     for iter = 2:length(data_segments)
%         seg2 = data_segments{iter};
% %         seg1 = wdenoise(seg1,9,'NoiseEstimate','LevelIndependent');
% %         seg2 = wdenoise(seg2,9,'NoiseEstimate','LevelIndependent');
% %         seg1 = wdenoise(seg1); % denoise signal using wavelet
% %         seg2 = wdenoise(seg2); % denoise signal using wavelet
%         [~,ix,iy] = dtw(seg1,seg2);
%         time_warped_seg1 = seg1(ix); % time warp the first segment
%         time_warped_seg2 = seg2(iy); % time warp the second segment
%         avg_waveform = (time_warped_seg1*weight + time_warped_seg2)/(weight+1); % compute average
%         
%         weight = weight + 1; % increment weight
%         fs = length(time_warped_seg1)/length(seg1)*fs; % update sampling rate
%         seg1 = avg_waveform;
%         landmarks = update_landmark_loc(landmarks, iter-1, ix);
%     end
%     time_warped_avg = avg_waveform;
%     new_sampling_rate = fs;
%     new_landmarks = landmarks;
% end

function new_landmarks = update_landmark_loc(landmarks, curr_turn, time_shift)
    num_landmarks = size(landmarks, 1);
    new_landmarks = landmarks;
    
    for curr_landmark_idx = 1:num_landmarks
        curr_landmark = landmarks(curr_landmark_idx, curr_turn);
        new_landmarks(curr_landmark_idx, curr_turn) = round(mean(find(time_shift==curr_landmark)));
    end  
end