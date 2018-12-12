% Resamples data to add uncertainty in rotation speed and
% add noise to the sensor measurement

function [new_sensor_data1, new_sensor_data2] = resample_and_add_noise(sensor_data1, sensor_data2, rotation_uncertainty, sensor_noise)
    if nargin ~= 4
        rotation_uncertainty = 1; % default maximum increase in rotation speed
        sensor_noise = 0.03; % +- 3% noise
        if nargin == 0
            load('front_sensor_data.mat');
            load('right_sensor_data.mat');
            sensor_data1 = front_sensor_data;
            sensor_data2 = right_sensor_data;
        end
    end
    
    data_size = length(sensor_data1);
    resample_scale = sin(linspace(-1*pi,pi,data_size));
    resample_scale = resample_scale + 2;
    
    new_sensor_data1 = [];
    new_sensor_data2 = [];
    iter = 1;
    count = 1;
    while iter <= data_size
        % standard deviation of Gaussian noise
        sd_noise1 = sensor_data1(iter)*sensor_noise;
        sd_noise2 = sensor_data2(iter)*sensor_noise;
        
        % add Gaussian noise
        new_sensor_data1 = [new_sensor_data1, normrnd(sensor_data1(iter), sd_noise1)];
        new_sensor_data2 = [new_sensor_data2, normrnd(sensor_data2(iter), sd_noise2)];
        
        resample_step = round(randi(rotation_uncertainty)*resample_scale(count));
%         disp(resample_step)
        iter = iter + resample_step;
        count = count + 1;
    end
    
end