classdef PropertyDefinition < handle
    % A PropertyDefinition provides information helpful to interpret variables/properties
    % in a datasource.
    %
    %
    % Categorical Properties
    % ----------------------
    % Property-definitions provide a string meaning for each possible value 
    % of a categorical variable. All possible values are listed in .Values and 
    % for a value .Values[k], the meaning of each value is given in .ValueMeanings{k}.
    % 
    % Values or ValueMeanings must not contain duplicates and (obviously) be of the same length.
    %
    % Values and Value-meanings can be converted into one another by using the 
    % two methods:
    % <a href="matlab:doc('dspace_data.PropertyDefition/meaningsToValues')">meaningsToValues()</a>.
    % <a href="matlab:doc('dspace_data.PropertyDefition/meaningsToValues')">valuesToMeanings()</a>.
    %
    % 
    % Continuous Properties
    % ---------------------
    % .Values and .ValueMeanings are both empty.
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

    
    properties (Access=public, Dependent) 
        % A longer description of the variable (string).
        LongName
        
        % Denotes the unit of the variable (string).
        UnitName
        
        % A double array of possible values for categorical variables.
        Values
        
        % A cell array of strings, .ValueMeanings{k} gives the meaning for .Values{k}.
        ValueMeanings
        
        % User-defined custom data. Note: Property-definitions are stored with datasources.
        % The size (in bytes) of .Various should be kept small.
        Various
    end
    
    % Internal and legacy properties
    properties (Constant, Hidden=true)
        UNIT_SEQUENCE_INDEX = 'sequenceIndex';
    end
   
    properties (Access=protected, Hidden=true)
        % Can hold non-trivial value representations in subclasses
        values
        % Can hold non-trivial meaning representations in subclasses (e.g. 
        % compressed strings in FileLinkPropertyDefinition)
        valueMeanings
    end
    
    properties (Access=public, Hidden=true)     
        longName
        unit
        various
    end
    
    % Getters and setters.
    methods
   
        function value = get.Values(obj)
            value = obj.getValues();
        end
        function value = get.ValueMeanings(obj)
            value = obj.getValueMeanings();
        end
        function value = get.LongName(obj)
            value = obj.longName;
        end
        function value = get.UnitName(obj)
            value = obj.unit;
        end
        function value = get.Various(obj)
            value = obj.various;
        end
        
        function set.Values(obj, v)
            obj.setValues(v);
        end
        function set.ValueMeanings(obj, v)
            obj.setValueMeanings(v);
        end
        function set.LongName(obj, value)
            obj.longName = value;
        end
        function set.UnitName(obj, value)
            obj.unit = value;
        end
        function set.Various(obj, value)
            obj.various = value;
        end
   
    end
    
    methods (Access=public)
               
        function obj = PropertyDefinition(values, valueMeanings, longName, unit, various)
            % Create a property definition by calling this constructor with 1, 4, or 5 arguments.
            % 1 argument: argument is the longName for this PropertyDefinition.
            % 4 arguments: arguments are values, valueMeanings, longName, and unit.
            % 5 arguments: 5th argument is various.
            if nargin == 1
                obj.values = [];
                obj.valueMeanings = [];
                obj.longName = values;
                obj.unit = '';
                obj.various = [];
            elseif nargin >= 4
                obj.values = values;
                obj.valueMeanings = valueMeanings;
                obj.longName = longName;
                obj.unit = unit;
                if nargin == 5
                    obj.various = various;
                end
            else
                %assert(false, 'dspace_data.PropertyDefinition: Constructor takes either 1, 4, or 5 arguments.\n');
            end
        end
        
        function info(obj)
            obj.print();
        end
        
        % override in subclasses
        function meanings = valuesToMeanings(obj, values)
            % Converts a vector of double values into a cell array of strings containing value meanings.
            % If a value is not found 'Value not found.' is returned as a meaning.
            value_ids = ismember(values, obj.values);
            if any(value_ids == 0)
                fprintf('dspace_data.PropertyDefition/valuesToMeanings: Not all given values are contained in this PropertyDefinitions .Values.\n');
            end
            meanings(value_ids ~= 0) = obj.valueMeanings(value_ids(value_ids ~= 0));
            meanings(value_ids == 0) = {'Value not found.'};
        end
        
        % override in subclasses
        function values = meaningsToValues(obj, meanings)
            % Converts a cell array of strings into a double vector containing values corresponding to the given value-meanings.
            % If a meaning is not found in .ValueMeanings, NaN is returned as a value.
            meaning_ids = ismember(meanings, obj.valueMeanings);
            if any(meaning_ids == 0)
                fprintf('dspace_data.PropertyDefition/valuesToMeanings: Not all given meanings are contained in this PropertyDefinitions .ValueMeanings.\n');
            end
            values(meaning_ids ~= 0) = obj.values(meanings_ids(meanings_ids ~= 0));
            values(meaning_ids == 0) = NaN;
        end
        
        % override in subclasses
        function valueMeaning = valueToMeaning(obj, value)
            % Returns the value meaning for a given variable value or an empty string if no meanings are defined.
            valueMeaning = '';
            if ~isempty(obj.values) && ~isempty(obj.valueMeanings)
                idx = find(value == obj.values, 1);
                if ~isempty(idx) && numel(obj.valueMeanings) >= idx
                    valueMeaning = obj.valueMeanings{idx};
                end
            end
        end
        
        % override in subclasses
        function value = meaningToValue(obj, valueMeaning)
            % Return the variable value associated with the given meaning or returns [] if Values or ValueMeanings are undefined.
            r = find(strcmp(obj.valueMeanings, valueMeaning));
            if numel(r) == 1
                value = obj.values(r);
            elseif numel(r) == 0
                value = [];
            elseif numel(r) > 1
                value = [];
            end 
        end
        
        % override in subclasses
        % override this method to use non-trivial internal representations 
        % of values and valueMeanings
        function setValues(obj, values)
            obj.values = values;
        end
        
        % override in subclasses
        function setValueMeanings(obj, valueMeanings)
            obj.valueMeanings = valueMeanings;
        end
        
        % override in subclasses
        function values = getValues(obj)
            values = obj.values;
        end
        
        % override in subclasses
        function meanings = getValueMeanings(obj)
            meanings = obj.valueMeanings;
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
        
        function cellString = getDescription(obj)         
        end     
    end
    
    % Hide handle class methods
    methods (Hidden=true)
        function lh = addlistener(varargin)
            lh = addlistener@handle(varargin{:});
        end
        function notify(varargin)
            notify@handle(varargin{:});
        end
        function delete(varargin)
            delete@handle(varargin{:});
        end
        function Hmatch = findobj(varargin)
            Hmatch = findobj@handle(varargin{:});
        end
        function p = findprop(varargin)
            p = findprop@handle(varargin{:});
        end
        function TF = eq(varargin)
            TF = eq@handle(varargin{:});
        end
        function TF = ne(varargin)
            TF = ne@handle(varargin{:});
        end
        function TF = lt(varargin)
            TF = lt@handle(varargin{:});
        end
        function TF = le(varargin)
            TF = le@handle(varargin{:});
        end
        function TF = gt(varargin)
            TF = gt@handle(varargin{:});
        end
        function TF = ge(varargin)
            TF = ge@handle(varargin{:});
        end
    end
    
    methods (Static, Hidden=true)
        
        function definitions = createDefaultDefinitions(propTable)
            vn = propTable.Properties.VariableNames;
            definitions = [];
            for vid = 1:numel(vn)
                definitions.(vn{vid}) = dspace_data.PropertyDefinition([], [], vn{vid}, '');
            end
        end
        
        function definition = getDefaultDefinition(propertyName)
            definition = dspace_data.PropertyDefinition([], [], propertyName, '');
        end
      
    end
    
    
end

