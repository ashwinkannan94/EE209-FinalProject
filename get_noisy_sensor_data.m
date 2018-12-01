function [noisy_sensor_data_front, noisy_sensor_data_right] = get_noisy_sensor_data(robot_pos_x, robot_pos_y, env)

    [sensor_data_front, sensor_data_right] = get_sensor_data(robot_pos_x, robot_pos_y, env);
    [noisy_sensor_data_front, noisy_sensor_data_right] = resample_and_add_noise(sensor_data_front, sensor_data_right);

end