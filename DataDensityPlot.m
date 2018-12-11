function [ f ] = DataDensityPlot( x, y, levels )
%DATADENSITYPLOT Plot the data density 
%   Makes a contour map of data density
%   x, y - data x and y coordinates
%   levels - number of contours to show
%
% By Malcolm Mclean
%
    map = dataDensity(x, y, 1024, 1024);
    
    map = map - min(min(map));
    map = floor(map ./ max(max(map)) * (levels-1));
    figure;
    imshow(uint8(map));
%     set(gca, 'XTick', [1 256]);
%     set(gca, 'XTickLabel', [min(x) max(x)]);
%     set(gca, 'YTick', [1 256]);
%     set(gca, 'YTickLabel', [min(y) max(y)]);
end