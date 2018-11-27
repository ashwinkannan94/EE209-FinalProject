
dbstop if error
close all;

[front_data_noisy, right_data_noisy] = resample_and_add_noise;





[Y1, Y2] = clusterLandmarks(front_data_noisy, right_data_noisy);

plot(front_data_noisy)
hold on

color_array = ['r'; 'g'; 'b'; 'y'];
for i = 1:size(Y1,1)
    peaks = Y1(i,:);
    peaks = peaks(peaks ~= 0);
    color = [color_array(i), '*'];
    plot(peaks, front_data_noisy(peaks), color)
end
hold off