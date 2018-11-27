function chris_test1    
%     [new_sensor_data1, new_sensor_data2] = resample_and_add_noise;
    
    load('denoised_front_sensor_segment.mat');
    load('denoised_right_sensor_segment.mat');
    
    figure;
    subplot(2,1,1);
    plot(denoised_front_sensor_segment);
    xlabel('time');
    ylabel('front sensor measurement');

    subplot(2,1,2); 
    plot(denoised_right_sensor_segment);
    xlabel('time');
    ylabel('right sensor measurement');
    
    [dist,ix,iy] = dtw(denoised_front_sensor_segment, denoised_right_sensor_segment, 'absolute');
    dtw(denoised_front_sensor_segment, denoised_right_sensor_segment, 'absolute');
end

