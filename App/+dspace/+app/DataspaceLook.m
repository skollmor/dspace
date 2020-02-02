classdef DataspaceLook < dspace.app.DataspaceLook_whiteTheme
    % Change the constants defined in this class to adjust the dataspace
    % GUI appearence.
    %
    % There are two blocks of constants:
    % (1) Looks
    % (2) Other Constants
    %
    % Best practice is to copy a block, comment out the original, and then make changes.
    %
    % <a href="matlab:edit dspace.app.DataspaceLook">Edit dspace.app.DataspaceLook</a>
    %
    %
    %
    % 
    %
    %<PRE>
    % This file is part of dspace-GUI.
    % 
    % Copyright (C) 2020 University Zurich, Sepp Kollmorgen
    % 
    % dspace-GUI is licenced under a custom license (see LICENSE file).
    % 
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    % </PRE>
    % <b>Dataspace on Github</b>: <a href="matlab:web('https://github.com/skollmor/dspace', '-browser')">https://github.com/skollmor/dspace</a>

    
    
    %% Other Constants
    properties (Constant)
        variablePrefixes = {'t_', 'E_', 'LG', 'SQ', 'C_', 'SAP_', 'L_', 'F_', 'arm_', 'BEV_', 'FCI_', 'task_', 'beh_',...
            'theta_', 'rho_', 'rsquare_', 'pca_', 'S_', 'bout_', 'split_', 'mean', 'var', 'Rev1c', 'Rev1b', 'Rev1', 'nPts_', 'median_', 'nNaNs_'};
    end
        
    methods (Static)
        function [ hex ] = rgb2hex(rgb)
            %% rgb2hex converts rgb color values to hex color format.
            %
            % This function assumes rgb values are in [r g b] format on the 0 to 1
            % scale.  If, however, any value r, g, or b exceed 1, the function assumes
            % [r g b] are scaled between 0 and 255.
            %
            % * * * * * * * * * * * * * * * * * * * *
            % SYNTAX:
            % hex = rgb2hex(rgb) returns the hexadecimal color value of the n x 3 rgb
            %                    values. rgb can be an array.
            %
            % * * * * * * * * * * * * * * * * * * * *
            % EXAMPLES:
            %
            % myhexvalue = rgb2hex([0 1 0])
            %    = #00FF00
            %
            % myhexvalue = rgb2hex([0 255 0])
            %    = #00FF00
            %
            % myrgbvalues = [.2 .3 .4;
            %                .5 .6 .7;
            %                .8 .6 .2;
            %                .2 .2 .9];
            % myhexvalues = rgb2hex(myrgbvalues)
            %    = #334D66
            %      #8099B3
            %      #CC9933
            %      #3333E6
            %
            % * * * * * * * * * * * * * * * * * * * *
            % Chad A. Greene, April 2014
            %
            % Updated August 2014: Functionality remains exactly the same, but it's a
            % little more efficient and more robust. Thanks to Stephen Cobeldick for
            % his suggestions.
            %
            % * * * * * * * * * * * * * * * * * * * *
            % See also hex2rgb, dec2hex, hex2num, and ColorSpec.
            %% Check inputs:
            assert(nargin==1,'This function requires an RGB input.')
            assert(isnumeric(rgb)==1,'Function input must be numeric.')
            sizergb = size(rgb);
            assert(sizergb(2)==3,'rgb value must have three components in the form [r g b].')
            assert(max(rgb(:))<=255& min(rgb(:))>=0,'rgb values must be on a scale of 0 to 1 or 0 to 255')
            %% If no value in RGB exceeds unity, scale from 0 to 255:
            if max(rgb(:))<=1
                rgb = round(rgb*255);
            else
                rgb = round(rgb);
            end
            %% Convert (Thanks to Stephen Cobeldick for this clever, efficient solution):
            hex(:,2:7) = reshape(sprintf('%02X',rgb.'),6,[]).';
            hex(:,1) = '#';
        end
      
    end
end

