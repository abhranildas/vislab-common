function [ptchout, mnv] = ptch_norm(ptch, m0, c0, ntype, ncolr)
% PTCH_NORM  Normalize an image patch's mean and/or contrast.
%   [ptchout, mnv] = vislib.ptch_norm(ptch, m0, c0, ntype, ncolr)
%
%   Rescales a patch to a target mean grey level (and optionally RMS contrast)
%   using one of several conventions. This is the canonical version: it keeps
%   the exact numerics of the texture-learning implementation (which is correct
%   and the most complete) and supersedes the duplicated copies in the project
%   repos and the buggy root +lib copy (whose ntype==2 used an undefined var).
%
%   Inputs
%     ptch  - image patch, [H x W] (grayscale) or [H x W x 3] (colour).
%     m0    - target mean grey level (e.g. 128).
%     c0    - target RMS contrast (used only for ntype == 2).
%     ntype - normalization type:
%               0 = none
%               1 = mean       : scale each channel to mean m0
%               2 = mean+contrast : per channel, set mean to m0 and RMS
%                   contrast to c0, then clip negatives to 0
%               3 = average mean : scale the whole patch so the mean across
%                   the channel means is m0 (colour)
%               4 = as ntype 3, then reverse contrast about m0 (colour)
%     ncolr - number of colour channels, 1 or 3 (default: size(ptch,3)).
%
%   Outputs
%     ptchout - normalized patch, same size as ptch.
%     mnv     - 3x1 vector of original per-channel means (unused entries 0).
%
%   See also VISLIB.CNTRST_NORM.

    if nargin < 5 || isempty(ncolr)
        ncolr = size(ptch, 3);
    end
    mnv = zeros(3, 1);

    switch ntype
        case 0                                      % no normalization
            ptchout = ptch;

        case 1                                      % scale each channel to mean m0
            mnv(1:ncolr) = squeeze(mean(ptch, [1 2]));
            ptchout = ptch .* reshape(m0 ./ mnv(1:ncolr), 1, 1, ncolr);

        case 2                                      % mean m0 + RMS contrast c0, per channel
            ptchout = zeros(size(ptch));
            npix = size(ptch, 1) * size(ptch, 2);
            for k = 1:ncolr
                ch     = ptch(:, :, k);
                mnv(k) = mean(ch(:));
                ch     = ch * m0 / mnv(k);              % set mean to m0
                sd     = sqrt(sum((ch(:) - m0).^2) / npix);  % RMS about m0
                ch     = c0 * m0 * (ch - m0) / sd + m0;      % set contrast to c0
                ptchout(:, :, k) = max(ch, 0);          % clip negatives
            end

        case 3                                      % scale whole patch to average mean m0
            mnv(1:ncolr) = squeeze(mean(ptch, [1 2]));
            ptchout = ptch * m0 / mean(mnv(1:ncolr));

        case 4                                      % as ntype 3, contrast-reversed about m0
            mnv(1:ncolr) = squeeze(mean(ptch, [1 2]));
            ptchout = ptch * m0 / mean(mnv(1:ncolr));
            ptchout = -(ptchout - m0) + m0;

        otherwise
            error('vislib:ptch_norm:badNtype', 'ntype must be 0-4, got %g.', ntype);
    end
end
