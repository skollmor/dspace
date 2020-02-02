    % The Dataview (also called PropertyList) provides several slots that can hold the names
    % of labels (of the datasource), graphs and the index of a currently selected 
    % data point. The dataview window shows the values of all slots. Right clicking 
    % on the blue text opens a context menu to change those values. The 2 sliders 
    % can dynamically control various program functions as specified by the user.
    % Property slots are shared among all plugins, these values can be changed 
    % using the indicated global key combinations.
    %
    % DSPACE-HELP-IMAGE<PropertyList_img1_v2.png>
    %
    % Click the circle symbol in the top right corner to add more property slots.
    %
    % <H4>Available Property Slots</H4>
    % Map-1 through Chart-3:  
    %
    % - can hold any label. 
    %
    % Order: 
    %
    % - can hold any label, its ordering (using the MATLAB function sort)
    % defines how to traverse through the dataset (i.e. how to change the 
    % focussed datapoint when up and down arrow are used)
    %
    % Selection:
    %
    % - can hold any label
    %
    % Sequence:
    %
    % - can hold any label, meant for sequence variables or variables that
    % should implicitly be transformed to sequences.
    %
    % Filters:
    %
    % - holds a point filter definition (see section (6)).
    %
    % Focused Item:
    %
    % - currently focused item, order of traversal (when using cursor keys) 
    % is determined by the Order variable.
    %
    % Graph:
    %
    % - holds a graph definition (see section (7)).
    %
    % Controls:
    %
    % - sliders to control various two globally shared parameters a and b
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

