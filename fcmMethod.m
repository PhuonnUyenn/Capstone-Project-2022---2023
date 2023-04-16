clc;
clear all;
close all;
%% Input
[I,path]=uigetfile('*.png','select a input image');
str=strcat(path,I);
im=imread(str);

figure;
imshow(im);
title('Input image','FontSize',20);

%% Filter Image
num_iter = 10;
delta_t = 1/7;
kappa = 15;
option = 2;

im = anisodiff(im,num_iter,delta_t,kappa,option);

im = uint8(im);

im = imresize(im,[256,256]);
if size(im,3)>1
    im = rgb2gray(im);
end
figure;
imshow(im);

fim = mat2gray(im);
level = graythresh(fim);
fim = imresize(fim,[256,256]);   
bwfim = im2bw(fim,0.1);

%% Fuzzy C Means Segmentation
[bwfim0,level0]=fcmthresh(fim,0);
[bwfim1,level1]=fcmthresh(fim,1);
subplot(2,2,1);
imshow(fim);title('Original');
subplot(2,2,2);
imshow(bwfim);title(sprintf('Otsu,level=%f',level));
subplot(2,2,3);
imshow(bwfim0);title(sprintf('FCM0,level=%f',level0));
subplot(2,2,4);
imshow(bwfim1);title(sprintf('FCM1,level=%f',level1));

%% Morphological Operation
SE = ones(5);
bwfim1 = imopen(bwfim1,SE);
imshow(bwfim1);
title('Brain Tumor with other small unwanted objects'); 
bwfim1 = bwareaopen(bwfim1,500);
figure;
imshow(bwfim1);
title('Segmented Brain Tumor');

%% Bounding Box
stats=regionprops(bwfim1,'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];
High_Density_Area=density > 0.6; % reduce to detect small or early stage tumors 
MaxArea=max(area(High_Density_Area));
tumor_label=find(area==MaxArea);
tumor=ismember(bwfim1,tumor_label);

box = stats(tumor_label);
wantedBox = box.BoundingBox;
figure
imshow(im);
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

tumorOutline=tumor - erodedImage;
figure;
imshow(tumorOutline);

%% Area and Perimeter of Brain tumor
measurements = regionprops(tumor,  ...
    'area', 'Centroid', 'Perimeter');

area = [measurements.Area];
centroid = [measurements.Centroid];
perimeter = [measurements.Perimeter];

numberofWhitePixels = bwarea(tumor);

%convert into mm
area_tumor = numberofWhitePixels * (0.26458333)^2;
perimeter_tumor = perimeter * 0.26458333;

% Get coordinates of the boundary in tumor
structBoundaries = bwboundaries(tumor);
xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
x = xy(:, 2); % Columns.
y = xy(:, 1); % Rows.
