classdef FileLinkPropertyDefinition < dspace_data.PropertyDefinition
    % File-Link properties harbour a list of filenames and a rootpath.
    % The rootpath serves to adapt to new environments when data is copied.
    %
    % Filenames are stored in three parts to save memory: a fixed rootpath,
    % a varying subpath not unique over files and a filename unique to each file.
    % 
    % Parts are combined using fullfile().
    %
    % values and valueMeanings can not be set 
    %
    %
    % See also dspace_data.TableDataSource.
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
        
        rootpath
        
        subpaths
        
        % same order as values and valueMeanings
        subpathIds
        
        % filenames
        filenames
    
    end
    
    methods (Access=public)
        
        function obj = FileLinkPropertyDefinition(varargin)
            % Can be called with 3 arguments: 
            % rootpath, subpaths (same size as filenames), filenames
            % 
            % Can be called with 4 arguments: 
            % rootpath, subpaths (only unqiue subpaths), subpathIds, filenames
            if nargin == 3
                rootpath = varargin{1};
                subpaths = varargin{2};
                filenames = varargin{3};
                
                obj.rootpath = rootpath;
                if any(cellfun(@isempty, subpaths))
                    obj.subpaths{1} = '';
                    obj.subpathIds(cellfun(@isempty, subpaths)) = 1;
                    [sp_, ~, obj.subpathIds(~cellfun(@isempty, subpaths))] =...
                        unique(subpaths(~cellfun(@isempty, subpaths)));
                    obj.subpaths = [obj.subpaths ; sp_];
                    obj.subpathIds(~cellfun(@isempty, subpaths)) = obj.subpathIds(~cellfun(@isempty, subpaths)) + 1;
                else
                    [obj.subpaths, ~, obj.subpathIds] = unique(subpaths);
                end
            elseif nargin == 4
                obj.rootpath = varargin{1};
                obj.subpaths = varargin{2};
                obj.subpathIds = varargin{3};
                filenames = varargin{4};
            else
                assert(false);
            end
            obj.filenames = filenames;
            obj.values = 1:numel(filenames);
            obj.valueMeanings = [];
            obj.longName = sprintf('Link to data at %s.', obj.rootpath);
            obj.unit = 'File-Link Property';
        end
        
        function [rootpath, subpaths, filenames] = getSplitFilenames(obj)
            rootpath = obj.rootpath;
            subpaths = obj.subpaths(obj.subpathIds);
            filenames = obj.filenames;
        end
        
        function meanings = valuesToMeanings(obj, values)
            % Converts a vector of double values into a cell array of strings containing value meanings.
            % If a value is not found 'Value not found.' is returned as a meaning.
            [~, value_ids] = ismember(values, obj.values);
            if any(value_ids == 0)
                fprintf('dspace_data.PropertyDefition/valuesToMeanings: Not all given values are contained in this PropertyDefinitions .Values.\n');
            end
            meanings(value_ids ~= 0) = fullfile(obj.rootpath, obj.subpaths(obj.subpathIds(value_ids(value_ids ~= 0))),...
                obj.filenames(value_ids(value_ids ~= 0)));
            meanings(value_ids == 0) = {'Value not found.'};
        end
        
        function fnames = getFullFilenames(obj, values)
            fnames = obj.valuesToMeanings(values);
        end
        
        function fname = getFullFilename(obj, value)
            fname = obj.valueToMeaning(value);
        end
        
        function values = meaningsToValues(obj, meanings)
            % Converts a cell array of strings into a double vector containing values corresponding to the given value-meanings.
            % If a meaning is not found in .ValueMeanings, NaN is returned as a value.
            assert(false);
%             meaning_ids = ismember(meanings, obj.valueMeanings);
%             if any(meaning_ids == 0)
%                 fprintf('dspace_data.PropertyDefition/valuesToMeanings: Not all given meanings are contained in this PropertyDefinitions .ValueMeanings.\n');
%             end
%             values(meaning_ids ~= 0) = obj.values(meanings_ids(meanings_ids ~= 0));
%             values(meaning_ids == 0) = NaN;
        end
        
        function valueMeaning = valueToMeaning(obj, value)
            % Returns the value meaning for a given variable value or an empty string if no meanings are defined.
            valueMeaning = obj.valuesToMeanings(value);
            valueMeaning = valueMeaning{1};
        end
        
        function value = meaningToValue(obj, valueMeaning)
            % Return the variable value associated with the given meaning or returns [] if Values or ValueMeanings are undefined.
            assert(false);
%             r = find(strcmp(obj.valueMeanings, valueMeaning));
%             if numel(r) == 1
%                 value = obj.values(r);
%             elseif numel(r) == 0
%                 value = [];
%             elseif numel(r) > 1
%                 value = [];
%             end 
        end
        
        function setValues(obj, values)
            assert(false);
            %obj.values = values;
        end
        
        % override in subclasses
        function setValueMeanings(obj, valueMeanings)
            assert(false);
            %obj.valueMeanings = valueMeanings;
        end
        
        function values = getValues(obj)
            values = obj.values;
        end
        
        function meanings = getValueMeanings(obj)
            meanings = obj.valuesToMeanings(obj.values);
        end
        
    end
    
    % Legacy methods
    methods (Access=public, Hidden=true)
        function print(obj)
            % Prints a summary of this propery definition
            fprintf('Long name: %s\n', obj.longName);
            if ~isempty(obj.unit)
                fprintf('Unit: <%s>\n', obj.unit);
            else
                fprintf('Unit: <>\n');
            end
            if ~isempty(obj.values) && ~isempty(obj.valueMeanings)
                pt = table();
                pt.Value = reshape(obj.values, [], 1);
                pt.Meaning = reshape(obj.valueMeanings, [], 1);
                fprintf('Values:\n\n');
                disp(pt);
            end
            if ~isempty(obj.various)
                fprintf('Additional Properties:\n');
                disp(obj.various);
            end     
        end
        
    end
    
        
end

