% input: front data segment and right data segment. (for 360 degree turn)
% output: orientation in degrees for each sample and distance measurement

function [degrees, distance] = get_degrees_from_sensor_data(front_data_seg, right_data_seg)
    % concatenate to make 720 degree turn to avoid flat ends in time warped
    % signal
    front_data_seg = [front_data_seg, front_data_seg]; 
    right_data_seg = [right_data_seg, right_data_seg];
    [~,front_warp_path,right_warp_path] = dtw(front_data_seg, right_data_seg);

    % get 25 to 75 percent indices of front data (contains only 360 turn)
    num_front_data_samples = length(front_data_seg);
    start_idx = round(num_front_data_samples*0.25);
    end_idx = start_idx + num_front_data_samples/2 - 1;

    sample_offset = [];
    for idx = start_idx:end_idx
        front_warp_idx = round(mean(find(front_warp_path==idx))); % find the corresponding sample in time warped signal
        right_orig_idx = right_warp_path(front_warp_idx); % find the corresponding right sensor data sample
        sample_offset = [sample_offset, right_orig_idx - idx]; % note: if positive, turning counter clockwise.
    end

    angular_v_sample = 20./sample_offset; % angular velocity in degree/sample
    degrees = cumsum(angular_v_sample); % find degrees for each sample
    distance = front_data_seg(start_idx:end_idx);
end