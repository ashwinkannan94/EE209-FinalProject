[environment, env_size_x, env_size_y] = get_environment_from_image('square_map.png'); % load map from PNG

% Robot's position (slight near the upper right corner)
robot_pos_x = 550;
robot_pos_y = 550;

% Sensor rotation speed
rotation_speed = 1; % degree per sample

% get sensor data time series for two 360 degree turns
front_sensor_data = [];
right_sensor_data = [];

theta = 0.1;
while theta < 360 * 5.5 % five and a half turns
    if mod(theta,30) == 0 % print theta for every 30 degrees
        disp(theta);
    end
    front_measurement = get_rangefinder_distance(robot_pos_x, robot_pos_y, theta, environment, env_size_x, env_size_y);
    front_sensor_data = [front_sensor_data, front_measurement]; % append current sensor measurement
    
    right_measurement = get_rangefinder_distance(robot_pos_x, robot_pos_y, theta-20, environment, env_size_x, env_size_y);
    right_sensor_data = [right_sensor_data, right_measurement]; % append current sensor measurement
    
    % random rotation speed
%     rotation_speed = randi(30); % between 1 and 10 degree per sample
    theta = theta + rotation_speed;
end

figure;
plot(environment(:,1),environment(:,2),'.k'); % plot the map
hold on;
scatter(robot_pos_x,robot_pos_y, 60, 'filled', 'b'); % plot the robot

xlim([0 env_size_x]);
ylim([0 env_size_y]);
title('Environment');

figure;
subplot(2,1,1);
plot(front_sensor_data);
xlabel('time');
ylabel('front sensor measurement');

subplot(2,1,2); 
plot(right_sensor_data);
xlabel('time');
ylabel('right sensor measurement');