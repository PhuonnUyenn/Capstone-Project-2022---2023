clc
close all
clear all

%%
[filename,path]=uigetfile('*.png','select a input image');
str = strcat(path,filename);
brainImg = imread(str);

figure;
imshow(brainImg);
title('Input image','FontSize',20);

%%
num_iter = 10;
delta_t = 1/7;
kappa = 15;
option = 2;

inp = anisodiff(brainImg,num_iter,delta_t,kappa,option);
inp = uint8(inp);

inp=imresize(inp,[256,256]);
if size(inp,3)>1
    inp=rgb2gray(inp);
end
imshow(inp);

%% thresholding
sout=imresize(inp,[256,256]);
t0 = 15;
th=t0+((max(inp(:))+min(inp(:)))./2);
for i=1:1:size(inp,1)
    for j=1:1:size(inp,2)
        if inp(i,j)>th
            sout(i,j)=1;
        else
            sout(i,j)=0;
        end
    end
end
%% watershed segmentation
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(sout), hy, 'replicate');
Ix = imfilter(double(sout), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
L = watershed(gradmag);
Lrgb = label2rgb(L);
imshow(Lrgb);

%% Bounding box
label=bwlabel(sout);
stats=regionprops(logical(sout),'Solidity','Area','BoundingBox');
density=[stats.Solidity];
area=[stats.Area];

high_dense_area = density>0.6;

max_area=max(area(high_dense_area));
tumor_label=find(area==max_area);
tumor = ismember(label,tumor_label);

box = stats(tumor_label);
wantedBox = box.BoundingBox;
imshow(inp);
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
imshow(tumorOutline);

%% Area and Perimeter of Brain tumor
measurements = regionprops(tumor,  ...
    'area', 'Centroid', 'Perimeter');

area = [measurements.Area];
centroid = [measurements.Centroid];
perimeter = [measurements.Perimeter];

numberOfPixels2 = bwarea(tumor);

area = numberOfPixels2*(0.26458333)^2;
perimeter1=perimeter*0.26458333;

% Get coordinates of the boundary in tumor
structBoundaries = bwboundaries(tumor);
xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
x = xy(:, 2); % Columns.
y = xy(:, 1); % Rows.
