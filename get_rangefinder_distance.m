function [distance, nearest_intersect_x, nearest_intersect_y, x, y] = get_rangefinder_distance(pos_x, pos_y, theta, environment, env_size_x, env_size_y)
    % Inputs:
    %           pos_x: X position of rangefinder
    %           pos_y: Y position of rangefinder
    %           theta: Orientation of rangefinder
    % Outputs:
    %           distance: Distance between rangefinder and object it's
    %                      facing towards
    %           nearest_intersect_x: X coordinate of intersection
    %           nearest_intersect_y: Y coordinate of intersection
    %           x: range of x values of rangefinder beam
    %           y: range of y values of rangefinder beam
    
    env_x = environment(:,1);
    env_y = environment(:,2);
    
    sensor_angle = mod(theta, 360);
    if sensor_angle == 0
        
        max_x = env_size_x;
        x = linspace(pos_x, max_x, env_size_x-pos_x+1);
        y = pos_y*ones(1,length(x));
        x_greater = env_x >= pos_x;
        idx = find(x_greater);
        env_x = env_x(idx);
        env_y = env_y(idx);
        
    elseif sensor_angle >= 0 && sensor_angle < 90
        slope = tan(theta*pi/180);
        y_intercept = (pos_y - slope*pos_x);
        max_x = min((env_size_y-y_intercept)/slope, env_size_x); % if the slope is too steep, the max x is limited
        x = linspace(pos_x, max_x, env_size_x-pos_x+1);
        y = slope*x + y_intercept;
        
        x_greater = env_x >= pos_x;
        y_greater = env_y >= pos_y;
        idx = find(and(x_greater, y_greater));
        env_x = env_x(idx);
        env_y = env_y(idx);
        
    elseif sensor_angle == 90 % if the sensor is facing straight up
        y = (pos_y: env_size_y);
        x = pos_x*ones(length(y),1)';
    elseif sensor_angle > 90 && sensor_angle <= 180
        slope = tan(theta*pi/180);
        y_intercept = (pos_y - slope*pos_x);
        min_x = max((env_size_y-y_intercept)/slope, 1); % if the slope is too steep, the max x is limited
        x = linspace(min_x, pos_x, pos_x);
        y = slope*x + y_intercept;
        
        x_less = env_x <= pos_x;
        y_greater = env_y >= pos_y;
        idx = find(and(x_less, y_greater));
        env_x = env_x(idx);
        env_y = env_y(idx);
        
    elseif sensor_angle > 180 && sensor_angle < 270
        slope = tan(theta*pi/180);
        y_intercept = (pos_y - slope*pos_x);
        min_x = max((1-y_intercept)/slope, 1); % if the slope is too steep, the max x is limited
        x = linspace(min_x, pos_x, pos_x);
        y = slope*x + y_intercept;
        x_less = env_x <= pos_x;
        y_less = env_y <= pos_y;
        idx = find(and(x_less, y_less));
        env_x = env_x(idx);
        env_y = env_y(idx);
    elseif sensor_angle == 270 % if the sensor is facing straight down
        y = (1: pos_y);
        x = pos_x*ones(length(y),1)';
    else
        slope = tan(theta*pi/180);
        y_intercept = (pos_y - slope*pos_x);
        max_x = min((1-y_intercept)/slope, env_size_x); % if the slope is too steep, the max x is limited
        x = linspace(pos_x, max_x, env_size_x-pos_x+1);
        y = slope*x + y_intercept;
        
        x_greater = env_x >= pos_x;
        y_less = env_y <= pos_y;
        idx = find(and(x_greater, y_less));
        env_x = env_x(idx);
        env_y = env_y(idx);
    end
                        
    %% get the cross point
%     rounded_x = round(x);
%     boolean_matrix = (env_x == rounded_x);
%     [row, col] = find(boolean_matrix);
%     distances = abs(env_y(row) - y(col).');
%     below_threshold_idx = find(distances <= 1);
%     intersect_x = env_x(row(below_threshold_idx));
%     intersect_y = env_y(row(below_threshold_idx));
%     intersect_y = [];
%     intersect_x = [];
%     
%     for i = 1:length(x)
%         curr_x = round(x(i));
%         curr_y = y(i);
%         same_x_idx = find(env_x==curr_x); % find the same X values from the environment
%         corres_y = env_y(same_x_idx); % corresponding y values of the environment
%         [min_diff, min_diff_idx] = min(abs(corres_y-curr_y));
%         if min_diff <= 1 % if the difference is only up to 1,
%             intersect_y = [intersect_y, corres_y(min_diff_idx)];
%             intersect_x = [intersect_x, curr_x];
%         end
%     end
    
    intersect_y = [];
    intersect_x = [];
    x_used = [];
    i = 1;
    while i < length(x)
        curr_x = round(x(i));
        x_used = [x_used, curr_x];
        if curr_x == 1036
            1;
        end
        curr_y = round(y(i));
        same_x_idx = find(env_x==curr_x); % find the same X values from the environment
        same_y_idx = find(env_y == curr_y);
        corres_x = env_x(same_y_idx);
        corres_y = env_y(same_x_idx); % corresponding y values of the environment
        [min_diff_y, min_diff_y_idx] = min(abs(corres_y-curr_y));
        [min_diff_x, min_diff_x_idx] = min(abs(corres_x-curr_x));
        
        
        if isempty([min_diff_x, min_diff_y])
            i = i + 1;
            continue;
        end
        
        if min_diff_x < min_diff_y
            min_diff = min_diff_x;
            min_diff_idx = min_diff_x_idx;
            diffs = corres_x - curr_x;
            diff_from_x = 1;
        else
            min_diff = min_diff_y;
            min_diff_idx = min_diff_y_idx;
            diffs = corres_y - curr_y;
            diff_from_x = 0;
        end
        
        step_size = round(diffs(min_diff_idx)/10);
        if step_size > 0
            i = i + step_size;
        else
            i = i + 1;

            if min_diff <= 1 % if the difference is only up to 1,
                if diff_from_x
                    intersect_y = [intersect_y, curr_y];
                    intersect_x = [intersect_x, corres_x(min_diff_idx)];
                else
                    intersect_y = [intersect_y, corres_y(min_diff_idx)];
                    intersect_x = [intersect_x, curr_x];
                end
            end
        end
    end
    
    
%     ref_x = round(x);
% %     same_x_idx = find(ref_x, env_x);
%     [~,same_x_idx] = ismember(ref_x, env_x);
%     zero_element_idx = find(same_x_idx==0);
%     same_x_idx(zero_element_idx) = [];
%     corres_y = env_y(same_x_idx);
%     x(zero_element_idx) = [];
%     y(zero_element_idx) = [];
%     [min_diff, min_diff_idx] = min(abs(corres_y-y));
%     small_diff_idx = find(min_diff<=1);
%     intersect_idx = min_diff_idx(small_diff_idx);
%     intersect_x = x(intersect_idx);
%     intersect_y = y(intersect_idx);

    dist = sqrt((intersect_x-pos_x).^2+(intersect_y-pos_y).^2);
    [distance, min_dist_idx] = min(dist);

    nearest_intersect_x = intersect_x(min_dist_idx);
    nearest_intersect_y = intersect_y(min_dist_idx);
end