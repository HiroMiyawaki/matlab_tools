function [h,s,v] = rgb2hsv(r,g,b)
%RGB2HSV Convert red-green-blue colors to hue-saturation-value.
%   H = RGB2HSV(M) converts an RGB color map to an HSV color map.
%   Each map is a matrix with any number of rows, exactly three columns,
%   and elements in the interval 0 to 1.  The columns of the input matrix,
%   M, represent intensity of red, blue and green, respectively.  The
%   columns of the resulting output matrix, H, represent hue, saturation
%   and color value, respectively.
%
%   HSV = RGB2HSV(RGB) converts the RGB image RGB (3-D array) to the
%   equivalent HSV image HSV (3-D array).
%
%   CLASS SUPPORT
%   -------------
%   If the input is an RGB image, it can be of class uint8, uint16, single,
%   or double. The output image is single when the input is single. For all 
%   other input data types, the output image is double. If the input is a
%   colormap, the input and output colormaps are both of class double.
%
%   See also HSV2RGB, COLORMAP, RGBPLOT.

%   Undocumented syntaxes:
%   [H,S,V] = RGB2HSV(R,G,B) converts the RGB image R,G,B to the
%   equivalent HSV image H,S,V.
%
%   HSV = RGB2HSV(R,G,B) converts the RGB image R,G,B to the
%   equivalent HSV image stored in the 3-D array (HSV).
%
%   [H,S,V] = RGB2HSV(RGB) converts the RGB image RGB (3-D array) to
%   the equivalent HSV image H,S,V.
%
%   See Alvy Ray Smith, Color Gamut Transform Pairs, SIGGRAPH '78.

%   Copyright 1984-2014 The MathWorks, Inc.


threeD = (ndims(r)==3);
switch nargin
    case 1
        if threeD
            if(size(r,3) ~= 3)
                error(message('MATLAB:rgb2hsv:invalidInputSizeRGB'));
            end
            
            validateattributes(r, {'uint8', 'uint16', 'double', 'single'}, {'real'}, mfilename, 'RGB', 1);
            
            if isa(r, 'uint8')
                r = double(r) / 255;
            elseif isa(r, 'uint16')
                r = double(r) / 65535;
            end
            
            g = r(:,:,2); b = r(:,:,3); r = r(:,:,1);
            siz = size(r);
            r = r(:); g = g(:); b = b(:);
            
        elseif ismatrix(r)
            if(size(r,2) ~=3)
                error(message('MATLAB:rgb2hsv:invalidSizeForColormap'));
            end
            
            validateattributes(r, {'double'}, {'real','nonempty','nonsparse'}, mfilename, 'M');
            
            if((any(r(:) < 0) || any(r(:) > 1)))
                error(message('MATLAB:rgb2hsv:badMapValues'));
            end
            
            g = r(:,2); b = r(:,3); r = r(:,1);
            siz = size(r);
        else
            error(message('MATLAB:rgb2hsv:invalidInputSize'));
        end
        
    case 3
        validateattributes(r, {'uint8', 'uint16', 'double', 'single'}, {'real', '2d'}, mfilename, 'R', 1);
        validateattributes(g, {'uint8', 'uint16', 'double', 'single'}, {'real', '2d'}, mfilename, 'G', 2);
        validateattributes(b, {'uint8', 'uint16', 'double', 'single'}, {'real', '2d'}, mfilename, 'B', 3);
        
        if ~isequal(size(r),size(g),size(b))
            error(message('MATLAB:rgb2hsv:InputSizeMismatch'));
        end
        
        if isa(r, 'uint8')
            r = double(r) / 255;
        elseif isa(r, 'uint16')
            r = double(r) / 65535;
        end
        
        if isa(g, 'uint8')
            g = double(g) / 255;
        elseif isa(g, 'uint16')
            g = double(g) / 65535;
        end
        
        if isa(b, 'uint8')
            b = double(b) / 255;
        elseif isa(b, 'uint16')
            b = double(b) / 65535;
        end
        
        siz = size(r);
        r = r(:); g = g(:); b = b(:);
    otherwise
        error(message('MATLAB:rgb2hsv:WrongInputNum'));
end

v = max(max(r,g),b);
h = zeros(size(v), 'like', r);
s = (v - min(min(r,g),b));

z = ~s;
s(z) = 1;
k = (r == v);
h(k) = (g(k) - b(k))./s(k);
k = (g == v);
h(k) = 2 + (b(k) - r(k))./s(k);
k = (b == v);
h(k) = 4 + (r(k) - g(k))./s(k);
h = h/6;
k = (h < 0);
h(k) = h(k) + 1;
h(z) = 0;

tmp = s./v;
tmp(z) = 0;
k = (v~=0);
s(k) = tmp(k);
s(~v) = 0;

if nargout<=1
    if (threeD || nargin==3)
        h = reshape(h,siz);
        s = reshape(s,siz);
        v = reshape(v,siz);
        h=cat(3,h,s,v);
    else
        h=[h s v];
    end
else
    h = reshape(h,siz);
    s = reshape(s,siz);
    v = reshape(v,siz);
end
