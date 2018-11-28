function [x_border_positions,y_border_positions] = generate_border_points(distance, degrees, starting_position_x, starting_position_y)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    x_border_positions = [];
    y_border_positions = [];
    for idx = 1:length(distance)
        x_border_positions = [x_border_positions, starting_position_x + distance(idx)*sind(degrees(idx))];
        y_border_positions = [y_border_positions, starting_position_y + distance(idx)*cosd(degrees(idx))];
    end
end

