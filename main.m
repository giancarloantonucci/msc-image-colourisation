%% What the user can change
string = 'image.jpg';   % reference image to test the process
nPixels = 1000;         % number random colour points
sigma1 = 400; sigma2 = 300; p = .5; delta = 2e-8; % parameters
func = 'gauss'; % radial basis function, 'compact' is the alternative

%% Get the coloured image
original = imread(string);
[nRows, nCols, ~] = size(original);

%% Get the greyscale image
coef = [.3 .11 .59];
grey = col2grey(original,coef(1),coef(2),coef(3));

%% Get the greyscale image with some random colour information on it
% pixels = randperm(nRows*nCols, nPixels)';
% semicoloured = grey;
% for i = 0:2
%     semicoloured(pixels + i*nRows*nCols) = original(pixels + i*nRows*nCols);
% end

%% Get the recoloured image
% Set the radial basis function for the kernel
switch func
    case 'gauss'
        phi = @(r) exp(-r.^2);
    case 'compact'
        phi = @(r) max(1-r,0).^4.*(4*r+1);
end

% Build the kernel matrix from the known colour information
[pxRows,pxCols] = ind2sub([nRows, nCols], pixels);

resKernel = zeros(nPixels);
for k = 1:nPixels
    idx = (k+1:nPixels)';
    resKernel(idx,k) = phi(sqrt((pxRows(k)-pxRows(idx)).^2+(pxCols(k)-pxCols(idx)).^2)/sigma1) ...
        .* phi(abs(double(grey(pixels(k)))-double(grey(pixels(idx)))).^p/sigma2);
end
resKernel = resKernel + resKernel' + eye(nPixels);

% Build the kernel matrix for the full colour information
totIndeces = (1:nRows*nCols)';
[totRows, totCols] = ind2sub([nRows, nCols], totIndeces);

totKernel = zeros(nRows*nCols, nPixels);
for k = 1:nPixels
    totKernel(:,k) = phi(sqrt((pxRows(k)-totRows).^2+(pxCols(k)-totCols).^2)/sigma1) ...
        .* phi(abs(double(grey(pixels(k)))-double(grey(totIndeces))).^p/sigma2);
end

% Solve the system for coefficients a, and recolour the image
recoloured = zeros(size(original),'uint8');
for i = 0:2
    f = double(original(pixels + i*nRows*nCols));
    a = (resKernel + delta*nPixels*eye(nPixels))\f;
    F = totKernel*a;
    F = reshape(F,nRows,nCols);
    recoloured(:,:,i+1) = uint8(F);
end

%% Plotting
subplot(1,3,1)
imshow(original)
title('RGB')
subplot(1,3,2)
imshow(grey)
title('Greyscale')
subplot(1,3,3)
imshow(recoloured)
title('Recoloured')