    % The Scatter-Tool displays scatterplots with up to several million points. 
    % It is especially useful as an embedding (e.g. t-SNE or UMAP) viewer.
    %
    % The scatter module can plot 2 labels against each other and a third as the marker color. Additionally, 
    % it can display a cursor, the current local graph (e.g. neighborhood for k-NN graphs) of the currently selected point,
    % a sequence variable, highlights, and an overlay depicting feature vectors. 
    %
    % The screenshot below
    % shows the ScatterTool displaying a t-SNE embedding of the MNIST dataset
    % where the current (hihg-D) neighborhood is marked by black crosses and
    % an overlay of the features containing the digit images; the overlay shows the average of all digits 
    % falling into the bin below in 2D axis. Other overlay modes include density measures and regression overlays 
    % (see below). 
    %
    % DSPACE-HELP-IMAGE<ScatterTool_img1_v2b.png>
    %
    % <h4>Mouse and Keyboard Controls</h4>
    % The orange elipses in the screenshot above mark areas that can be right clicked to open a context
    % menu that allows to change which labels are displayed, and which colormaps are used.
    %
    % The scrollwheel allows zooming in and out. Right clicking and dragging 
    % pans the 2D plane.
    % Left clicking sets the cursor to the closest datapoint. 
    %
    % <h4>Toolbars</h4>
    % The toolbar buttons on the top left have the following functions:
    %
    % From left to right, the first three bring up (1) the settings window,
    % (2) a context menu to choose what is being displayed and (3) a point filter context menu.
    % The 4th and 5th button are for manual point selection. The 4th button enables polygon 
    % drawing mode and the 5th button creates a new label in the datasource indicating which 
    % points fall inside the polygons created.
    %
    % The toolbar on the top right is only visible when the cursor hovers over this area.
    % Functions of the six buttons are, from left to right: (1) hide axes to maximize visible area.
    % (2)-(5) Matlab zoom and pan and rotate functions. (6) scale axis to optimally fit plotted data.
    % Note that <b>if you use buttons (2)-(5) you have to deactive them again</b>.
    %
    % <h4>Some Keyboard-Shortcuts</h4> 
    % +, -         : Increase, decrease point-size
    %
    % 2, 3         : Switch between 2d or 3d display
    %
    % shift + L    : Lock limits
    %
    % shift + /, * : Increase, decrease overlay rows
    %
    % ctrl + /, *  : Increase, decrease overlay transparency
    %
    % o            : Draw overlay
    %
    % g            : Draw local graph
    % 
    % <h4>Overlay Modes</h4>
    % Overlay mode, overlay colormap and the features to be displayed can be chosen 
    % from the context menu (sun button in toolbar). Overlay resolution can be set using
    % keyboard shortcuts or the setting dialog (first button in toolbar).
    %
    % <b>Sequences (experimental):</b> 
    % If a sequence variable is selected in the Dataview, it will be displayed if the checkbox in the
    % visibility context menu (sun button) is checked.
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

