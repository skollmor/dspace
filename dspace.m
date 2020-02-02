function varargout = dspace(varargin)
    % DSPACE Starts Dataspace v1.3 and imports data.
    % 
    % If you are new to Dataspace, start by reading our great but consise
    % <a href="matlab:dspace.help('dspace.resources.docs.Introduction_to_Dataspace')">Introduction and Data Import Tutorial (dspace help)</a>.
    % 
    % 
    % Starting the Dataspace GUI
    % --------------------------
    %
    % DSPACE() - starts an instance of the Dataspace GUI. 
    %
    % DSPACE(datasource) - starts a dataspace instance with the given datasource.
    % (see <a href="matlab:doc('dspace_data.TableDataSource')">dspace_data.TableDataSource</a>)
    %
    % DSPACE(datacollection) - starts a dataspace instance with the given data-
    % collection.
    % (see <a href="matlab:doc('dspace_data.DataCollection')">dspace.DataCollection</a>)
    %
    %
    % Importing Matlab Standard Data Types
    % ------------------------------------
    %
    % DSPACE(table) - creates a datasource from the given table T and starts 
    % a dataspace instance with that datasource.
    % (see <a href="matlab:doc('table')">table</a>).
    %
    % DSPACE(matrix) - creates a datasource from the given matrix (it will 
    % be treated as NxD coordinates, where N is the number of datapoints and
    % D the dimension, or as NxD1xD2, where N is the number of datapoints and
    % D1 and D2 are height and width of the coordinate matrix respectively)
    % Currently the dataspace GUI only displays 1-d (i.e. vectors) or 2-d (e.g.
    % images) coordinates. Use reshape to convert n-d (n>2) into 1-d or 2-d 
    % coordinates.
    % (see <a href="matlab:doc('reshape')">reshape</a>).
    %
    % DSPACE(vector) - creates a datasource from a column-vector (treated as 
    % a variable).
    %
    % DSPACE(vector1, matrix1, vector2, table1, table2) - all above conventions
    % can be combined. In that case every matrix (size(M, 2) > 1) is interpreted
    % as coordinates, columns of width 1 in tables are interpreted as
    % variables and columns of width D>1 are interpreted as coordinates.
    %
    % source = DSPACE(_) - works like the modes above except that it does
    % not start the dataspace GUI but returns the created datasource. 
    % (see <a href="matlab:doc('dspace_data.TableDataSource')">TableDataSource</a>)
    %
    % [source, dspaceApp] = DSPACE(_) - works like the modes above, starts
    % a dspace GUI and returns the dspaceApp object. 
    %
    % Multiple datasources can easily be combined in data-collections. More information
    % and an example can be found here:
    % <a href="matlab:doc('dspace_data.DataCollection')">dspace.DataCollection</a>
    %
    %
    % Assigning Names to Imported Standard Data Types
    % -----------------------------------------------
    % 
    % A call to DSPACE() such as this one:
    %
    % DSPACE(vector1, matrix1, vector2, table1, table2)
    %
    % the actual argument names of the function call (that is 'vector1', 
    % 'matrix1',...) are used to name the features and labels resulting 
    % from matrix and vector data import. For table-data the column names are used.
    %
    % You can also insert strings before vector, matrix and cell array arguments to name
    % the resulting labels and features:
    %
    % DSPACE('vector1_name', vector1, matrix1, 'vector2_name', vector2, table1, table2)
    %
    % A string before a table argument creates an error.
    %
    %
    % Importing Data From .csv and Other Files
    % ----------------------------------------
    %
    % A more extensive tutorial on importing data is given in the dataspace
    % help:
    % <a href="matlab:dspace.help('dspace.resources.docs.Introduction_to_Dataspace')">Introduction and Data Import Tutorial (dspace help)</a>
    % 
    % To import tables and other data from .csv or other files use Matlab's 
    % capabilities. In the Matlab GUI: 
    % <a href="https://au.mathworks.com/help/matlab/ref/importtool-app.html">Home/Import Data</a>. 
    % 
    % Or, use the built-in Matlab functions to create tables and matrices that 
    % you then import using DSPACE(). Helpful and convenient Matlab functions 
    % are, i.e.: 
    % <a href="matlab:doc('uiimport')">uiimport</a> 
    % <a href="matlab:doc('readtable')">readtable</a>.
    %
    % To create tables from other datatypes, you can also use the Matlab built-in
    % functions:
    % <a href="matlab:doc('array2table')">array2table</a> - Convert homogeneous array to table.
    % <a href="matlab:doc('cell2table')">cell2table</a> - Convert cell array to table.
    % <a href="matlab:doc('struct2table')">struct2table</a> - Convert structure array to table.
    %
    %
    % Examples
    % --------
    %
    % You can find those and more examples also in dspace_examples.m in the 
    % dataspace main folder.
    %
    % % %% Random Smoothed Data
    % imgs = randn(10000, 100, 100);
    % imgs = convn(imgs, ones(1, 10, 10), 'same');
    % random_values = randn(10000, 1);
    % idx = (1:10000)';
    % dspace('unrelatedNumbers', random_values, 'Random Images', imgs, 'IndexVar', idx);
    %
    % %% IRIS Dataset
    % load fisheriris;
    % X = meas.';
    % Y = species;
    % irisData = table(X(1, :)', X(2, :)', X(3, :)', X(4, :)', Y, 'VariableNames',...
    % {'sepal_length_cm', 'sepal_width_cm', 'petal_length_cm', 'petal_width_cm',...
    % 'target_label'});
    % irisFeatures = X';
    % dspace(irisData, irisFeatures);
    %
    % %% Matlab's Synthetic Digit Dataset (requires neural network toolbox)
    % digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos','nndatasets','DigitDataset');
    % imds = imageDatastore(digitDatasetPath,'IncludeSubfolders',true,'LabelSource','foldernames');
    % imgs = imds.readall();
    % labels = double(imds.Labels);
    % idx = (1:numel(labels))';
    % source = dspace(imgs, labels, idx);
    % source.name = 'Matlab Synthetic Digits Dataset';
    % dspace(source);
    %
    %
    % Important Notes
    % ---------------
    %
    % This function must be located in the main Dataspace-Folder. This main folder 
    % also contains the package-folder +dspace.
    %
    % See also dspace.start, dspace.help.
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

    
    % (TODO not implemented:
    % Note: The .addFeatures() and .addLabels() methods of 
    % dspace_data.TableDataSource support the same data-arguments 
    % as DSPACE and can be used to add data to existing datasources:
    % <a href="matlab:doc('dspace_data.TableDataSource/addCoordinates')">dspace_data.TableDataSource.addFeatures()</a>
    % <a href="matlab:doc('dspace_data.TableDataSource/addVariables')">dspace_data.TableDataSource/addVariables()</a>)
   
    if nargin == 0
        
        assert(nargout == 0, 'dspace(): if the function is called without import arguments, it can not have output arguments.');
        
        fprintf('dspace(): starting dspace-GUI...\n');
        dspace.start();
        
        return
    
    end
    
    inputNames = {};
    inArgs = {};
    C = 1;
    k = 1;
    
    while (k <= nargin)
        if isstring(varargin{k}) || ischar(varargin{k})
            % By definition strings can only occur as names for vector or matrix arguments.
            if k == nargin
                warning(['dspace: The last function input (%i) is a string (%s). '...
                    'Strings can only occur in name, value pairs (to give names '...
                    'to labels or features). Input ignored.\n'], k, varargin{k});
                    break;
            end
            if isstring(varargin{k+1}) || ischar(varargin{k+1})
                 warning(['dspace: Function inputs (%i) and (%i) are both strings (%s, %s). '...
                    'Strings can only occur in name, value pairs (to give names '...
                    'to labels or features). Input ignored.\n'],...
                        k, k+1, varargin{k}, varargin{k+1});
                    k = k + 2;
                    continue;
            end
            if ~isnumeric(varargin{k+1}) && ~iscell(varargin{k+1})
                 warning(['dspace: Function input (%i) is a string (%s). '...
                    'The next input (%i) must be numeric or a cell array but is neither. '... 
                    'Input ignored.\n'], k, varargin{k}, k+1);
                    k = k + 2;
                    continue;
            end
            % Create input from the name, value pair
            % make sure the name can be used in Matlab code
            inputNames{C} = matlab.lang.makeValidName(varargin{k});
            inArgs{C} = varargin{k+1};
            C = C + 1;
            k = k + 2;
        else
            % Create input from the value and the name of the function input (if available)
            inputNames{C} = inputname(k);
            if isempty(inputNames{C})
                inputNames{C} = sprintf('input%i', C);
            end
            inArgs{C} = varargin{k};
            C = C + 1;
            k = k + 1;
        end
            
        if isempty(inputNames{C-1})
            inputNames{C-1} = sprintf('input%i', C-1);
        end
    end
    
    if dspace.isDataCollection(inArgs{1}) || dspace.isDatasource(inArgs{1})
        if nargout == 0
            fprintf('dspace(): starting dspace-GUI...\n');
            dspace.start(inArgs{1});
        elseif nargout == 1
            varargout{1} = inArgs{1};
        elseif nargout == 2
            varargout{1} = inArgs{1};
            fprintf('dspace(): starting dspace-GUI...\n');
            varargout{2} = dspace.start(inArgs{1});
        end
        
        return
    end
    
    %% Data Import
    % nargin >= 1 and 1st argument is not a string, datasource, or data-collection 
    % 1st and all other arguments must be data arguments (tables, cells, matrices 
    % or vectors) 
    
    source = dspace.parseDspaceArgs(inArgs, inputNames, 1);
      
    if nargout == 1
    
        varargout{1} = source;
    
    elseif nargout == 0 || nargout == 2
    
        fprintf('dspace(): starting dspace-GUI...\n');
        dspaceApp = dspace.start(source);    
        
        if nargout == 2
            varargout{1} = source;
            varargout{2} = dspaceApp;
        end
        
    end
     
end