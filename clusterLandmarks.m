function [front_landmarks, right_landmarks] = clusterLandmarks(front_sensor_data, right_sensor_data)

% Denoise Sensor Data
fc = 80;
fs = 14000; % 14kHz
[b,a] = butter(6,fc/(fs/2));
denoised_front_sensor_data = filtfilt(b,a,front_sensor_data);
denoised_right_sensor_data = filtfilt(b,a,right_sensor_data);

% No more than 10 landmarks/corners
max_k = 10;

% Pull out corner locations
[peaks1, locs1, w1] = findpeaks(denoised_front_sensor_data);
[peaks2, locs2, w2] = findpeaks(denoised_right_sensor_data);
peaks1 = peaks1.';
peaks2 = peaks2.';

% Concatenate to 1 array for clustering
peaks = [peaks1; peaks2];

% Determine optimal number of clusters
eva = evalclusters(peaks, 'kmeans', 'silhouette', 'KList', [1:max_k]);
optimal_k = eva.OptimalK;

% Perform K means clustering
idx = kmeans(peaks, optimal_k);

% Separate back into original groups
% If still concatenated, could break periodicity
idx1 = idx(1:size(peaks1,1));
idx2 = idx(size(peaks1,1)+1:end);

%%% Periodicity Check %%%
min_corners = 2;
subsequence = [];

% Start with a few entries in order to not find mini subsequence
for i = 1:min_corners
    subsequence = [subsequence, idx1(i)];
end

% If next sequence equals stored sequence, we have found it and can break
j = min_corners + 1;
while true
    if isequal(subsequence, idx1(j:j+length(subsequence) - 1).')
        break;
    end
    subsequence = [subsequence, idx1(j)];
    j = j + 1;
end


%%% Separate Clusters Based on Periodicity %%%
orig_subsequence = subsequence;
cluster_max = max(subsequence);
cluster_count = zeros(1,length(subsequence));
% Basically using a hash table to count cluster number in sequence. 
% If a certain cluster is seen more than once, separate that one into 
% new cluster
for i = 1:length(subsequence)
   if(cluster_count(subsequence(i)) == 1)
      cluster_max = cluster_max + 1;
      subsequence(i) = cluster_max;
      cluster_count(cluster_max) = 1;
   else
      cluster_count(subsequence(i)) = 1;
   end
end


%%% Update idx values %%%
for i = 1:(length(idx1) - length(subsequence)+1)
   seq = idx1(i:i+length(subsequence)-1);
   if sum(seq == subsequence.') == 3 || isequal(seq, orig_subsequence.')
       idx1(i:i+length(subsequence)-1) = subsequence;
   end
end
    
for i = 1:(length(idx2) - length(subsequence)+1)
   seq = idx2(i:i+length(subsequence)-1);
   if sum(seq == subsequence.') == 3 || isequal(seq, orig_subsequence.')
       idx2(i:i+length(subsequence)-1) = subsequence;
   end
end
    



front_landmarks = zeros(cluster_max, ceil(size(peaks,1)/(cluster_max-1)));
right_landmarks = zeros(cluster_max, ceil(size(peaks,1)/(cluster_max-1)));



for i = 1:cluster_max
    
    locs = locs1(idx1 == i);
    num_locs = size(locs,2);
    front_landmarks(i,1:num_locs) = locs;
    
    locs = locs2(idx2 == i);
    num_locs = size(locs,2);
    right_landmarks(i, 1:num_locs) = locs.';
    
end


end