function [front_sensor_data, right_sensor_data] = get_sensor_data(robot_pos_x, robot_pos_y, env)
    
    rotation_speed = 0.1;
    
    [environment, env_size_x, env_size_y] = env{:};
    
    front_sensor_data = zeros(1,360*1/rotation_speed);

    for theta1 = 1:(360/rotation_speed) % just one turn
        theta = theta1*rotation_speed;
        if mod(theta,30) == 0 % print theta for every 30 degrees
            disp(theta);
        end
        front_measurement = get_rangefinder_distance(robot_pos_x, robot_pos_y, theta, environment, env_size_x, env_size_y);
        front_sensor_data(theta1) = front_measurement; % append current sensor measurement

        %right_measurement = get_rangefinder_distance(robot_pos_x, robot_pos_y, theta-20, environment, env_size_x, env_size_y);
        %right_sensor_data = [right_sensor_data, right_measurement]; % append current sensor measurement

        % random rotation speed
    %     rotation_speed = randi(30); % between 1 and 10 degree per sample
        %theta = theta + rotation_speed;
    end
    right_sensor_data = [front_sensor_data(end-199:end),front_sensor_data(1:end-200)];
    
    front_sensor_data = [front_sensor_data, front_sensor_data, front_sensor_data, front_sensor_data, front_sensor_data, front_sensor_data];
    right_sensor_data = [right_sensor_data, right_sensor_data, right_sensor_data, right_sensor_data, right_sensor_data, right_sensor_data];

end