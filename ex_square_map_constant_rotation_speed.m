[environment, env_size_x, env_size_y] = get_environment_from_image('square_map.png'); % load map from PNG

% Robot's position
robot_pos_x = 500;
robot_pos_y = 500;

% get sensor data time series for two 360 degree turns
sensor_data = [];
for theta = 1:720
    measurement = get_rangefinder_distance(robot_pos_x, robot_pos_y, theta, environment, env_size_x, env_size_y);
    sensor_data = [sensor_data, measurement]; % append current sensor measurement
end

figure;
plot(environment(:,1),environment(:,2),'.k'); % plot the map
hold on;
scatter(robot_pos_x,robot_pos_y, 60, 'filled', 'b'); % plot the robot

xlim([0 env_size_x]);
ylim([0 env_size_y]);
title('Environment');

figure;
plot(sensor_data);
xlabel('time');
ylabel('sensor measurement');