function distance = pc_distance(A, B)

    %INPUTS
    % A - 2xn array of n (x,y) points
    % B - 2xm array of m (x,y) points
    
    
    sum_distA = 0;
    for i = 1:length(A)
       
        a = A(:,i);
        min_dist = inf;
        for j = 1:length(B)
           b = B(:,j);
           dist = sqrt(sum((a - b).^2));
           if dist < min_dist
               min_dist = dist;
           end
        end
        sum_distA = sum_distA + min_dist;
    end

    sum_distB = 0;
    for i = 1:length(B)

        b = B(:,i);
        min_dist = inf;
        for j = 1:length(A)
           a = A(:,j);
           dist = sqrt(sum((a - b).^2));
           if dist < min_dist
               min_dist = dist;
           end
        end
        sum_distB = sum_distB + min_dist;
    end

    distance = 1/(length(A) + length(B)) * (sum_distB + sum_distA);
    
end