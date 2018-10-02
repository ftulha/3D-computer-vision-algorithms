% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath([folder '\' 'MatlabFns']));
addpath(genpath([folder '\' 'vlfeat-0.9.20-bin']));
run('vl_setup');

% UNCOMMENT THE SECTION BELOW DEPENDING ON WHICH DATASET YOU WANT TO RUN IT
% FOR.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dataset 1 sequence 1
p = [folder '\' 'datasets\' 'Dataset 1\sequence m\'];
% Find the number of images that will be used to generate the panorama.
a = dir([p '/*).jpg']);
numImages = size(a,1);
outPath = [p 'result.jpg'];
for i=1:numImages
    listImages{i} = rgb2gray(imread([p 'img ('  num2str(i)  ').jpg']));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Dataset 1 sequence 2
% p = [folder '\' 'datasets\' 'Dataset 1\sequence 2\'];
% % Find the number of images that will be used to generate the panorama.
% a = dir([p '/*).jpg']);
% numImages = size(a,1);
% outPath = [p 'result.jpg'];
% for i=1:numImages
%     listImages{i} = rgb2gray(imread([p 'img ('  num2str(i)  ').jpg']));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Dataset 2 sequence 1
% p = [folder '\' 'datasets\' 'Dataset 2\sequence 1\'];
% % Find the number of images that will be used to generate the panorama.
% a = dir([p '/*).jpg']);
% numImages = size(a,1);
% outPath = [p 'result.jpg'];
% for i=1:numImages
%     listImages{i} = rgb2gray(imread([p 'img ('  num2str(i)  ').jpg']));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Dataset 2 sequence 2
% p = [folder '\' 'datasets\' 'Dataset 2\sequence 2\'];
% % Find the number of images that will be used to generate the panorama.
% a = dir([p '/*).jpg']);
% numImages = size(a,1);
% outPath = [p 'result.jpg'];
% for i=1:numImages
%     listImages{i} = rgb2gray(imread([p 'img ('  num2str(i)  ').jpg']));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Dataset 3 sequence 1
% p = [folder '\' 'datasets\' 'Dataset 3\sequence 1\'];
% % Find the number of images that will be used to generate the panorama.
% a = dir([p '/*).jpg']);
% numImages = size(a,1);
% outPath = [p 'result.jpg'];
% for i=1:numImages
%     listImages{i} = rgb2gray(imresize(imread([p 'img ('  num2str(i)  ').jpg']), 0.4));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Dataset 3 sequence 2
% p = [folder '\' 'datasets\' 'Dataset 3\sequence 2\'];
% Find the number of images that will be used to generate the panorama.
% a = dir([p '/*).jpg']);
% numImages = size(a,1);
% outPath = [p 'result.jpg'];
% for i=1:numImages
%     listImages{i} = rgb2gray(imresize(imread([p 'img ('  num2str(i)  ').jpg']), 0.4));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Dataset 4 
% p = [folder '\' 'datasets\' 'Dataset 4\'];
% % Find the number of images that will be used to generate the panorama.
% a = dir([p '/*).jpg']);
% numImages = size(a,1);
% outPath = [p 'result.jpg'];
% for i=1:numImages
%     listImages{i} = rgb2gray(imresize(imread([p 'img ('  num2str(i)  ').jpg']), 0.4));
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE ALGORITHM BEGINS HERE.

% Display a montage for all images 
dirOutput = dir(fullfile(p,'*).jpg'));
fileNames = {dirOutput.name}';
for i=1:numImages
    gamma{i} = [p fileNames{i}];
end

imDisp = montage(gamma);
hold on

% Choose the reference image. Let's take this to be the middle image.
refIdx = uint32(floor(1+numImages)/2);
I_ref = listImages{refIdx}; 

imageSize = size(I_ref);  % all the images are the same size

for i=1:numImages
    if i ~= 2
        % Extract the features for the ith and the reference image using the SIFT implementation by VL.
        Ia = im2single(listImages{i});
        Ib = im2single(I_ref);
        [fa, da] = vl_sift(Ia);
        [fb, db] = vl_sift(Ib);
        
        [matches, scores] = vl_ubcmatch(da, db);
        
        % Retrieve the locations of matched points.
        X1 = fa(1:2,matches(1,:));
        X2 = fb(1:2,matches(2,:));
       
        % Display the matching points. The data still includes several outliers, but you can see the effects of rotation and scaling on the display of matched features.
        
        % Find the optimal threshold for a set of feature points.
        threshold = 0.001;
        [H, inliers] = ransacfithomography(X1, X2, threshold);
        A = projective2d(H');
        projections(i).mat = A;
        I_result = imwarp(listImages{i}, A);
        pano{i} = I_result;
        [xlim(i,:), ylim(i,:)] = outputLimits(A, [1 imageSize(2)], [1 imageSize(1)]);

    else
        pano{i} = I_ref;
        dummy = projective2d(eye(3)');
        projections(i).mat = dummy;
        [xlim(2,:), ylim(2,:)] = outputLimits(dummy, [1 imageSize(2)], [1 imageSize(1)]);
    end
end

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panoramaImg = zeros([height width 3], 'like', I_ref);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);
panoramaImg = rgb2gray(panoramaImg);

% Create the panorama.
for i = 1:numImages

    I = listImages{i};

    % Transform I into the panorama.
    warpedImage = imwarp(I, projections(i).mat, 'OutputView', panoramaView);

    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), projections(i).mat, 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    panoramaImg = step(blender, panoramaImg, warpedImage, mask);
end

hold off
imshow(panoramaImg);
imwrite(panoramaImg, outPath);