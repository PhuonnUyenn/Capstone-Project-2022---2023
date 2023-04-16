clc
close all
clear all

%% Input
[I,path]=uigetfile('*.png','select a input image');
str = strcat(path,I);
I = imread(str);

figure(1);
imshow(I);
title('Input image','FontSize',20);

%% Filter Image
num_iter = 10;
delta_t = 1/7;
kappa = 15;
option = 2;

inp = anisodiff(I,num_iter,delta_t,kappa,option);

inp = uint8(inp);

inp = imresize(inp,[256,256]);
if size(inp,3)>1
    inp = rgb2gray(inp);
end
figure(2);
imshow(inp);

%% Otsu Segementation
im_thr = imtophat(inp,strel('disk',40));
im_adjust = imadjust(im_thr);
level = graythresh(im_adjust);
figure;
imshow(level);
BW = im2bw(im_adjust,level);
figure;
imshow(BW);
SE_erode=strel('disk',3);
im_erode=imerode(BW,SE_erode);
figure;
imshow(im_erode);

%% Morphological Operation
SE=ones(3);
im_erode=imopen(im_erode,SE);
imshow(im_erode);
title('Brain Tumor with other small unwanted objects');
im_erode = bwareaopen(im_erode,500);
figure;
imshow(im_erode)
title('Segmented Brain Tumor')

%% Bounding Box
stats=regionprops(im_erode,'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];
High_Density_Area=density > 0.5; 
MaxArea=max(area(High_Density_Area));
tumor_label=find(area==MaxArea);
tumor=ismember(im_erode,tumor_label);

%Bounding Box
box = stats(tumor_label);
wantedBox = box.BoundingBox;
figure
imshow(inp);
title('Bounding Box','FontSize',20);
hold on;
rectangle('Position',wantedBox,'EdgeColor','y');
hold off;

dilationAmount = 5;
rad = floor(dilationAmount);
[r,c] = size(tumor);
filledImage = imfill(tumor, 'holes');

for i=1:r
   for j=1:c
       x1=i-rad;
       x2=i+rad;
       y1=j-rad;
       y2=j+rad;
       if x1<1
           x1=1;
       end
       if x2>r
           x2=r;
       end
       if y1<1
           y1=1;
       end
       if y2>c
           y2=c;
       end
       erodedImage(i,j) = min(min(filledImage(x1:x2,y1:y2)));
   end
end

tumorOutline = tumor - erodedImage;
figure;
imshow(tumorOutline);

%% Area and Perimeter of Brain tumor
measurements = regionprops(tumor,  ...
    'area', 'Centroid', 'Perimeter');
area_tumor = [measurements.Area];
centroid = [measurements.Centroid];
perimeter = [measurements.Perimeter];

numberofWhitePixel = bwarea(tumor);
area_tumor = numberofWhitePixel * (0.26458333)^2;
perimeter_tumor = perimeter * 0.26458333;

structBoundaries = bwboundaries(tumor);
xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
x = xy(:, 2); % Columns.
y = xy(:, 1); % Rows.

%%
% tumorOutline=tumor - erodedImage;
% numWhitePixels = sum(tumor(:));
% labeledImage = bwlabel(tumor);
% measurements = regionprops(tumor,  ...
%     'area', 'Centroid', 'Perimeter');
% 
% area_tumor = [measurements.Area];
% centroid = [measurements.Centroid];
% perimeter = [measurements.Perimeter];

%% Analze Physical Properties of Tumor

% numberofPixels1 = sum(tumor(:));
% numberofPixels2 = bwarea(tumor);
% area_tumor = sqrt(numberofPixels2);
% 
% 
% area_tumor = area_tumor*0.26458333;
% perimeter_tumor = perimeter*0.26458333;
% structBoundaries = bwboundaries(tumor);
% xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
% x = xy(:, 2); % Columns.
% y = xy(:, 1); % Rows.

%%

