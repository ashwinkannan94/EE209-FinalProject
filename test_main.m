[environment, env_size_x, env_size_y] = get_environment_from_image('2d_drawing2.png');

robot_pos_x = 800;
robot_pos_y = 500;
robot_theta = 220; % in degrees

[distance, nearest_intersect_x, nearest_intersect_y, x, y] = get_rangefinder_distance(robot_pos_x, robot_pos_y, robot_theta, environment, env_size_x, env_size_y);

plot(environment(:,1),environment(:,2),'.k');
hold on;
plot(x,y,'g');

scatter(robot_pos_x,robot_pos_y, 60, 'filled', 'b');
scatter(nearest_intersect_x,nearest_intersect_y, 100, 'x', 'r');

xlim([0 env_size_x]);
ylim([0 env_size_y]);

legend('Obstacle', 'Sensor beam', 'Robot', 'Detected point');
title(['Distance: ', num2str(distance)]);