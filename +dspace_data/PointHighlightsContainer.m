classdef PointHighlightsContainer < handle
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
        
        % cell array of matlab commands (as strings)
        highlights = {}
        
        % arguments: P, a, b, lgIds, cId
        % (properties, control a, control b, current local group ids,
        % current id)
        highlightFcns = {}
        
        highlightNames = {};
        
        associatedSourceName
        name
        
    end
    
    properties (Constant)
        emptyHighlights = dspace_data.PointHighlightsContainer({}, {}, '', '');
    end
    
    methods
        
        function obj = PointHighlightsContainer(highlights, highlightNames, associatedSourceName, name)
            obj.highlights = highlights;
            obj.highlightNames = highlightNames;
            obj.associatedSourceName = associatedSourceName;
            obj.name = name;
            obj.createdOn = now();
        end
        
        function str = getLongDescriptor(obj)
            if ~isempty(obj.name)
                str = sprintf('%s :: %i types', obj.name, numel(obj.highlights));
            else
                str = sprintf('Unnamed :: %i types', numel(obj.highlights));
            end
            if ~isempty(obj.associatedSourceName)
                str = [str ' :: ' obj.associatedSourceName];
            end
        end
        
        function str = getShortDescriptor(obj)
            if ~isempty(obj.name)
                str = sprintf('%s :: %i types', obj.name, numel(obj.highlights));
            else
                str = sprintf('Unnamed :: %i types', numel(obj.highlights));
            end
        end
        
        function compileHighlightFcns(obj)
            for k = 1:numel(obj.highlights)
                obj.highlightFcns{k} = str2func(['@(P, a, b, lgIds, cId) ' obj.highlights{k}]);
            end
        end
        
        function rt = isempty(obj)
            rt = isempty(obj.highlights) && isempty(obj.name);
        end
        
    end
    
    methods (Static)
        
        function idx = getIndexByLongDescriptor(longDescriptor, highlightsList)
            idx = NaN;
            for k = 1:numel(highlightsList)
                if strcmp(longDescriptor, highlightsList{k}.getLongDescriptor())
                    idx = k;
                    return;
                end
            end
        end
        
        function idx = getIndexByShortDescriptor(shortDescriptor, highlightsList)
            idx = NaN;
            for k = 1:numel(highlightsList)
                if strcmp(shortDescriptor, highlightsList{k}.getShortDescriptor())
                    idx = k;
                    return;
                end
            end
        end
        
        function pfc = getEmptyHighlights()
            pfc = dspace_data.PointHighlightsContainer.emptyHighlights;
        end
        
    end
    
end

