function map = generate_map(x,y, rotation_speed, distances, sampling_rate)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    map = zeros(360,2);
    for i=1:359
        dist = distances(i,2);
        map(i,1) = x + dist*cosd(i);
        map(i,2) = y + dist*sind(i);
    end
    scatter(map(:,1),map(:,2))
end

