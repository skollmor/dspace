function [ titleStr, settings, results ] = createLabelsFromFeatures( dataview, settings )
    % This function stores feature information for all datapoints within
    % the current selection in one or several new labels.
    %
    % Ids -- specified as a matlab expression, e.g. Ids='1' or Ids='1:10'
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


    if nargin == 0
        % This moduleFcn was called with 0 arguments --> return a name and label for this module
        % function.
        titleStr = 'Essentials/Features/Create Labels from Features';
        return;
    end 
        
    pf = dataview.getPointFilter();
    source = dataview.dataSource;
    np = sum(pf);
    featureIdentifiers = source.getCoordinateIdentifiers();
        
    titleStr = sprintf('Create labels from features on current selection (%i points).', np);
    
    if nargin < 2 || isempty(settings)
        % This moduleFcn was called with 1 argument --> return a settings structure for this module
        % function
        settings = {'Description' , sprintf('Derive labels from features on current selection (%i points)',...
            np),...
            'WindowWidth', 600, 'ControlWidth', 350,...
            'separator', 'Input',...
            {'Features', 'featureName'}, featureIdentifiers,...
            'separator', 'Individual Feature Components',...
            {'Ids (Matlab Expr. as String or Empty)', 'ids'}, '1',...
            {'Export all Components', 'allIds'}, false,...
            {'Use Feature-Layout for Names', 'useLayout'}, true,...
            {'Output Variable Stem', 'variableStem'}, 'newLabel_',...
            'separator', 'Functions of Feature Vectors',...
            {'Sum', 'computeSum'}, false,...
            {'Var', 'computeVar'}, false};
        return;
    end
    
    %% ModuleFcn called with 2 arguments - perform computation
    newName = settings.variableStem;
    newName = [newName settings.featureName];
    ftId = find(strcmp(settings.featureName, featureIdentifiers));
    parentFeatures = source.coordinates{ftId}; 
    
    [X, layout] = parentFeatures.getMatrix(find(pf));
 
    newVarNames = {};
    if ~isempty(settings.ids) || settings.allIds
        if settings.allIds
            ids = 1:size(X, 2);
        elseif isnumeric(settings.ids)
            ids = settings.ids;
        else
            ids = eval(settings.ids);
        end
        for k = 1:numel(ids)
            Xvals = NaN(source.getNumberOfPoints(), 1);
            Xvals(pf) = X(:, ids(k));
            if settings.useLayout && ~isempty(layout.componentMeanings)
                newname = matlab.lang.makeValidName(sprintf('%s_%s', settings.variableStem, layout.componentMeanings{1}{ids(k)}));
            else
                newname = matlab.lang.makeValidName(sprintf('%sC%i', settings.variableStem, ids(k)));
            end
            dataview.putProperty(newname, Xvals,...
                    dspace_data.PropertyDefinition([], [], newname, '', settings));
                newVarNames{end+1} = newname; %#ok<AGROW>
        end
    end
    if settings.computeSum
        Xvals = NaN(source.getNumberOfPoints(), 1);
        Xvals(pf) = sum(X(:, :), 2);
        dataview.putProperty(matlab.lang.makeValidName(sprintf('%sSum', settings.variableStem)), Xvals,...
            dspace_data.PropertyDefinition([], [], sprintf('%sSum', settings.variableStem), '', settings));
        newVarNames{end+1} = matlab.lang.makeValidName(sprintf('%sSum', settings.variableStem));
    end
    
    if settings.computeVar
        Xvals = NaN(source.getNumberOfPoints(), 1);
        Xvals(pf) = var(X(:, :), [], 2);
        dataview.putProperty(matlab.lang.makeValidName(sprintf('%sVar', settings.variableStem)), Xvals,...
            dspace_data.PropertyDefinition([], [], sprintf('%sVar', settings.variableStem), '', settings));
        newVarNames{end+1} = matlab.lang.makeValidName(sprintf('%sVar', settings.variableStem));
    end
    
    %% Write results struct
    results.newVarNames = newVarNames;
end




