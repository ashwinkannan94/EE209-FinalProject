function [x_border_positions,y_border_positions] = generate_border_points(distance, degrees, starting_position_x, starting_position_y)
% Generates border points based on distance and degrees data
%   Using the degrees and the distance that is provided, find new x and y
%   coordinates which will be where the border is. Basic logic is to use
%   the following:
%   x_border = starting_x + distance*sin(degree)
%   y_border = starting_y + distance*cos(degree)

    x_border_positions = [];
    y_border_positions = [];
    for idx = 1:length(distance)
        x_border_positions = [x_border_positions, starting_position_x + distance(idx)*sind(degrees(idx))];
        x_border_positions = [y_border_positions, starting_position_y + distance(idx)*cosd(degrees(idx))];
    end
%   figure
%   scatter(x_border_positions,y_border_positions)
%   Do these two lines above where the code is called
end

