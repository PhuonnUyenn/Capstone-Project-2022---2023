function varargout = TESsT(varargin)
% TESsT MATLAB code for TESsT.fig
%      TESsT, by itself, creates a new TESsT or raises the existing
%      singleton*.
%
%      H = TESsT returns the handle to a new TESsT or the handle to
%      the existing singleton*.
%
%      TESsT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESsT.M with the given input arguments.
%
%      TESsT('Property','Value',...) creates a new TESsT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TESsT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TESsT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TESsT

% Last Modified by GUIDE v2.5 17-Dec-2022 13:38:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TESsT_OpeningFcn, ...
                   'gui_OutputFcn',  @TESsT_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before TESsT is made visible.
function TESsT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TESsT (see VARARGIN)

% Choose default command line output for TESsT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TESsT wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TESsT_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global brainImg 

[filename, pathname] = uigetfile({'*.png';'*.jpg'; '*.bmp'; '*.tif';'*.gif'; '*.jpeg'}, 'Load Image File');

if isequal(filename,0)||isequal(pathname,0)
    warndlg('Press OK to continue', 'Warning');
    
else
    brainImg = imread([pathname filename]);
    brainImg = imresize(brainImg,[256,256]);
    
    axes(handles.axes1);
    imshow(brainImg);
    axis off
    helpdlg(' Image loaded successfully ', 'Alert'); 
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global brainImg inp

num_iter = 10;
delta_t = 1/7;
kappa = 15;
option = 2;

inp = anisodiff(brainImg,num_iter,delta_t,kappa,option);

inp = uint8(inp);

inp = imresize(inp,[256,256]);
if size(inp,3)>1
    inp = rgb2gray(inp);
end
axes(handles.axes2);
imshow(inp);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global inp im_seg max_area luachonseg im_tumoralone tumor_label label stats density area sout h im_seg1 level1 fim
luachonseg = get(handles.popupmenu2,'value');

if (luachonseg == 1) 
    SE = ones(5);
    im_seg = imopen(im_seg, SE);
    im_tumoralone = bwareaopen(im_seg, 600);
    
    stats = regionprops(im_seg,'Solidity','Area','BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];
    High_Density_Area = density > 0.5; % reduce to detect small or early stage tumors
    max_area = max(area(High_Density_Area));
    
    if max_area > 100
       axes(handles.axes4);
       imshow(im_tumoralone);
    else
        h = msgbox('No Tumor!!','status');
        return;
    end
    
elseif (luachonseg == 2)
    sout = imresize(inp,[256,256]);
    t0 = 10;
    th = t0 +((max(inp(:)) + min(inp(:)))./2);
    for i = 1:1:size(inp,1)
        for j = 1:1:size(inp,2)
            if inp(i,j) > th
                sout(i,j) = 1;
            else
                sout(i,j) = 0;
            end
        end
    end
    label = bwlabel(sout);
    stats = regionprops(logical(sout),'Solidity','Area','BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];
    high_dense_area = density > 0.6;
    max_area = max(area(high_dense_area));
    tumor_label = find(area == max_area);
    im_tumoralone = ismember(label,tumor_label);

    if max_area>100
       axes(handles.axes4);
       imshow(im_tumoralone);
    else
        h = msgbox('No Tumor!!','status');
        return;
    end
    
elseif (luachonseg == 3)    
    im_seg = (im_seg == 3);
    SE = ones(10); % small 
    %SE=ones(15); % big 
    im_seg = imopen(im_seg,SE);
    im_tumoralone = bwareaopen(im_seg, 400);
    
    stats = regionprops(logical(im_seg),'Solidity','Area','BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];
    high_dense_area = density > 0.6;
    max_area = max(area(high_dense_area));
    
    if max_area > 100   
       axes(handles.axes4);
       imshow(im_tumoralone);
    else
        h = msgbox('No Tumor!!','status');
        return;
    end
elseif (luachonseg == 4)
    [im_seg1,level1] = fcmthresh(fim,1);
    SE = ones(10);
    im_seg1 = imopen(im_seg1,SE);
    im_tumoralone = bwareaopen(im_seg1, 500);
    
    stats = regionprops(logical(im_seg1),'Solidity','Area','BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];
    high_dense_area = density > 0.7;
    max_area = max(area(high_dense_area));
    
    if max_area > 100
       axes(handles.axes4);
       imshow(im_tumoralone);
    else
        h = msgbox('No Tumor!!','status');
        return;
    end
end  

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global luachonseg max_area tumor_label im_tumoralone1 inp sout wantedBox im_seg im_seg1 h
luachonseg = get(handles.popupmenu2,'value');

if (luachonseg == 1)
    stats = regionprops(im_seg,'Solidity','Area','BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];
    High_Density_Area = density > 0.5; % reduce to detect small or early stage tumors

    max_area = max(area(High_Density_Area));
    tumor_label = find(area == max_area);
    im_tumoralone1 = ismember(im_seg,tumor_label);

    if max_area > 100
        box = stats(tumor_label);
        wantedBox = box.BoundingBox;
        axes(handles.axes5);
        imshow(inp);
        hold on;
        rectangle('Position',wantedBox,'EdgeColor','y');
        hold off;
    else
        h = msgbox('No Tumor!!','status');
        return;
    end

elseif (luachonseg == 2)
    label = bwlabel(sout);
    stats = regionprops(logical(sout),'Solidity','Area','BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];
    high_dense_area = density>0.6;
    max_area = max(area(high_dense_area));
    tumor_label = find(area == max_area);
    im_tumoralone1 = ismember(label,tumor_label);
    
    if max_area > 100
        box = stats(tumor_label);
        wantedBox = box.BoundingBox;
        axes(handles.axes5);
        imshow(inp);
        hold on;
        rectangle('Position',wantedBox,'EdgeColor','y');
        hold off;
    else
        h = msgbox('No Tumor!!','status');
        return;
    end
    
elseif (luachonseg == 3)   
    stats = regionprops(logical(im_seg),'Solidity','Area','BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];
    high_dense_area = density > 0.6;
    max_area = max(area(high_dense_area));
    tumor_label = find(area == max_area);
    im_tumoralone1 = ismember(im_seg,tumor_label);
    
    if max_area > 100
        box = stats(tumor_label);
        wantedBox = box.BoundingBox;
        axes(handles.axes5);
        imshow(inp);
        hold on;
        rectangle('Position',wantedBox,'EdgeColor','y');
        hold off;
    else
        h = msgbox('No Tumor!!','status');
        return;
    end
elseif (luachonseg == 4)
    stats = regionprops(logical(im_seg1),'Solidity','Area','BoundingBox');
    density = [stats.Solidity];
    area = [stats.Area];
    high_dense_area = density > 0.6;
    max_area = max(area(high_dense_area));
    tumor_label = find(area == max_area);
    im_tumoralone1 = ismember(im_seg1,tumor_label);
    
    if max_area > 100
        box = stats(tumor_label);
        wantedBox = box.BoundingBox;
        axes(handles.axes5);
        imshow(inp);
        hold on;
        rectangle('Position',wantedBox,'EdgeColor','y');
        hold off;
    else
        h = msgbox('No Tumor!!','status');
        return;
    end
    
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global luachonseg im_tumoralone1 erodedImage tumorOutline filledImage dilationAmount
luachonseg = get(handles.popupmenu2,'value');

if (luachonseg == 1)  
    dilationAmount = 5;
    rad = floor(dilationAmount);
    [r,c] = size(im_tumoralone1);
    filledImage = imfill(im_tumoralone1, 'holes');

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
    tumorOutline = im_tumoralone1 - erodedImage;
    
    axes(handles.axes6);
    imshow(tumorOutline);
    
elseif (luachonseg == 2)    
    dilationAmount = 5;
    rad = floor(dilationAmount);
    [r,c] = size(im_tumoralone1);
    filledImage = imfill(im_tumoralone1, 'holes');

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
    tumorOutline = im_tumoralone1 - erodedImage;

    axes(handles.axes6);
    imshow(tumorOutline);
    
elseif (luachonseg == 3)
    dilationAmount = 5;
    rad = floor(dilationAmount);
    [r,c] = size(im_tumoralone1);
    filledImage = imfill(im_tumoralone1, 'holes');

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
    tumorOutline = im_tumoralone1 - erodedImage;
    
    axes(handles.axes6);
    imshow(tumorOutline);
    
elseif (luachonseg == 4)
    dilationAmount = 5;
    rad = floor(dilationAmount);
    [r,c] = size(im_tumoralone1);
    filledImage = imfill(im_tumoralone1, 'holes');

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
    tumorOutline = im_tumoralone1 - erodedImage;
    
    axes(handles.axes6);
    imshow(tumorOutline);    

end

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global luachonseg im_tumoralone area perimeter x y  centroid numberOfPixels2  
luachonseg = get(handles.popupmenu2,'value');
% handles = guidata(hObject);

if (luachonseg == 1)
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
    
    % Get coordinates of the boundary in tumor
    structBoundaries = bwboundaries(im_tumoralone);
    xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
    x = xy(:, 2); % Columns.
    y = xy(:, 1); % Rows.
    
    set(handles.text10,'String',area);
    set(handles.text11,'String',perimeter);
    set(handles.text12,'String',centroid);    

elseif (luachonseg == 2)
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
    
    % Get coordinates of the boundary in tumor
    structBoundaries = bwboundaries(im_tumoralone);
    xy = structBoundaries{1}; % Get n by 2 array of x,y coordinates.
    x = xy(:, 2); % Columns.
    y = xy(:, 1); % Rows.
    
    set(handles.text10,'String',area);
    set(handles.text11,'String',perimeter);
    set(handles.text12,'String',centroid);
    
elseif (luachonseg == 3)
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
    
    % Get coordinates of the boundary in tumor
    structBoundaries = bwboundaries(im_tumoralone);
    xy = structBoundaries{1}; % Get n by 2 array of x,y coordinates.
    x = xy(:, 2); % Columns.
    y = xy(:, 1); % Rows.
    
    set(handles.text10,'String',area);
    set(handles.text11,'String',perimeter);
    set(handles.text12,'String',centroid);

elseif (luachonseg == 4)
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
    
    % Get coordinates of the boundary in tumor
    structBoundaries = bwboundaries(im_tumoralone);
    xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
    x = xy(:, 2); % Columns.
    y = xy(:, 1); % Rows.
    
    set(handles.text10,'String',area);
    set(handles.text11,'String',perimeter);
    set(handles.text12,'String',centroid);
    
end
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1); cla(handles.axes1); title('');
axes(handles.axes2); cla(handles.axes2); title('');
axes(handles.axes3); cla(handles.axes3); title('');
axes(handles.axes4); cla(handles.axes4); title('');
axes(handles.axes5); cla(handles.axes5); title('');
axes(handles.axes6); cla(handles.axes6); title('');


set(handles.text10,'String','');
set(handles.text11,'String','');
set(handles.text12,'String','');
set(handles.text20,'String','');
set(handles.text21,'String','');
set(handles.text22,'String','');
set(handles.text23,'String','');
set(handles.text24,'String','');


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
luachonseg = get(hObject,'Value');
global inp im_thr im_adjust im_seg level BW SE_erode Idata Idx nn level0 fim im_seg0
if(luachonseg ==1)
    inp = imresize(inp,[256,256]);   
    im_thr = imtophat(inp,strel('disk',40));
    im_adjust = imadjust(im_thr);
    level = graythresh(im_adjust);
    BW = im2bw(im_adjust,level);
    SE_erode = strel('disk',3);
    im_seg = imerode(BW,SE_erode);
        
    axes(handles.axes3);
    imshow(im_seg); 
    
elseif (luachonseg == 2)
    sout = imresize(inp,[256,256]);
    t0 = 10;
    th = t0+((max(inp(:)) + min(inp(:)))./2);
    for i = 1:1:size(inp,1)
        for j = 1:1:size(inp,2)
            if inp(i,j) > th
                sout(i,j) = 1;
            else
                sout(i,j) = 0;
            end
        end
    end
    hy = fspecial('sobel');
    hx = hy';
    Iy = imfilter(double(sout), hy, 'replicate');
    Ix = imfilter(double(sout), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);
    L = watershed(gradmag);
    im_seg = label2rgb(L);
    
    axes(handles.axes3);
    imshow(im_seg);
    
elseif (luachonseg == 3)
    Idata = reshape(inp, [],1);
    Idata = double(Idata);
    [Idx, nn] = kmeans(Idata, 3);
    im_seg = reshape(Idx,size(inp)); 
    
    axes(handles.axes3);
    imshow(im_seg, []); 
    
elseif (luachonseg == 4)
    inp = imresize(inp,[256,256]);
    fim = mat2gray(inp);
    level = graythresh(fim);
    [im_seg0,level0] = fcmthresh(fim,0);
    
    axes(handles.axes3);
    imshow(im_seg0)
end
% --- Executes on selection change in popupmenu2.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text4 as text
%        str2double(get(hObject,'String')) returns contents of text4 as a double


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text5 as text
%        str2double(get(hObject,'String')) returns contents of text5 as a double


% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text6 as text
%        str2double(get(hObject,'String')) returns contents of text6 as a double


% --- Executes during object creation, after setting all properties.
function text6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pushbutton7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global im_tumoralone im_tumoralone2 im_mask Accuracy Sensitivity Fmeasure Precision MCC Dice Jaccard Specitivity

[filename, pathname] = uigetfile({'*.png';'*.jpg'; '*.bmp'; '*.tif';'*.gif'; '*.jpeg'}, 'Load Mask File');
im_mask = imread([pathname filename]);
im_mask = imresize(im_mask,[256,256]);
im_mask = im2bw(im_mask, 0.5);
        
im_tumoralone2 = imresize(im_tumoralone,[256,256]);
im_tumoralone2 = im2bw(im_tumoralone2, 0.5);

[Accuracy, Sensitivity, Fmeasure, Precision, MCC, Dice, Jaccard, Specitivity] = EvaluateImageSegmentationScores(im_mask, im_tumoralone2);

set(handles.text20,'String',Accuracy);
set(handles.text21,'String',Fmeasure);
set(handles.text22,'String',Precision);
set(handles.text23,'String',Specitivity);
set(handles.text24,'String',Sensitivity);
    
    
    
