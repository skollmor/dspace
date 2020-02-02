function [ modules, modules_initialPositions, modules_initialStates] = define_modules( )
    % This function defines the list of modules available in the dataspace
    % GUI. 
    %
    % <a href="matlab:edit dspace.app.define_modules">Edit dspace.app.define_modules</a>
    %
    % Edit with care. Dataspace might not start if this file is corrupt.
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

    
    % Cell array, N_M x 1
    modules = {...
        dspace.modules.ActionSelector('Actions')
        dspace.modules.PropertyList('Dataview')
        dspace.modules.PointFilterAndHighlightsManager_v2('Filter')
        dspace.modules.ScatterDisplay_v2('Scatter-A', dspace.Dataview.MAPPING_PRIMARY, dspace.Dataview.MAPPING_SECONDARY,...
        dspace.Dataview.MAPPING_TERTIARY, dspace.Dataview.SELECTION, 'Map-1', 'Map-2', 'Map-3', 'Selection')
        dspace.modules.ScatterDisplay_v2('Scatter-B', dspace.Dataview.CHART_PRIMARY, dspace.Dataview.CHART_SECONDARY,...
        dspace.Dataview.CHART_TERTIARY, dspace.Dataview.SELECTION, 'Chart-1', 'Chart-2', 'Chart-3', 'Selection')
        dspace.modules.ScatterDisplay_v2('Scatter-C', dspace.Dataview.MAPPING_TERTIARY, dspace.Dataview.CHART_TERTIARY,...
        dspace.Dataview.ORDERING, dspace.Dataview.SELECTION, 'Map-3', 'Chart-3', 'Order', 'Selection')
        dspace.modules.ScatterDisplay_v2('Scatter-D', dspace.Dataview.MAPPING_TERTIARY, dspace.Dataview.CHART_TERTIARY,...
        dspace.Dataview.ORDERING, dspace.Dataview.SELECTION, 'Map-3', 'Chart-3', 'Order', 'Selection')
        dspace.modules.XfViewer('Ft-A')
        dspace.modules.XfViewer('Ft-B')
        dspace.modules.XfViewer('Ft-C')
        dspace.modules.BinningTool_v2('Bin-A', dspace.Dataview.CHART_PRIMARY,...
            dspace.Dataview.CHART_TERTIARY, dspace.Dataview.CHART_SECONDARY,...
            dspace.Dataview.SELECTION, 'Chart-1', 'Chart-3', 'Chart-2', 'Selection')
        dspace.modules.BinningTool_v2('Bin-B', dspace.Dataview.CHART_PRIMARY,...
            dspace.Dataview.CHART_TERTIARY, dspace.Dataview.CHART_SECONDARY,...
            dspace.Dataview.SELECTION, 'Chart-1', 'Chart-3', 'Chart-2', 'Selection')  
        dspace.modules.BinningTool_v2('Bin-C', dspace.Dataview.CHART_PRIMARY,...
            dspace.Dataview.CHART_TERTIARY, dspace.Dataview.CHART_SECONDARY,... 
            dspace.Dataview.SELECTION, 'Chart-1', 'Chart-3', 'Chart-2', 'Selection')
        };
    % Cell array, 1 x N_M
    modules_initialPositions = {...
        [10    163   238   634],... %actions
        [10    163   238   634],... %dataview
        [923   165   356   500],... %filters
        [265   163   639   607],... %scatter
        [1358  165   494   472],...
        [924   112   356   213],...
        [924   112   356   213],...
        [920   553   356   218],... %crd
        [921   556   356   213],...
        [992   339   509   379],...
        [1289  370   615   402],... %bin
        [992   339   509   379],... 
        [992   339   509   379],... 
        [11    905   1409  211]};
    
    % logical array, 1 x N_M
    modules_initialStates = [false, false, false, false, false, false, false,...
        true, false, false, false, false, false, false];
    
end

