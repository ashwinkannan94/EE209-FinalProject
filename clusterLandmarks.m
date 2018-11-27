function [Y1, Y2] = clusterLandmarks(X1, X2)

max_k = 10;

[peaks1, locs1, w1] = findpeaks(X1, 'MinPeakWidth', 5);
[peaks2, locs2, w2] = findpeaks(X2, 'MinPeakWidth', 5);

peaks1 = peaks1.';
peaks2 = peaks2.';

peaks = [peaks1; peaks2];


eva = evalclusters(peaks, 'kmeans', 'silhouette', 'KList', [1:max_k]);

optimal_k = eva.OptimalK;

idx = kmeans(peaks, optimal_k);



idx1 = idx(1:size(peaks1,1));
idx2 = idx(size(peaks1,1)+1:end);


Y1 = zeros(optimal_k, ceil(size(peaks,1)/(optimal_k-1)));
Y2 = zeros(optimal_k, ceil(size(peaks,1)/(optimal_k-1)));



for i = 1:optimal_k
    
    locs = locs1(idx1 == i);
    num_locs = size(locs,2);
    Y1(i,1:num_locs) = locs;
    
    locs = locs2(idx2 == i);
    num_locs = size(locs,2);
    Y2(i, 1:num_locs) = locs.';
    
end


end