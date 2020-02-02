classdef StringList < handle
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

    
    properties
        promptString = 'Select options';
        
        choices
        isSelected
        maxSummaryStringLength = 30;
    end
    
    properties (Dependent)
        N
        strings
        summaryString
    end
    
    methods
        
        function rt = get.summaryString(obj)
            s = '';
            for k = 1:numel(obj.strings)
                if isempty(s)
                    s = obj.strings{k};
                else
                    s = [s '; ' obj.strings{k}]; %#ok<AGROW>
                end
            end
            if numel(s) > obj.maxSummaryStringLength
                s = s(1:obj.maxSummaryStringLength);
                s = [s '...'];
            end
            if isempty(s)
                if obj.N == 0 && numel(obj.choices) == 0
                    rt = sprintf('0 options available');
                else
                    rt = sprintf('%i selected', obj.N);
                end
            else
                rt = sprintf('%i selected (%s)', obj.N, s);
            end
        end
        
        function rt = get.N(obj)
            rt = sum(obj.isSelected);
        end
        
        function rt = get.strings(obj)
            rt = obj.choices(obj.isSelected);
        end
        
    end
    
    methods
        
        function obj = StringList(choices, isSelected)
            obj.choices = choices;
            if nargin > 1
                obj.isSelected = isSelected;
            else
                obj.isSelected = false(size(choices));
            end
        end
        
        function guiSelect(obj)
            if numel(obj.choices) == 0
                return;
            end
            [sel, ok] = listdlg('PromptString',obj.promptString,...
                'SelectionMode','multiple', 'ListString', obj.choices,...
                'OKString', 'Select', 'ListSize', [600, 300],...
                'initialValue', find(obj.isSelected));
            
            if ok
                obj.isSelected = false(numel(obj.choices), 1);
                obj.isSelected(sel) = true;
            end
        end
        
        function select(obj, stringsToSelect)
            new_isSelected = false(numel(obj.choices), 1);
            for k = 1:numel(stringsToSelect)
                id = strcmp(stringsToSelect{k}, obj.choices);
                new_isSelected(id) = true;
            end
            obj.isSelected = new_isSelected;
        end
        
        
    end
end

