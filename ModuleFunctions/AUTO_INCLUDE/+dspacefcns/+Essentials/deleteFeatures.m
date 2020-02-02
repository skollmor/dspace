function [ titleStr, settings, results ] = deleteFeatures( dataview, settings )
    % This function removes one or more coordinate systems from the datasource.
    % Attention: If other coordinates depend on the deleted coordinates (because they
    % are derived from them), errors will result if those coordinates are accessed later.
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

    
    titleStr = 'Essentials/Organize Datasource/Delete Features';
    
    if nargin == 0
        % Function was called with 0 inputs: 
        % -- Only need to define the title (which we did already above)   
        return
    elseif nargin == 1 || (nargin == 2 && isempty(settings))
        % Function was called with 1 input or 2 inputs where the second is empty:
        % -- Only define default settings --
        source = dataview.getDatasource();
        featureNames = source.getCoordinateIdentifiers();
        settings = {'Description' , 'Delete features from datasource.',...
            'WindowWidth', 500, 'ControlWidth', 350,...
            {'Features to delete', 'featuresToDelete'}, dspace.app.StringList(featureNames)};
        return;
    end
    
    % Function was called with 2 arguments.
    %% -- Perform computations and create module function outputs --
    
    source = dataview.dataSource;
    featureNames = settings.featuresToDelete.strings;
    for cid = 1:numel(featureNames)
        [~, idx] = source.getCoordinatesByIdentifier(featureNames{cid});
        if ~isempty(idx)
            source.F(idx) = [];
        else
            fprintf('Features %s not found in source %s...\n', featureNames{cid}, source.getName());
        end
    end
   
    results.deletedFeatures = featureNames;
end
