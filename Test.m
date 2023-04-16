[filename, pathname] = uigetfile({'*.png';'*.jpg'; '*.bmp'; '*.tif';'*.gif'; '*.jpeg'}, 'Load Mask File');

im_tumoralone = imread([pathname filename]);
im_tumoralone = imresize(im_tumoralone,[256,256]);
im_tumoralone = im2bw(im_tumoralone, 0.5);

measurements = regionprops(im_tumoralone,  ...
    'area', 'Centroid', 'Perimeter');

area = [measurements.Area];
centroid = [measurements.Centroid];
perimeter = [measurements.Perimeter];

% Calculate the area, in pixels
numberOfPixels2 = bwarea(im_tumoralone);
%area = sqrt(numberOfPixels2);

%convert into mm
area = numberOfPixels2 * (0.26458333)^2;
perimeter = perimeter * 0.26458333;