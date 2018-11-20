function [environment, env_size_x, env_size_y] = get_environment_from_image(image_filename)
    %% Load image file as grayscale image
    RGB_image = imread(image_filename);
    grayscale_image = rgb2gray(RGB_image);

    %% Convert to binary matrix
    grayscale_image(grayscale_image < 122) = 0; % set dark pixels to 0
    grayscale_image(grayscale_image > 123) = 255; % set bright pixels to 255
    image_matrix = grayscale_image;
    env_size_x = size(image_matrix,2);
    env_size_y = size(image_matrix,1);

    % imshow(grayscale_image);

    image_matrix = flipud(image_matrix);

    x = [];
    y = [];
    for i = 1:size(image_matrix,1)
        for j = 1:size(image_matrix,2)
            if image_matrix(i,j) == 0
                x = [x; j];
                y = [y; i];
            end
        end
    end
    environment = [x,y];
end