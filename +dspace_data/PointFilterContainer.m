classdef PointFilterContainer < matlab.mixin.Copyable
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

    
    properties (Access=public)
        createdOn                            
        associatedSourceName
        name
    end
    
    properties (Access=public, Hidden=false)
        % deprecated:
        % filter                     % string - matlab expression that avaluates to a logical array 
        %                            % i.e. 'P.prop1 < b'
        
        conditionNames  = {}         % 1xC cell array of strings, can be '' or []
        conditions      = {}         % 1xC cell array of strings defining 
                                     % conditions through matlab expressions that avaluate to a 
                                     % logical array i.e. 'P.prop1 < b'.
                                     % each cell can be '' or []
                                    
        conditionIsActive            % 1xC boolean array
        
        conditionLinkages = {}       % 1x(C-1) cell array of strings, specifying logical operiations
                                     % '|' or '&'
                                     
    end
    
    properties (Access=public, Transient)
        %% TODO: move out compilation and such to (/bin) CompiledFilter:
        filterFcn                    % e.g. @(P, a, b) P.prop1 < b
        conditionFcns                
        filterString
    end
    
    methods
        
        function removeLastCondition(obj)
            lcc = obj.getConditionCount();
            if numel(obj.conditionNames) >= lcc
                obj.conditionNames(lcc) = [];
            end
            if numel(obj.conditions) >= lcc
                obj.conditions(lcc) = [];
            end
            if numel(obj.conditionIsActive) >= lcc
                obj.conditionIsActive(lcc) = [];
            end
            if lcc > 1
                if numel(obj.conditionLinkages) >= lcc-1
                    obj.conditionLinkages(lcc-1) = [];
                end
            end
        end
        
        function cc = getConditionCount(obj)
            cc = max([numel(obj.conditions), numel(obj.conditionNames),...
                numel(obj.conditionIsActive)]);
        end
        
        function cname = getConditionName(obj, cidx)
            if isempty(obj.conditionNames)
                cname = '';
            elseif numel(obj.conditionNames) >= cidx
                cname = obj.conditionNames{cidx};
            else
                cname = '';
            end
        end
        
        function setConditionName(obj, cidx, cname)
            obj.conditionNames{cidx} = string(cname);
        end
        
        function cstr = getCondition(obj, cidx)
            if isempty(obj.conditions)
                cstr = '';
            elseif numel(obj.conditions) >= cidx
                cstr = obj.conditions{cidx};
            else
                cstr = '';
            end
        end
        
        function setCondition(obj, cidx, cstr)
            obj.conditions{cidx} = char(string(cstr));
        end
        
        function isactive = getIsActiveCondition(obj, cidx)
            if isempty(obj.conditionIsActive)
                isactive = false;
            elseif numel(obj.conditionIsActive) >= cidx
                isactive = obj.conditionIsActive(cidx);
            else
                isactive = false;
            end
        end
        
        function setConditionIsActive(obj, cidx, isactive)
            obj.conditionIsActive(cidx) = isactive;
        end
        
        % return linkage belonging to condition k (linkage idx is k-1)
        function linkage = getConditionLinkage(obj, cidx)
            if isempty(obj.conditionLinkages)
                linkage = '&';
            elseif numel(obj.conditionLinkages) >= cidx-1
                linkage = obj.conditionLinkages{cidx-1};
                if isempty(linkage)
                    linkage = '&';
                end
            else
                linkage = '&';
            end
        end
        
        function setConditionLinkage(obj, cidx, linkage)
            obj.conditionLinkages{cidx-1} = linkage;
        end
        
    end
         
    methods
        
        function obj = PointFilterContainer(conditions, associatedSourceName, filterName)
            if ischar(conditions) && ~isempty(conditions)
                obj.conditions{1} = conditions;
            elseif iscellstr(conditions)
                obj.conditions = conditions;
            elseif isempty(conditions)
                obj.conditions = {};
                conditions = {};
            else
                assert(false);
            end
            obj.associatedSourceName = associatedSourceName;
            obj.name = filterName;
            obj.createdOn = now();
            obj.conditionIsActive = true(numel(obj.conditions), 1);
            obj.conditionLinkages = arrayfun(@(~) '&', 1:numel(obj.conditions)-1,...
                'uni', false);
            obj.conditions = cellfun(@(x) string(x), conditions, 'uni', false);
            obj.compileFilter();
        end
        
        % Checks syntactic correctness
        function [doesCompile, hasChanged] = compileFilter(obj)
            fstr = '';
            doesCompile = true(1, numel(obj.conditions));
            openBrackets = 0;
            for k = 1:numel(obj.conditions)
                cstr = obj.getCondition(k);
                try
                    if isempty(cstr)
                        obj.conditionFcns{k} = @(P, a, b) true(size(P, 1), 1);
                    else
                        obj.conditionFcns{k} = str2func(['@(P, a, b) ' cstr]);
                    end
                catch
                    doesCompile(k) = false;
                end
                if obj.getIsActiveCondition(k) && ~isempty(cstr)
                    if k > 1 && ~isempty(fstr)
                        costr = obj.getConditionLinkage(k);
                        if startsWith(costr, ')')
                            if openBrackets > 0
                                openBrackets = openBrackets-1;
                            else
                                costr = costr(2:end);
                            end
                        end
                        if endsWith(costr, '(')
                            openBrackets = openBrackets+1;
                        end
                        fstr = [fstr costr]; %#ok<AGROW>
                    end
                    fstr = [fstr '(' cstr ')']; %#ok<AGROW>
                end
            end
            for k = 1:openBrackets
                fstr = [fstr ')']; %#ok<AGROW>
            end
            hasChanged = ~strcmp(obj.filterString, fstr);
            if ~all(doesCompile) 
                return
            end
            obj.filterString = fstr;
            if isempty(fstr)
                obj.filterFcn = @(P, a, b) true(size(P, 1), 1);
            else
                obj.filterFcn = str2func(['@(P, a, b) ' fstr]);
            end
        end
        
        % Checks whether the filter can actually be executed on dsource
        % application of the filter with fault control and reporting
        function conditionCorrectness = checkFilter(obj, dsource, dview)    
            P = dsource.P;
            a = dview.getControlA;
            b = dview.getControlB;
            conditionCorrectness = false(1, numel(obj.conditions));
            for k = 1:numel(obj.conditions)
                executionOk = true;
                try
                    pf = obj.conditionFcns{k}(P, a, b);
                catch
                    executionOk = false;
                end
                if executionOk
                    executionOk = size(pf, 1) == dsource.getNumberOfPoints()...
                        & islogical(pf);
                end
                conditionCorrectness(k) = executionOk;
            end
        end
        
         function [pf, isCorrect] = apply(obj, dsource, dview)
            P = dsource.P;
            a = dview.getControlA;
            b = dview.getControlB;    
            try 
                pf = obj.filterFcn(P, a, b);
                isCorrect = true;
            catch
                pf = true(dsource.getNumberOfPoints(), 1);
                isCorrect = false;
            end
         end
            
        
        function str = getLongDescriptor(obj)
            if ~isempty(obj.name)
                str = sprintf('%s :: %s', obj.name, obj.filterString);
            else
                str = obj.filterString;
            end
            if ~isempty(obj.associatedSourceName)
                str = [str ' :: ' obj.associatedSourceName];
            end
%             if isempty(str)
%                 str = '-----------';
%             end
        end
        
        function str = getShortDescriptor(obj)
             if ~isempty(obj.name)
                str = sprintf('%s :: %s', obj.name, obj.filterString);
            else
                str = obj.filterString;
             end
%             if isempty(str)
%                 str = '-----------';
%             end
        end
        
        function rt = isempty(obj)
            rt = isempty(obj.filterString);
        end
         
    end
    
    methods (Static)
        
        function obj = loadobj(s)
            if isstruct(s)
                if isfield(s, 'filter')
                    obj = dspace_data.PointFilterContainer(s.filter, s.associatedSourceName, s.name);
                else
                    assert(false, 'Invalid Old PointFilterContainer Object');
                end
            else
                obj = s;
            end
            obj.compileFilter();
        end
        
        function idx = getIndexByName(name, filterContainerList)
            idx = NaN;
            for k = 1:numel(filterContainerList)
                if strcmp(name, filterContainerList{k}.name)
                    idx = k;
                    return;
                end
            end
        end
        
        function idx = getIndexByLongDescriptor(longDescriptor, filterContainerList)
            idx = NaN;
            for k = 1:numel(filterContainerList)
                if strcmp(longDescriptor, filterContainerList{k}.getLongDescriptor())
                    idx = k;
                    return;
                end
            end
        end
        
        function idx = getIndexByShortDescriptor(shortDescriptor, filterContainerList)
            idx = NaN;
            for k = 1:numel(filterContainerList)
                if strcmp(shortDescriptor, filterContainerList{k}.getShortDescriptor())
                    idx = k;
                    return;
                end
            end
        end
        
        function pfc = getEmptyFilter()
            pfc = dspace_data.PointFilterContainer({}, '', '---');
        end
        
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
    
end

