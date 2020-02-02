classdef Dataview < matlab.mixin.Copyable   
    % A Dataview instance specifies what part of a data source is
    % visualized and how.
    %
    % When changed, a dataview elicits property change events via its change
    % listener (-->setChangeListener(obj, changeListenerFcn)).
    %
    % A Dataspace-GUI instance will install a changeListener that
    % distributes change events to all modules. In script processing 
    % typically no event handling is used.
    %
    % <H3>Event Types</H3>
    % 
    % There are three types of events
    %
    % 1) Slot-Events -- firePropertyChangeEvent(), firePropertyValueChangeEvent()
    %
    %   These events are created when the property loaded into a slot changes, for example:
    %
    %   FOCUSSED_ID - change of the focussed element (cursor)
    %
    %   POINT_FILTER - change in current Point-Filter
    %
    %   LOCAL_GROUP - change in current local group
    %
    %   MAPPING_PRIMARY, etc... - change in one of the other property slots
    %
    %   The dataspace changeListerner Dataspace.dataviewChangeListenerFcn
    %   will call the 
    %
    %   >> module.notifyOfChange(eventType, old, new, dataview) method
    %
    %   on all active modules
    %
    % 2) Non-slot Events
    %
    %   If a property not loaded into a slot changes or coordinates change or
    %   a local group changes, this event type is elicited.
    %
    %   NOT IMPLEMENTED YET - currently event type 3 is used for these cases
    %
    % 3) Structural Change Events
    %
    %   These are events that require a complete update, currently this is
    %   achieved by simply calling Dataspace.updateAll() as is done, e.g.,
    %   after the execution of module functions. It will call the
    %
    %   >> module.update(dataview) 
    %
    %   function on all active modules
    % 
    % <H3>Deprecated</H3> 
    %
    % Dataviews can be configured to a certain datasource so that almost
    % all getters work without arguments (-->setDatasource(obj, dataSource)).
    %
    % Deprecated: Dataviews create virtual properties: i.e.
    % currentLocalGroup;
    % Deprecated: displayId
    %
    % 
    %
    %<PRE>
    % This file is part of dspace-core.
    %
    % Copyright (C) 2020 University Zurich, Sepp Kollmorgen
    %
    % This program is free software: you can redistribute it and/or modify
    % it under the terms of the GNU Affero General Public License as published by
    % the Free Software Foundation, either version 3 of the License, or
    % (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU Affero General Public License for more details.
    %
    % You should have received a copy of the GNU Affero General Public License
    % along with this program (see LICENSE file).  If not, see <https://www.gnu.org/licenses/>.
    % </PRE>
    % <b>Dataspace on Github</b>: <a href="matlab:web('https://github.com/skollmor/dspace', '-browser')">https://github.com/skollmor/dspace</a>

    
    % Hidden Constants
    properties (Hidden=true, Access=public, Constant)
        
        % For changes in properties that are not assigned to slots of this
        % dataview
        EVENTTYPE_DATASOURCE_PROPERTY_CHANGE = 'dataSourceProperty';
        
        % Typically changing the datasource will imply changes in all
        % datasource properties. Instead only this event is fired.
        EVENTTYPE_DATASOURCE_OR_DATAVIEW_CHANGE = 'datasource';
        
        % The following identifiers are also used as EVENTTYPES
        MAPPING_PRIMARY = 'primaryMappingProperty';
        MAPPING_SECONDARY = 'secondaryMappingProperty';
        MAPPING_TERTIARY = 'tertiaryMappingProperty';
        CHART_PRIMARY = 'primaryChartProperty';
        CHART_SECONDARY = 'secondaryChartProperty';
        CHART_TERTIARY = 'tertiaryChartProperty';
        ORDERING = 'orderingProperty';
        SELECTION = 'selectionProperty';
        
        % The sequence variable is either an explicit indexing
        % variable (e.g. always giving the next neighbour, unit=dspace_data.PropertyDefinition.UNIT_SEQUENCE_INDEX)
        % or not (in which case the (1)-sequence operator is returned). Hence rt is always a variable of indices.
        % PropertyList prints implicit sequence variables in italic
        SEQUENCE = 'sequenceProperty';
        FOCUSSED_ID = 'focussedId';
        % name of the local group definition per display
        LOCAL_GROUP_NAME = 'localGroupName';
        % dependent property (determined by focussed_id and local_group_id)
        LOCAL_GROUP = 'localGroup';
        % filters points to be displayed - matlab command as string.
        % has access to P (property struct, e.g. XProps) and control parameters (a, b)
        % returns a logical vector
        POINT_FILTER = 'pointFilter';
        
        % highlights are multilevel point filters meant for marking groups
        % of points in plots independent of coloring and point filter (e.g.
        % events in time series, single trials, etc.)
        POINT_HIGHLIGHTS = 'pointHighlights';
        
        % Use this event when the point filter list (stored in the
        % dataspace registry) changes
        POINT_FILTER_LIST = 'pointFilterList';
        
        % Use this event when the point highlights list (stored in the
        % dataspace registry) changes
        POINT_HIGHLIGHTS_LIST = 'pointHighlightsList';
        
        % Control parameters are (per display) scalars that can be accessed by point
        % filters.
        CONTROL_PRIMARY = 'controlParameterA';
        CONTROL_SECONDARY = 'controlParameterB';
        % Each control parameter has a minimum, maximum and stepsize associated (triplet)
        CONTROL_RANGE_PRIMARY = 'controlRangeA';
        CONTROL_RANGE_SECONDARY = 'controlRangeB';
        
        % All Slots holding vector properties
        ALL_XPROPERTY_SLOTS = {dspace.Dataview.MAPPING_PRIMARY, dspace.Dataview.MAPPING_SECONDARY,...
            dspace.Dataview.MAPPING_TERTIARY, dspace.Dataview.CHART_PRIMARY, dspace.Dataview.CHART_SECONDARY,...
            dspace.Dataview.CHART_TERTIARY, dspace.Dataview.ORDERING, dspace.Dataview.SELECTION, dspace.Dataview.SEQUENCE};
        ALL_XPROPERTY_SLOTS_SHORTNAMES = {'Map-1', 'Map-2', 'Map-3', 'Chart-1', 'Chart-2',...
            'Chart-3', 'Order', 'Selection', 'Sequence'};
        % Virtual properties
        VIRTUAL_XPROPERTY_CURRENT_LOCAL_GROUP = 'currentLocalGroup';
        VIRTUAL_XPROPERTY_NAMES = {dspace.Dataview.VIRTUAL_XPROPERTY_CURRENT_LOCAL_GROUP};
    end

    % Monitoring
    properties (Access=public, Transient=true)
        backingDatasource
        monitoringEnabled = false;
        monitorObj = [];
        proxySource = [];
    end
       
    properties (Hidden=true, Dependent)
         dataSource
    end
    
    properties (Hidden=true, Transient=true)
        oldLocalGroupPropertyValues = [];
        oldLocalGroupIds = [];
         
        changeListenerFcn
        
        % id of local group (use localGroupName for changes)
        localGroupId
    end
    
    % These properties work only if the dataview is fully configured
    % For interaction with Dataview objects on the command line
    properties (GetAccess=public, Dependent)
        %nPoints
        Map1name
        Map2name
        Map3name
        Chart1name
        Chart2name
        Chart3name
        OrderName
        SelectionName
        SequenceName
        FilterName
        HighlightsName
        ControlA
        ControlB
        LocalGroupName
        FocussedId
    end
    
    properties (GetAccess=public, Dependent, Hidden=false)
        %nPoints
        Map1
        Map2
        Map3
        Chart1
        Chart2
        Chart3
        Order
        Selection
        Sequence
        Filter
        Highlights
        ControlRangeA
        ControlRangeB
        LocalGroupDefinition
        LocalGroup
        DatasetName
        DatasetUID
    end
    
    properties (Hidden=true, SetAccess=public, GetAccess=public)
        
        name = 'Default View';
         
        % property names for each display (cell arrays)
        primaryMappingProperty = '';
        secondaryMappingProperty = '';
        tertiaryMappingProperty = '';
        
        primaryChartProperty = '';
        secondaryChartProperty = '';
        tertiaryChartProperty = '';
        
        orderingProperty = '';
        selectionProperty = '';
        
        sequenceProperty = '';
        
        % id of focussed point in current ordering
        focussedId = 1;
        
        % name of local group
        localGroupName = '';
        
        % filters points to be displayed - PointFilterContainer instances;
        % contains matlab command as string that has access to P and returns a logical vector
        pointFilter = dspace_data.PointFilterContainer.getEmptyFilter();
        
        % highlights points to be displayed - PointHighlightsContainer instances;
        % contains multiple matlab commands as strings that have access to
        % P and returns logical vectors
        pointHighlights = [];
        
        controlA = 1;
        controlB = 1;
        controlRangeA = [1, 100, 1];
        controlRangeB = [1, 100, 1];
        
        isOverriding = false;
        
    end
    
    methods % Dependent Properties
        function rt = get.Map1(obj)
            rt = obj.getPrimaryMapping();
        end
        
        function rt = get.Map2(obj)
            rt = obj.getSecondaryMapping();
        end
        
        function rt = get.Map3(obj)
            rt = obj.getTertiaryMapping();
        end
        
        function rt = get.Chart1(obj)
            rt = obj.getPrimaryChart();
        end
        
        function rt = get.Chart2(obj)
            rt = obj.getSecondaryChart();
        end
        
        function rt = get.Chart3(obj)
            rt = obj.getTertiaryChart();
        end
        
        function rt = get.Order(obj)
            rt = obj.getOrdering();
        end
        
        function rt = get.Selection(obj)
            rt = obj.getSelection();
        end
        
        function rt = get.Sequence(obj)
            rt = obj.getSequence();
        end
        
        function rt = get.Filter(obj)
            rt = obj.getPointFilter();
        end
        
        function rt = get.Highlights(obj)
            rt = obj.getPointHighlights();
        end
        
        function rt = get.Map1name(obj)
            rt = obj.primaryMappingProperty;
        end
        
        function rt = get.Map2name(obj)
            rt = obj.secondaryMappingProperty;
        end
        
        function rt = get.Map3name(obj)
            rt = obj.tertiaryMappingProperty;
        end
        
        function rt = get.Chart1name(obj)
            rt = obj.primaryChartProperty;
        end
        
        function rt = get.Chart2name(obj)
            rt = obj.secondaryChartProperty;
        end
        
        function rt = get.Chart3name(obj)
            rt = obj.tertiaryChartProperty;
        end
        
        function rt = get.OrderName(obj)
            rt = obj.orderingProperty;
        end
        
        function rt = get.SelectionName(obj)
            rt = obj.selectionProperty;
        end
        
        function rt = get.SequenceName(obj)
            rt = obj.sequenceProperty;
        end
        
        function rt = get.FilterName(obj)
            rt = obj.pointFilter;
        end
        
        function rt = get.HighlightsName(obj)
            rt = obj.pointHighlights;
        end
        
        function rt = get.ControlA(obj)
            rt = obj.controlA;
        end
        
        function rt = get.ControlB(obj)
            rt = obj.controlB;
        end
        
        function rt = get.ControlRangeA(obj)
            rt = obj.controlRangeA;
        end
        
        function rt = get.ControlRangeB(obj)
            rt = obj.controlRangeB;
        end
        
        function rt = get.FocussedId(obj)
            rt = obj.getFocussedId();
            assert(numel(rt) == 1);
        end
        
        function rt = get.LocalGroup(obj)
            rt = obj.getLocalGroup();
        end
        
        function rt = get.LocalGroupName(obj)
            rt = obj.getLocalGroupName();
        end
        
        function rt = get.LocalGroupDefinition(obj)
            rt = obj.getLocalGroupDefinition();
        end
        
        function rt = get.DatasetName(obj)
            rt = obj.dataSource.getName();
        end
        
        function rt = get.DatasetUID(obj)
            rt = obj.dataSource.getUniqueIdentifier();
        end
    end
   
    % Dependent property dataSource - to allow for change monitoring
    methods
        function rt = get.dataSource(obj)
            if obj.monitoringEnabled
                rt = obj.proxySource;
            else
                rt = obj.backingDatasource;
            end
        end
        
        function set.dataSource(obj, value)
            if obj.monitoringEnabled
                fprintf(['Dataview: Monitoring was enabled but dataSource was '...
                    'reset. This may indicate a problem\n']);
                obj.monitoringEnabled = false;
                obj.monitorObj = [];
                obj.proxySource = [];
                obj.backingDatasource = value;
            else
                obj.backingDatasource = value;
            end
        end
    end
    
    % Monitoring & Custody Chain
    methods
        
        function enableMonitoring(obj, monitorObj)
            obj.monitoringEnabled = true;
            obj.monitorObj = monitorObj;
%             obj.proxySource = dspace_data.TableDatasourceProxy(...
%                         obj.backingDatasource, obj.monitorObj);
        end
        
        function disableMonitoring(obj, monitorObj)
            assert(obj.monitoringEnabled);
            assert(obj.monitorObj == monitorObj);
            obj.monitoringEnabled = false;
        end
        
%         function chains = getCustodyChains(obj, monitorObj)
%             assert(obj.monitorObj == monitorObj);
%             assert(~isempty(obj.proxySource));
%             chain = dspace_data.DataCustodyChain(obj.proxySource);
%             chains = chain.splitChain(); 
%             % first chain is always the one for the datasource
%             chains{1}.addMonitoredObjInformation(obj.dataSource);
%         end
        
    end
    
    % Hide handle/copyable class methods
    methods (Hidden=true)
        function lh = addlistener(varargin)
            lh = addlistener@matlab.mixin.Copyable(varargin{:});
        end
        function notify(varargin)
            notify@matlab.mixin.Copyable(varargin{:});
        end
        function Hmatch = findobj(varargin)
            Hmatch = findobj@matlab.mixin.Copyable(varargin{:});
        end
        function p = findprop(varargin)
            p = findprop@matlab.mixin.Copyable(varargin{:});
        end
        function TF = eq(varargin)
            TF = eq@matlab.mixin.Copyable(varargin{:});
        end
        function TF = ne(varargin)
            TF = ne@matlab.mixin.Copyable(varargin{:});
        end
        function TF = lt(varargin)
            TF = lt@matlab.mixin.Copyable(varargin{:});
        end
        function TF = le(varargin)
            TF = le@matlab.mixin.Copyable(varargin{:});
        end
        function TF = gt(varargin)
            TF = gt@matlab.mixin.Copyable(varargin{:});
        end
        function TF = ge(varargin)
            TF = ge@matlab.mixin.Copyable(varargin{:});
        end
    end
    
    methods (Hidden=true)
        function delete(obj)
            obj.dataSource = [];
        end
    end
    
    methods (Access=public, Hidden=false)
        
        function source = getDatasource(obj)
            source = obj.dataSource;
        end
        
    end
    
    % Constructor
    methods (Access=public, Hidden=true)
        
        function obj = Dataview(primaryMappingProperty, secondaryMappingProperty, tertiaryMappingProperty,...
                primaryChartProperty, secondaryChartProperty, tertiaryChartProperty, orderingProperty,...
                selectionProperty, sequenceProperty)
            
            obj.primaryMappingProperty = primaryMappingProperty;
            obj.secondaryMappingProperty = secondaryMappingProperty;
            obj.tertiaryMappingProperty = tertiaryMappingProperty;
            obj.primaryChartProperty = primaryChartProperty;
            obj.secondaryChartProperty = secondaryChartProperty;
            obj.tertiaryChartProperty = tertiaryChartProperty;
            obj.orderingProperty = orderingProperty;
            obj.selectionProperty = selectionProperty;
            obj.sequenceProperty = sequenceProperty;
            obj.focussedId = 1;
            obj.localGroupName = '';
            obj.localGroupId = [];
            obj.pointFilter = dspace_data.PointFilterContainer.getEmptyFilter;
            obj.pointHighlights = dspace_data.PointHighlightsContainer.getEmptyHighlights();
            obj.controlA = 1; 
            obj.controlB = 1; 
            obj.controlRangeA = [1, 100, 1];
            obj.controlRangeB = [1, 100, 1];
            
        end
    end
    
    % Events
    methods (Access=public, Hidden=true)
        
        % Fires an appropriate property change event if the propertyName
        % occurs in any Property-Slot of this dataview. This is for the
        % (rare) case of properties changing their actual values.
        % Slots with the respective property are searched and update events
        % for them are created. If plugins access non-slot properties, this
        % will fail.
        function firePropertyValueChangeEvent(obj, propertyName)
            for i = 1:numel(dspace.Dataview.ALL_XPROPERTY_SLOTS)
                pname = obj.getPropertyInSlot(dspace.Dataview.ALL_XPROPERTY_SLOTS{i});
                if strcmp(pname, propertyName)
                    firePropertyChangeEvent(obj, dspace.Dataview.ALL_XPROPERTY_SLOTS{i}, pname, pname)
                end
            end
        end
        
        % this is for changes in slots
        function firePropertyChangeEvent(obj, eventType, old, new)
            if ~isempty(obj.changeListenerFcn)
                obj.changeListenerFcn(obj, eventType, old, new);
            end
        end
        
        function setDatasource(obj, dataSource)
            obj.dataSource = dataSource;
            
            if obj.focussedId > dataSource.N
                obj.focussedId = dataSource.N;
            end
%             if ~ismember(obj.localGroupName, dataSource.getLocalGroupNames())
%                 obj.localGroupName = '';
%                 obj.localGroupId = [];
%             end
            obj.updateLocalGroupId();
            
        end
          
        % changeListener must be a function:
        % changeListenerFcn(dataview, eventType, old, new)
        function setChangeListener(obj, changeListenerFcn)
            obj.changeListenerFcn = changeListenerFcn;
        end
        
        function rt = getName(obj)
            rt = obj.name;
        end
        
    end
    
    % Note: Property name setters elicit propertyChangeEvents
    methods (Access=public, Hidden=true) 
        
        function setPrimaryMappingProperty(obj, propertyName)
            oldName = obj.primaryMappingProperty;
            obj.primaryMappingProperty = propertyName;
            obj.firePropertyChangeEvent(dspace.Dataview.MAPPING_PRIMARY, oldName, propertyName);
        end
        
        function setSecondaryMappingProperty(obj, propertyName)
            oldName = obj.secondaryMappingProperty;
            obj.secondaryMappingProperty = propertyName;
            obj.firePropertyChangeEvent(dspace.Dataview.MAPPING_SECONDARY, oldName, propertyName);
        end
        
        function setTertiaryMappingProperty(obj, propertyName)
            oldName = obj.tertiaryMappingProperty;
            obj.tertiaryMappingProperty = propertyName;
            obj.firePropertyChangeEvent(dspace.Dataview.MAPPING_TERTIARY, oldName, propertyName);
        end
        
        function setPrimaryChartProperty(obj, propertyName)
            oldName = obj.primaryChartProperty;
            obj.primaryChartProperty = propertyName;
            obj.firePropertyChangeEvent(dspace.Dataview.CHART_PRIMARY, oldName, propertyName);
        end
        
        function setSecondaryChartProperty(obj, propertyName)
            oldName = obj.secondaryChartProperty;
            obj.secondaryChartProperty = propertyName;
            obj.firePropertyChangeEvent(dspace.Dataview.CHART_SECONDARY, oldName, propertyName);
        end
        
        function setTertiaryChartProperty(obj, propertyName)
            oldName = obj.tertiaryChartProperty;
            obj.tertiaryChartProperty = propertyName;
            obj.firePropertyChangeEvent(dspace.Dataview.CHART_TERTIARY, oldName, propertyName);
        end
        
        function setOrderingProperty(obj, propertyName)
            oldName = obj.orderingProperty;
            obj.orderingProperty = propertyName;
            obj.firePropertyChangeEvent(dspace.Dataview.ORDERING, oldName, propertyName);
        end
        
        function setSelectionProperty(obj, propertyName)
            oldName = obj.selectionProperty;
            obj.selectionProperty = propertyName;
            obj.firePropertyChangeEvent(dspace.Dataview.SELECTION, oldName, propertyName);
        end
        
        function setSequenceProperty(obj, propertyName)
            oldName = obj.sequenceProperty;
            obj.sequenceProperty = propertyName;
            obj.firePropertyChangeEvent(dspace.Dataview.SEQUENCE, oldName, propertyName);
        end
        
        function setFocussedId(obj, id)
            oldId = obj.focussedId;
            obj.focussedId = id;
            obj.firePropertyChangeEvent(dspace.Dataview.FOCUSSED_ID, oldId, id);
            %local Group change is mostly
            %obj.firePropertyChangeEvent(dspace.Dataview.LOCAL_GROUP, oldId, id);
            obj.firePropertyValueChangeEvent(obj.VIRTUAL_XPROPERTY_CURRENT_LOCAL_GROUP);
        end
        
        function setLocalGroupName(obj, name)
            oldName = obj.localGroupName;
            obj.localGroupName = name;
            obj.updateLocalGroupId();
            obj.firePropertyChangeEvent(dspace.Dataview.LOCAL_GROUP_NAME, oldName, name);
            obj.firePropertyChangeEvent(dspace.Dataview.LOCAL_GROUP, oldName, name);
            obj.firePropertyValueChangeEvent(obj.VIRTUAL_XPROPERTY_CURRENT_LOCAL_GROUP);
        end
        
        function updateLocalGroupId(obj)
            source = obj.dataSource;
            if ~isempty(source)
                [~, obj.localGroupId] = source.getLocalGroupDefByName(obj.localGroupName);
            else
                obj.localGroupId = 0;
            end
        end
        
        function setPointFilter(obj, pointFilterContainer)
            oldFilterContainer = obj.pointFilter;
            obj.pointFilter = pointFilterContainer;
            if ~obj.isAttachedToGUI() && ~isempty(obj.dataSource)
                [~, isCorrect] = pointFilterContainer.apply(obj.dataSource, obj);
                if ~isCorrect
                    error('dspace.Dataview.setPointFilter:: The point filter is erroneous.');
                end
            end
            obj.firePropertyChangeEvent(dspace.Dataview.POINT_FILTER, oldFilterContainer, pointFilterContainer);
        end
        
        function setPointHighlights(obj, highlightsContainer)
            oldHighlights = obj.pointHighlights;
            obj.pointHighlights = highlightsContainer;
            obj.firePropertyChangeEvent(dspace.Dataview.POINT_HIGHLIGHTS, oldHighlights, highlightsContainer);
        end
        
        function setControlA(obj, controlParameter)
            oldControlA = obj.controlA;
            obj.controlA = controlParameter;
            % fire control change event
            obj.firePropertyChangeEvent(dspace.Dataview.CONTROL_PRIMARY, oldControlA, controlParameter);
            % fire also a point filter event
            %% TODO only send event when filter depends on control values
            obj.firePropertyChangeEvent(dspace.Dataview.POINT_FILTER, oldControlA, controlParameter);
            % fire also a point highlights event
            obj.firePropertyChangeEvent(dspace.Dataview.POINT_HIGHLIGHTS, oldControlA, controlParameter);
        end
        
        function setControlB(obj, controlParameter)
            oldControlB = obj.controlB;
            obj.controlB = controlParameter;
            % fire control change event
            obj.firePropertyChangeEvent(dspace.Dataview.CONTROL_SECONDARY, oldControlB, controlParameter);
            % fire also a point filter event
            obj.firePropertyChangeEvent(dspace.Dataview.POINT_FILTER, oldControlB, controlParameter);
        end
        
        function setControlRangeA(obj, controlRange)
            oldControlRangeA = obj.controlRangeA;
            obj.controlRangeA = controlRange;
            obj.firePropertyChangeEvent(dspace.Dataview.CONTROL_RANGE_PRIMARY, oldControlRangeA, controlRange);
        end
        
        function setControlRangeB(obj, controlRange)
            oldControlRangeB = obj.controlRangeB;
            obj.controlRangeB = controlRange;
            obj.firePropertyChangeEvent(dspace.Dataview.CONTROL_RANGE_SECONDARY, oldControlRangeB, controlRange);
        end
        
    end
    
    % Non-standard getters for properties and property values
    methods (Access=public, Hidden=true) 
        
        function isAttached = isAttachedToGUI(obj)
            isAttached = ~isempty(obj.changeListenerFcn);
        end
        
        function propDefinition = getPropertyDefinition(obj, propertyName)
            if nargin < 3
                dataSource = obj.dataSource;
            end
            
            propDefinition = dataSource.getPropertyDefinition(propertyName);
        end
        
        function pn = getNonVirtualPropertyNames(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            pn = dataSource.getPropertyNames();
        end
        
        function pn = getVirtualPropertyNames(obj)
            pn = obj.VIRTUAL_XPROPERTY_NAMES;
        end
        
        function pn = getPropertyNames(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            pn = [dataSource.getPropertyNames() obj.VIRTUAL_XPROPERTY_NAMES];
        end
        
        function v = getPropertyValues(obj, propertyName)
            if nargin < 3
                dataSource = obj.dataSource;
            end
            
            if ~isempty(propertyName) && ismember(propertyName, obj.VIRTUAL_XPROPERTY_NAMES)
                v = obj.getVirtualPropertyValues(propertyName);
            else
                v = dataSource.getPropertyValues(propertyName);
            end
        end
        
        function v = getVirtualPropertyValues(obj, propertyName)
            if nargin < 3
                dataSource = obj.dataSource;
            end
            
            switch propertyName
                case obj.VIRTUAL_XPROPERTY_CURRENT_LOCAL_GROUP
                    if ~isempty(obj.oldLocalGroupPropertyValues) &&...
                            numel(obj.oldLocalGroupPropertyValues) == dataSource.getNumberOfPoints()
                        obj.oldLocalGroupPropertyValues(obj.oldLocalGroupIds) = NaN;
                    else
                        obj.oldLocalGroupPropertyValues = NaN(dataSource.getNumberOfPoints(), 1, 'single');
                    end
                    [obj.oldLocalGroupIds, distances] = obj.getLocalGroup();
                    if isempty(distances)
                        obj.oldLocalGroupPropertyValues(obj.oldLocalGroupIds) = 1:numel(obj.oldLocalGroupIds);
                    else
                        obj.oldLocalGroupPropertyValues(obj.oldLocalGroupIds) = distances;
                    end
                otherwise
                    assert(false);
            end
            v = obj.oldLocalGroupPropertyValues;
        end
        
        % Returns the name of the property in the specified slot
        function name = getPropertyInSlot(obj, slotName)
            switch slotName
                case dspace.Dataview.MAPPING_PRIMARY
                    name = obj.primaryMappingProperty;
                case dspace.Dataview.MAPPING_SECONDARY
                    name = obj.secondaryMappingProperty;
                case dspace.Dataview.MAPPING_TERTIARY
                    name = obj.tertiaryMappingProperty;
                case dspace.Dataview.CHART_PRIMARY
                    name = obj.primaryMappingProperty;
                case dspace.Dataview.CHART_SECONDARY
                    name = obj.secondaryMappingProperty;
                case dspace.Dataview.CHART_TERTIARY
                    name = obj.tertiaryMappingProperty;
                case dspace.Dataview.ORDERING
                    name = obj.orderingProperty;
                case dspace.Dataview.SELECTION
                    name = obj.selectionProperty;
                case dspace.Dataview.SEQUENCE
                    name = obj.sequenceProperty;
                otherwise
                    assert(false);
            end
        end
        
        % returns values for the property currently residing in the specified slot
        function [rt, name] = getSlotValues(obj, slotName)
            
            if nargin < 3
                dataSource = obj.dataSource;
            end
            
            switch slotName
                case dspace.Dataview.MAPPING_PRIMARY
                    [rt, name] = obj.getPrimaryMapping();
                case dspace.Dataview.MAPPING_SECONDARY
                    [rt, name] = obj.getSecondaryMapping();
                case dspace.Dataview.MAPPING_TERTIARY
                    [rt, name] = obj.getTertiaryMapping();
                case dspace.Dataview.CHART_PRIMARY
                    [rt, name] = obj.getPrimaryChart();
                case dspace.Dataview.CHART_SECONDARY
                    [rt, name] = obj.getSecondaryChart();
                case dspace.Dataview.CHART_TERTIARY
                    [rt, name] = obj.getTertiaryChart();
                case dspace.Dataview.ORDERING
                    [rt, name] = obj.getOrdering();
                case dspace.Dataview.SELECTION
                    [rt, name] = obj.getSelection();
                case dspace.Dataview.SEQUENCE
                    [rt, name] = obj.getSequence();
                case dspace.Dataview.POINT_FILTER
                    [rt, name] = obj.getPointFilter();
                otherwise
                    assert(false);
            end
        end
        
        function putProperty(obj, propertyName, values, propertyDefinition)
            dataSource = obj.dataSource;
            
            dataSource.Xprops.(propertyName) = values;
            if nargin == 4
                dataSource.XpropDefinitions.(propertyName) = propertyDefinition;
            end
            
            firePropertyValueChangeEvent(obj, propertyName)
        end
        
        % property names are indexed in alphabetical order
        function id = getPropertyId(obj, propertyName)
            
            if nargin < 3
                dataSource = obj.dataSource;
            end
            
            id = find(strcmp(propertyName, obj.getPropertyNames()));
        end
        
        function c = getPropertyCount(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            c = numel(obj.getPropertyNames());
        end
        
        % rts rows are the fixed length representations corresponding to
        % ids
        function rt = getDataMatrix(obj, ids, coordinateId)
            
            dataSource = obj.dataSource;
            
            rt = dataSource.getDataMatrix(ids, coordinateId);
        end
        
        % rts rows are the fixed length representations corresponding to
        % ids
        function rt = getDataMatrixCutout(obj, ids, cutoutIds, coordinateId)
            
            dataSource = obj.dataSource;
            
            rt = dataSource.getDataMatrixCutout(ids, cutoutIds, coordinateId);
        end
         
        function [rt, name] = getPrimaryMapping(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            name = obj.primaryMappingProperty;
            rt = obj.getPropertyValues(name);
            %rt = dataSource.getPropertyValues(name);
        end
        
        function [rt, name] = getSecondaryMapping(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            name = obj.secondaryMappingProperty;
            rt = obj.getPropertyValues(name);
            
        end
        
        function [rt, name] = getTertiaryMapping(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            name = obj.tertiaryMappingProperty;
            rt = obj.getPropertyValues(name);
            
        end
        
        function [rt, propertyName_col1, propertyName_col2] = getMapped(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            propertyName_col1 = obj.primaryMappingProperty;
            propertyName_col2 = obj.secondaryMappingProperty;
            if isempty(propertyName_col1) || isempty(propertyName_col2)
                rt = [];
            else
                rt = [obj.getPropertyValues(propertyName_col1) obj.getPropertyValues(...
                    propertyName_col2)];
            end
        end
        
        function [rt, propertyName] = getPrimaryChart(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = obj.getPropertyValues(obj.primaryChartProperty);
            propertyName = obj.primaryChartProperty;
        end
        
        function [rt, propertyName] = getSecondaryChart(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = obj.getPropertyValues(obj.secondaryChartProperty);
            propertyName = obj.secondaryChartProperty;
        end
        
        function [rt, propertyName] = getTertiaryChart(obj)
            
           if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = obj.getPropertyValues(obj.tertiaryChartProperty);
            propertyName = obj.tertiaryChartProperty;
        end
        
        function [rt, name] = getOrdering(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = obj.getPropertyValues(obj.orderingProperty);
            name = obj.orderingProperty;
        end
        
        function [rt, name] = getSelection(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            rt = obj.getPropertyValues(obj.selectionProperty);
            name = obj.selectionProperty;
        end
        
        function rt = getFocussedId(obj)
%             if nargin < 2
%                 dataSource = obj.dataSource;
%             end
            
            rt = obj.focussedId;
        end
        
        function rt = getLocalGroupName(obj)
%            if nargin < 2
%                 dataSource = obj.dataSource;
%             end
            
            rt = obj.localGroupName;
        end
        
        function rt = getLocalGroupDefinition(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            if ~isempty(obj.localGroupId)
                rt = dataSource.LG{obj.localGroupId};
            else
                rt = dspace_graphs.TrivialGraph();
            end
        end
        
        function rt = getLocalGroupDefinitions(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = dataSource.getLocalGroupDefinitions();
        end
        
        % group size k is optional. overrides k from group definition.
        function [ids, distances] = getLocalGroup(obj, k)
            dataSource = obj.dataSource;
            
            groupId = obj.localGroupId;
            pointId = obj.focussedId;
            
            if isempty(groupId) || isempty(pointId)
                ids = [];
                distances = [];
                return;
            end
            
            if nargin < 2
                [ids, distances] = dataSource.getLocalGroup(groupId, pointId);
            else
                [ids, distances] = dataSource.getLocalGroup(groupId, pointId, k);
            end
        end
        
        
        function rt = getControlA(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = obj.controlA;
        end
        
        function rt = getControlB(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = obj.controlB;
        end
        
        function rt = getControlRangeA(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = obj.controlRangeA;
        end
        
        function rt = getControlRangeB(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = obj.controlRangeB;
        end
        
        function P = getAllProperties(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            P = dataSource.P;
%             vp = obj.getVirtualPropertyNames();
%             for k = 1:numel(vp)
%                 P.(vp{k}) = obj.getVirtualPropertyValues(vp{k});
%             end
        end
        
        % Does not evaluate the sequence. The sequence variable is either an explicit indexing
        % variable (e.g. always giving the next neighbour, unit=dspace_data.PropertyDefinition.UNIT_SEQUENCE_INDEX)
        % or not (in which case the (1)-sequence operator is returned). Hence rt is always a variable of indices.
        function [rt, name] = getSequence(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            pd = obj.getPropertyDefinition(obj.sequenceProperty);
            if strcmp(pd.unit, dspace_data.PropertyDefinition.UNIT_SEQUENCE_INDEX)
                rt = obj.getPropertyValues(obj.sequenceProperty);
                name = obj.sequenceProperty;
            else
                [rt, name] = obj.getSequenceOperator(1);
            end
        end
        
        % The sequence operator gives the index of the datapoint (w.r.t.
        % source) that is k steps (k < 0 or k > 0 or k = 0 (identity)) from
        % the current point.
        function [rt, name] = getSequenceOperator(obj, k)
            
            if nargin < 3
                dataSource = obj.dataSource;
            end
            sequence = obj.getPropertyValues(obj.sequenceProperty);
            if isempty(sequence)
                rt = [];
                name = '';
                return
            end
            name = obj.sequenceProperty;
            [~, order] = sort(sequence);
            
            if k == 0
                rt = 1:numel(order);
            elseif k < 0
                rt = [NaN(-k, 1); order(1:end-k, 1)];
            elseif k > 0
                rt = [order(k+1:end, 1); NaN(k, 1)];
            end
        end
        
        function pfContainer = getPointFilterContainer(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            pfContainer = obj.pointFilter;
        end
        
        % Evaluates the point filter
        function [pfEvaluated, pfName, pfContainer] = getPointFilter(obj)
            %% SPEED: application of pf not necessary if only the container is required
            %% SPEED: Every update cycle could have a unique identifier so that pf and other results
            % can be reused throughout one update cycle
            % The dataview should take care of cycle management
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            pfContainer = obj.pointFilter;
            
            pfName = pfContainer.getLongDescriptor();
            [pfEvaluated, isCorrect] = pfContainer.apply(dataSource, obj);
            if ~isCorrect
                if ~obj.isAttachedToGUI()
                    warning('dspace.Dataview.getPointFilter:: Point filter contains an error. Dataview is not attached to a GUI.');
                else
                    fprintf('dspace.Dataview.getPointFilter:: Point filter contains an error.\n');
                end
            end 
        end
        
        % Evaluates the highlights
        % hlEvaluated is a kx1 cell array where each element is an array
        % of ids (w.r.t. dataSource)
        function [hlEvaluated, hlName, hlContainer] = getPointHighlights(obj)
            
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            hlContainer = obj.pointHighlights;
            
            if isempty(hlContainer) || isempty(hlContainer.highlights) ||...
                    all(cellfun(@isempty, hlContainer.highlights))
                hlEvaluated = {};
                hlName = '';
                return;
            end
            
            hlName = hlContainer.getLongDescriptor;
            
            P = obj.getAllProperties(); % Variables for eval
            a = obj.controlA;
            b = obj.controlB;
            lgIds = obj.getLocalGroup();
            cId = obj.focussedId;
            
            hlEvaluated = cell(numel(hlContainer.highlights), 1);
            for k = 1:numel(hlContainer.highlights)
                if isempty(hlContainer.highlightFcns{k})
                    hlEvaluated{k} = [];
                    continue;
                end
                
                rt = hlContainer.highlightFcns{k}(P, a, b, lgIds, cId);
                if islogical(rt)
                    hlEvaluated{k} = find(rt);
                else
                    if any(isnan(rt))
                        rt(isnan(rt)) = [];
                    end
                    hlEvaluated{k} = rt;
                end
                hlEvaluated{k} = reshape(hlEvaluated{k}, [], 1);
            end
            
        end
        
        function rt = getNumberOfPoints(obj)
            if nargin < 2
                dataSource = obj.dataSource;
            end
            
            rt = dataSource.getNumberOfPoints;
        end
        
        function applyTemplate(obj, template)
            for slotId = 1:numel(obj.ALL_XPROPERTY_SLOTS)
                %for k = 1:obj.nDisplays
                k = 1;
                propertyName = template.(dspace.Dataview.ALL_XPROPERTY_SLOTS{slotId});
                if obj.isOverriding || ~isempty(propertyName)
                    obj.(dspace.Dataview.ALL_XPROPERTY_SLOTS{slotId}) = propertyName;
                end
                %end
            end
            
            % focussed item id is not copied
            
            if obj.isOverriding || ~isempty(template.localGroupName)
                obj.localGroupName = template.localGroupName;
                obj.updateLocalGroupId();
            end
            if obj.isOverriding || ~template.pointFilter.isempty()
                obj.pointFilter = template.pointFilter;
            end
            if iscell(template.pointHighlights) && ~isempty(template.pointHighlights);
                template.pointHighlights = template.pointHighlights{1};
            end
            if obj.isOverriding || ~isempty(template.pointHighlights) ...
                    && ~template.pointHighlights.isempty() 
                obj.pointHighlights = template.pointHighlights;
            end
        end
        
    end
    
    % Various
    methods (Static, Hidden=true)
        function shortName = getXpropertyShortName(longName)
            idx = find(strcmp(dspace.Dataview.ALL_XPROPERTY_SLOTS, longName), 1);
            shortName = dspace.Dataview.ALL_XPROPERTY_SLOTS_SHORTNAMES{idx};
        end
    end
    
    % Creation of Empty Default View
    methods (Static)
        function dataview = getConfiguredDefaultView(dataSource)
            dataview = dspace.Dataview('', '', '', '', '', '', '', '', '');
            dataview.setDatasource(dataSource);
        end
    end
    
end





















