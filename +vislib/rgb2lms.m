function imgout = rgb2lms(img, M)
% RGB2LMS  Convert a camera-RGB image to human LMS cone space.
%   imgout = vislib.rgb2lms(img, M)
%
%   Applies a 3x3 camera-RGB -> LMS colour matrix to every pixel and clips
%   negative cone responses to zero.
%
%   Inputs
%     img - [H x W x 3] image in the camera's linear RGB space.
%     M   - 3x3 matrix mapping an RGB pixel (row vector) to [L M S].
%
%   Output
%     imgout - [H x W x 3] image in LMS cone space (non-negative).
%
%   See also VISLIB.PTCH_NORM.

    [h, w, d] = size(img);
    pix    = reshape(img, [], d) * M;          % apply colour transform per pixel
    imgout = max(reshape(pix, h, w, 3), 0);    % clip negative cone responses
end
