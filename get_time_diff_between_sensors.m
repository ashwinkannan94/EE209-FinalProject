function time_offset = get_time_diff_between_sensors(front_data_seg, right_data_seg, sampling_rate)
    front_data_seg = [front_data_seg, front_data_seg];
    right_data_seg = [right_data_seg, right_data_seg];
    [~,front_warp_path,right_warp_path] = dtw(front_data_seg, right_data_seg);

    num_front_data_samples = length(front_data_seg);
    start_idx = round(num_front_data_samples*0.25);
    end_idx = start_idx + num_front_data_samples/2 - 1;

    sample_offset = [];
    for idx = start_idx:end_idx
        front_warp_idx = round(mean(find(front_warp_path==idx)));
        right_orig_idx = right_warp_path(front_warp_idx);
        sample_offset = [sample_offset, right_orig_idx - idx]; % if positive, turning counter clockwise.
    end

    time_offset = sample_offset./sampling_rate;
%     angular_velocity = 20./time_offset;

    angular_v_sample = 20./sample_offset; % angular velocity in degree/sample

    degrees = cumsum(angular_v_sample); % find degrees for each sample

%     % determine which data is leading
%     mid_idx = round(length(front_warp_path)/2);
%     if front_warp_path(mid_idx) < right_warp_path(mid_idx)
%         % front sensor data is leading
%         lead_warp_path = front_warp_path;
%         lag_warp_path = right_warp_path;
%     else
%         % right sensor data is leading
%         lead_warp_path = right_warp_path;
%         lag_warp_path = front_warp_path;
%     end
% 
%     num_samples_offset = lag_warp_path - lead_warp_path;
%     new_sampling_rate = length(front_warp_path)/length(front_data_seg)*sampling_rate;
%     time_offset = num_samples_offset/new_sampling_rate;
% 
%     close all;
%     figure;
%     subplot(2,1,1);
%     plot(front_data_seg);
%     hold on;
%     plot(right_data_seg);
%     xlabel('time');
%     ylabel('Sensor measurement');
%     legend('Front', 'Right');
% 
%     subplot(2,1,2); 
%     plot(front_data_seg(front_warp_path));
%     hold on;
%     plot(right_data_seg(right_warp_path));
%     xlabel('time');
%     ylabel('Dynamic Time Warped data');
end