function [x_coord, y_coord, image_matrix] = convert_image(image_filename)
    %% Load image file as grayscale image
    RGB_image = imread(image_filename);
    grayscale_image = rgb2gray(RGB_image);
%     imshow(grayscale_image)

    %% Convert to binary matrix
%     grayscale_image(grayscale_image < 122) = 0; % set dark pixels to 0
%     grayscale_image(grayscale_image > 123) = 255; % set bright pixels to 255
%     image_matrix = grayscale_image;
%     image_matrix = imresize(grayscale_image, scale_factor);
%     env_size_x = size(image_matrix,2);
%     env_size_y = size(image_matrix,1);

    % imshow(grayscale_image);

    image_matrix = flipud(grayscale_image);
    
    image_matrix = image_matrix < 128;
%     image_matrix = bwmorph(binaryImage, 'skel', inf); % shrink thickness of lines
    image_matrix = image_matrix == 0;
    image_matrix = double(image_matrix);
    
%     imshow(image_matrix);
    
    x_coord = [];
    y_coord = [];
    for i = 1:size(image_matrix,1)
        for j = 1:size(image_matrix,2)
            if image_matrix(i,j) == 0
                x_coord = [x_coord; j];
                y_coord = [y_coord; i];
            end
        end
    end
end