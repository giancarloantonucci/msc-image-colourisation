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