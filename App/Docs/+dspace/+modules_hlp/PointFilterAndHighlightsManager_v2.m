    % Filters can constrain what data is currently displayed and analyzed. They 
    % are specified as MATLAB expressions that evaluate to logical vectors.
    % They can access the label table of the datasource through a table 
    %
    % >> P. 
    %
    % The filter expression can also access variables a and b (those can be 
    % defined in the control section of the dataview plugin) that provide 
    % access to the slider values of the dataview window. 
    % For instance, if idx is a label in the datasource, then the following is
    % a valid filter expression:
    %
    % >> P.idx > a
    %
    % This filter limit the set of displayed points to those for which the value
    % of the label idx is larger than the global control parameter a. 
    %
    % DSPACE-HELP-IMAGE<PointFilterManager_img1_v2.png>
    %
    % Each slot of the Filter window can contain a condition that can be toggled 
    % active or inactive by clicking the checkbox. The MATLAB expression for the 
    % condition can be changed by clicking the text. Above, set in slightly smaller font
    % are user defined titles for the conditions which can also be edited by clicking on them. 
    % 
    % <H4>Entering new Filter Conditions</H4>
    % First, click on the condition text. Second, type the matlab expression.
    % Third, and importantly, <b>press the enter key</b>.
    %
    % If a condition contains an error it is displayed in red. The error has to 
    % be fixed or the whole filter will not update.
    %
    % The circular button on the top-right, opens a context menu with options to manage 
    % filters (e.g. store/load).
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
