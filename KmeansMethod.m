clc
close all
clear all

%% Input
[I,path]=uigetfile('*.png','select a input image');
str=strcat(path,I);
I=imread(str);

figure;
imshow(I);
title('Input image','FontSize',20);

%% Grayscale conversion 
num_iter = 10;
delta_t = 1/7;
kappa = 15;
option = 2;
disp('Preprocessing image please wait . . .');
inp = anisodiff(I,num_iter,delta_t,kappa,option);
inp = uint8(inp);

inp=imresize(inp,[256,256]);

if size(inp,3)>1
    inp=rgb2gray(inp);
end
figure;
imshow(inp);
title('Filtered image','FontSize',20);

%% Segmentation USing K-means Clustering 
Idata=reshape(inp, [],1);
Idata=double(Idata);

[Idx, nn]=kmeans(Idata,4);
Imsame=reshape(Idx,size(inp));
figure;
imshow(Imsame, [])
imshow(Imsame==2, []); % Tumor in this cluster 
figure
subplot(2,2,1); imshow(Imsame==1, []);
subplot(2,2,2); imshow(Imsame==2, []);
subplot(2,2,3); imshow(Imsame==3, []);
subplot(2,2,4); imshow(Imsame==4, []);
 
 bw =(Imsame == 2);
 SE=ones(5); % small 
 %SE=ones(15); % big 
 bw=imopen(bw,SE);
 figure;
 imshow(bw);
 title('Brain Tumor with other small unwanted objects');
 bw = bwareaopen(bw,400);
 figure;
 imshow(bw)
 title('Segmented Brain Tumor')


%% Brain Tumor Detection based on Tumor Solidity (Used for GUI development)
stats=regionprops(bw,'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];
High_Density_Area=density > 0.6; % reduce to detect small or early stage tumors 
MaxArea = max(area(High_Density_Area));
tumor_label = find(area==MaxArea);
tumor = ismember(bw,tumor_label);

%% Bounding Box
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
%figure
%imshow(erodedImage);
%title('eroded image','FontSize',20);


tumorOutline=tumor - erodedImage;
figure;
imshow(tumorOutline);

%% Calculate the area, in pixels
numWhitePixels = sum(tumor(:));

measurements = regionprops(tumor,  ...
    'Area', 'Centroid', 'Perimeter');

area = [measurements.Area];
centroid = [measurements.Centroid];
perimeter = [measurements.Perimeter];

numberOfWhitePixels = bwarea(tumor);

%convert into mm
area_tumor = numberOfWhitePixels * (0.26458333)^2;
perimeter_tumor = perimeter * 0.26458333;

% Get coordinates of the boundary in tumor
structBoundaries = bwboundaries(tumor);
xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
x = xy(:, 2); % Columns.
y = xy(:, 1); % Rows.






