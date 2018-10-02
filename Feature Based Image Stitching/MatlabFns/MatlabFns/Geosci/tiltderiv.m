% TILTDERIV  Tilt derivative of potential field data
%
% Usage: td = tiltderiv(im, padding)
%
% Arguments:    im - Input potential field image.
%          padding - Width of tapered padding to apply to the image to reduce 
%                    edge effects. Depending on the degree of cyclic
%                    discontinuity in your data values of up to, say, 100
%                    can be useful. Defaults to 0.
%
% Returns:      td - The tilt derivative.
%
% Use of the DEALIAS function can be useful prior to computing the tilt
% derivative.
%
% Reference:  
% Hugh G. Miller and Vijay Singh. Potential field tilt - a new concept for
% location of potential field sources. Applied Geophysics (32) 1994. pp
% 213-217.
%
% See also: VERTDERIV, HORIZDERIV, DEALIAS

% Copyright (c) 2015-2017 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.
%
% March   2015  
% October 2017 - Changed to use frequency domain horizontal derivatives and
%                to allow for data padding.

function  td = tiltderiv(im, padding)

    assert(size(im,3) == 1, 'Image must be single channel');
    
    if ~exist('padding', 'var'), padding = 0; end
    im = impad(im, padding, 'taper');
    
    [gx, gy] = horizderiv(im, 1);
    gz = vertderiv(im, 1);
    
    td = imtrim(atan(gz./sqrt(gx.^2 + gy.^2)), padding);