classdef DataspaceLook_whiteTheme < handle
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

    
    
    
%     %White Scheme
    properties (Constant)

        controlDropdown_background = 0.98*[1,1,1];
        overlayLineStyle = '-';
        overlayLineWidth = 2;
        overlayLines = [1,1,1]*1;
        background = [1,1,1]; %0.98*[1,1,1]; %[1,1,1];
        defaultPlotBackground = [1,1,1];
        background2 = 0.9*[1,1,1];
        mainFigureBackground = 0.95*[1,1,1];
        background2_disabled = [0.8, 0.8, 0.94];
        background2Edge = [0.5, 0.5, 0.84];
        background2EdgeWidth = 1;

        propertyList_headings = [1,1,1] * 0.75;
        propertyList_headings2 = [0.8,1,0.8] * 0.8;

        mainText = [0,0,0];
        secondaryText = [1,1,1] * 0.4;
        brightBackground = [1,1,1];
        marker = [1,1,1]*0.4;
        headingText = [0.5, 0.5, 0.8];
        errorText = [1.0 0.5 0.5];
        errorText2 = [0.8 0.2 0.2];
        backplot = ones(1, 3)*0.6;
        localGroupMarker = '+k';
        localGroupLineWidth = 2;
        highlightScatter_colors = {'k', 'k', 'k', 'k', 'k', 'k'};
        highlightScatter_markers = {'x', 's', '^', '+', '+', '+'};
        highlightScatter_size = [5, 5, 5, 5, 5, 5];
        highlightScatter_lineWidth = [1, 1, 1, 1, 1, 1];
        xfViewerText = [0.6, 0.6, 0.6];
        xfViewerLine = [1,1,1]*0.5;
        xfViewerLine_main = [1,0.3,0.3]*1;
        binningLines = [1,1,1] * 0.2;
        useMainMenu = true;

        windowHeaderBackground = [1,1,1];
        windowHeaderBorderWidth = 1;
        windowHeaderBorderHighlightColor = 0.7*[1,1,1]; %0.4*[1 1 1];
        windowHeaderBorderShadowColor = 0.7*[1,1,1]; %0.4*[1 1 1];
        titleText = [1,1,1] * 0.4; %[1,1,1] * 0.8;

        controlWindowDescriptionText = [1,1,1] * 0.4;
        controlWindowBtns = [1,1,1] * 0.7;

        
        boxTitles = 0.9*[1,1,1]; %[0.05 0.25 0.5];
        boxBorderWidth = 1;
        boxBorderHighlightColor = 0.7*[1,1,1]; %0.4*[1 1 1];
        boxBorderShadowColor = 0.7*[1,1,1]; %0.4*[1 1 1];

        
        
        % NODETYPE_VARIABLE = 1;
        % NODETYPE_LOCALGROUP = 2;
        % NODETYPE_COORDINATES = 3;
        % NODETYPE_POINTFILTER = 4;
        % NODETYPE_MODULEFCN = 5;
        custodyChain_MARKERCOLORS = 0.82 * [0.4 1   0.4
            0.8   0.8   0
            0.5 0.5 1
            0   0   0
            1   0   1
            0.8   0.3   0.8];

        codeText = [0 0.8 0];
        helpText = [1 1 1] * 0.2;
        linkText = [0.5 0.5 1];
        unicode_settings = dspace.modules.UiUtils.isWinOrMacAssign(char(hex2dec('2699')), 'P');
        unicode_execute = dspace.modules.UiUtils.isWinOrMacAssign(char(hex2dec('27a0')), '>>');
        unicode_windows = char(8473);
        unicode_checkbox = char(9673);

        toolbarHeight = 25;
        
        toolbar_gap = 5;
        initialSize = [0.71, 0.69];
        
        axisMargins_horzPixPerLetter = 10;
        axisMargins_lineWidth_yAxis = 20;
        axisMargins_bottom = 45;
        axisMargins_top = 20;
        axisMargins_right = 20;
       
        colorbarPosition_default = [0.75, 0.7, 0.1, 0.25];
       
        %% Font sizes
        % isWinOrMacAssign returns the first argument if the op. system is windows
        % and the 2nd if the op. system is mac.
        % boxTitle_fontsize = dspace.modules.UiUtils.isWinOrMacAssign(8, 9);
        boxTitle_fontsize = 8;
        custodyChainGraphFontsize = 8;
        normalFontsize = 10;
        symbolFontsize = 12;
        smallFontsize = 8;
        
    end
end
