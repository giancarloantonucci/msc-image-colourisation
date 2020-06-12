function varargout = Colourisation(varargin)
% COLOURISATION MATLAB code for Colourisation.fig
%      COLOURISATION, by itself, creates a new COLOURISATION or raises the existing
%      singleton*.
%
%      H = COLOURISATION returns the handle to a new COLOURISATION or the handle to
%      the existing singleton*.
%
%      COLOURISATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLOURISATION.M with the given input arguments.
%
%      COLOURISATION('Property','Value',...) creates a new COLOURISATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Colourisation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Colourisation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Colourisation

% Last Modified by GUIDE v2.5 08-May-2017 06:58:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Colourisation_OpeningFcn, ...
                   'gui_OutputFcn',  @Colourisation_OutputFcn, ...
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


% --- Executes just before Colourisation is made visible.
function Colourisation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Colourisation (see VARARGIN)

% Choose default command line output for Colourisation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Colourisation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Colourisation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonRecolour.
function pushbuttonRecolour_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonRecolour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
string = 'Running...';
set(handles.infoRecoloured, 'String', string);

nRows = handles.nRows;
nCols = handles.nCols;
nPixels = handles.nPixels;
pixels = handles.pixels;
phi = handles.phi;
grey = handles.Grey;
semicoloured = handles.Semicoloured;
sigma1 = handles.sigma1;
sigma2 = handles.sigma2;
delta = handles.delta;
p = handles.p;

[pxRows,pxCols] = ind2sub([nRows, nCols], pixels);

resKernel = zeros(nPixels);
compTime = 0;
tic,
for k = 1:nPixels
    idx = (k+1:nPixels)';
    resKernel(idx,k) = phi(sqrt((pxRows(k)-pxRows(idx)).^2+(pxCols(k)-pxCols(idx)).^2)/sigma1) ...
        .* phi(abs(double(grey(pixels(k)))-double(grey(pixels(idx)))).^p/sigma2);
end
resKernel = resKernel + resKernel' + eye(nPixels);
compTime = compTime + toc;

% 
totIndeces = (1:nRows*nCols)';
[totRows, totCols] = ind2sub([nRows, nCols], totIndeces);

totKernel = zeros(nRows*nCols, nPixels);
tic,
for k = 1:nPixels
    % Something intelligent could be used to reuse the entries of the
    % restricted kernel
    totKernel(:,k) = phi(sqrt((pxRows(k)-totRows).^2+(pxCols(k)-totCols).^2)/sigma1) ...
        .* phi(abs(double(grey(pixels(k)))-double(grey(totIndeces))).^p/sigma2);
end
compTime = compTime + toc;

%
recoloured = zeros(size(semicoloured),'uint8');
tic,
for i = 0:2
    f = double(semicoloured(pixels + i*nRows*nCols));
    a = (resKernel + delta*nPixels*eye(nPixels))\f;
    F = totKernel*a;
    F = reshape(F,nRows,nCols);
    recoloured(:,:,i+1) = uint8(F);
end
compTime = compTime + toc;

handles.Recoloured = recoloured;
axes(handles.axesRecoloured);
imshow(handles.Recoloured);
string = ['Computational time required is ' num2str(compTime) ' seconds.'];
set(handles.infoRecoloured, 'String', string);
guidata(hObject,handles)


% --- Executes on button press in pushbuttonLoadImage.
function pushbuttonLoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename pathname] = uigetfile({'*.jpg';'*.bmp'},'File Selector');
original = imread(strcat(pathname, filename));
[nRows, nCols, ~] = size(original);
string = ['Size is ' num2str(nRows) 'x' num2str(nCols) ' pixels.'];

handles.Original = original;
handles.nRows = nRows;
handles.nCols = nCols;

axes(handles.axesOriginal);
imshow(handles.Original);
set(handles.infoOriginal, 'String', string);

string = 'Good. Now convert it to greyscale.';
set(handles.textComment, 'String', string);
guidata(hObject,handles)


% --- Executes on button press in pushbuttonMakeGrey.
function pushbuttonMakeGrey_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonMakeGrey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
original = handles.Original;

coef = [.3 .11 .59];
grey = col2grey(original,coef(1),coef(2),coef(3));
 
handles.Grey = grey;

axes(handles.axesGrey);
imshow(handles.Grey);

string = ['Choose some random pixels to colourise with the slider (Look'...
    ' the greyscale image). Now, choose the other values (press again),'...
    ' and recolourise.'];
set(handles.textComment, 'String', string);
guidata(hObject,handles)

% --- Executes on slider movement.
function sliderAddColour_Callback(hObject, eventdata, handles)
% hObject    handle to sliderAddColour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
nRows = handles.nRows;
nCols = handles.nCols;
original = handles.Original;
grey = handles.Grey;

value = get(handles.sliderAddColour,'Value');
maxNPixels = min(nRows*nCols, 1000);
nPixels = round(maxNPixels*value);

pixels = randperm(nRows*nCols, nPixels)';
semicoloured = grey;
for i = 0:2
    semicoloured(pixels + i*nRows*nCols) = original(pixels + i*nRows*nCols);
end

handles.nPixels = nPixels;
handles.pixels = pixels;
handles.Semicoloured = semicoloured;

axes(handles.axesGrey);
imshow(handles.Semicoloured);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function sliderAddColour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderAddColour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editSigma2_Callback(hObject, eventdata, handles)
% hObject    handle to editSigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSigma2 as text
%        str2double(get(hObject,'String')) returns contents of editSigma2 as a double
sigma2 = str2double(get(hObject, 'String'));
if isnan(sigma2)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

handles.sigma2 = sigma2;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editSigma2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigma2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSigma1_Callback(hObject, eventdata, handles)
% hObject    handle to editSigma1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSigma1 as text
%        str2double(get(hObject,'String')) returns contents of editSigma1 as a double
sigma1 = str2double(get(hObject, 'String'));
if isnan(sigma1)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

handles.sigma1 = sigma1;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editSigma1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSigma1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editP_Callback(hObject, eventdata, handles)
% hObject    handle to editP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editP as text
%        str2double(get(hObject,'String')) returns contents of editP as a double
p = str2double(get(hObject, 'String'));
if isnan(p)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

handles.p = p;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDelta_Callback(hObject, eventdata, handles)
% hObject    handle to editDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDelta as text
%        str2double(get(hObject,'String')) returns contents of editDelta as a double
delta = str2double(get(hObject, 'String'));
if isnan(delta)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

handles.delta = delta;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editDelta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDelta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(get(handles.uibuttongroup1,'SelectedObject'),'Tag')
    case 'radiobuttonGaussian'
        phi = @(r) exp(-r.^2);
    case 'radiobuttonComSupp'
        phi = @(r) max(1-r,0).^4.*(4*r+1);
end

handles.phi = phi;
guidata(hObject, handles);

function img = col2grey(img,r,g,b)
% IMG = COL2GREY(IMG,R,G,B) converts IMG from RGB to BW, using a linear
% combination of the RGB layers with coefficients R, G and B.
% Note that the coefficients must be normalised.
% 
% Giancarlo Antonucci, May 2017.

img = img(:,:,1)*r + img(:,:,2)*g + img(:,:,3)*b;
img = repmat(img,[1,1,3]);
if isfloat(img)
    img = round(img);
end
img = uint8(img);
