    % The binning-tool serves to compute histograms (1D) and conditional 
    % expectations. The label on the x-axis is binned, various properties 
    % such as point count per bin (histogram), the mean of another label 
    % (regression 1Var->1Var), means of 2 other 
    % variables (regression 1Var->2Var), can be plotted per bin on the other axes.
    % 
    % The binning tool can group datapoints accoring to a grouping label and plot each group separately.
    %
    % Per default the selection label (chosen in the Dataview plugin) determines the coloring groups.
    %
    % DSPACE-HELP-IMAGE<BinningTool_img1_v2b.png>
    % 
    % The axes-labels can be right-clicked to change depcited labels and labels used for binning
    % as well as colormaps and the grouping variable.
    %
    % <h4>Supported Modes</h4>
    % Modes can be chosen via the visibility context menu (sun button in toolbar): 'Plot type' and 'Errorbar type'.
    % 
    % Binning resolution and the threshold for choosing whether to bin the data or consider its unique values
    % can be chosen in the settings dialog (first button in toolbar).
    %
    % <h4>Keyboard-Shortcuts</h4> 
    % +, -         : Increase, decrease point-size
    %
    % shift + L    : Lock limits
    %
    % g            : Draw local graph
    %
    %
    % Note: some parts of the binning tool are still experimental.
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

        

