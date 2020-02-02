function [ titleStr, settings, results ] = deleteDatasources( dataview, settings )
    % This function removes one or more datasources from the current collection. 
    % Use with care. This operation can not be undone.
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

    
    titleStr = 'Essentials/Organize Collection/Delete Datasources';
    
    if nargin == 0
        % Function was called with 0 inputs: 
        % -- Only need to define the title (which we did already above)   
        return
    elseif nargin == 1 || (nargin == 2 && isempty(settings))
        % Function was called with 1 input or 2 inputs where the second is empty:
        % -- Only define default settings --
        source = dataview.getDatasource();
        srcNames = compileSourceNames(source.ParentCollection);
        settings = {'Description' , 'Delete datasources from the current collection.',...
            'WindowWidth', 500, 'ControlWidth', 350,...
            {'Datasources to delete', 'srcsToDelete'}, dspace.app.StringList(srcNames),...
            {'Delete empty levels', 'deleteEmptyLevels'}, true};
        return;
    end
    
    % Function was called with 2 arguments.
    %% -- Perform computations and create module function outputs --
    
    source = dataview.dataSource;
    delNames = settings.srcsToDelete.strings;
    srcNames = compileSourceNames(source.ParentCollection);
    col = source.ParentCollection;
    for cid = 1:numel(delNames)
        
        idx = find(strcmp(delNames{cid}, srcNames));
        [sourceLevel, sourceId] = getDataSourceIndexPair(col, idx);
        fprintf('Deleting datasource <%s> from level <%s>...\n',...
            col.sources.(col.LevelNames{sourceLevel}){sourceId}.Name,...
            col.LevelNames{sourceLevel});
        col.sources.(col.LevelNames{sourceLevel})(sourceId) = [];
        
        if settings.deleteEmptyLevels && numel(col.sources.(col.LevelNames{sourceLevel})) == 0 
            col.sources = rmfield(col.sources, col.LevelNames{sourceLevel});
        end
        
    end
   
    results = [];
end


function [sourceLevel, sourceId] = getDataSourceIndexPair(col, runningIdx)
    if ~isempty(runningIdx)
        ps = 0;
        levelNames = col.getLevelNames();
        for sourceLevel = 1:numel(levelNames)
            if runningIdx <= ps + numel(col{sourceLevel})
                sourceId = runningIdx - ps;
                return;
            else
                ps = ps + numel(col{sourceLevel});
            end
        end
    end
    sourceLevel = NaN;
    sourceId = NaN;
end

function names = compileSourceNames(col)
    names = {};
    levelNames = col.getLevelNames();
    for sourceLevel = 1:numel(levelNames)
        %<HTML><FONT color="red">Hello</Font></html>
        paddln = levelNames{sourceLevel}; %sprintf('%30s', levelNames{sourceLevel});
        %paddln = strrep(paddln, ' ', '-');
        if mod(sourceLevel, 2) == 1
            names{end+1} = arrayfun(@(i) sprintf('%2i-%s | %s (%i/%i)', sourceLevel, ...
                paddln, col{sourceLevel}{i}.getName(), i, numel(col{sourceLevel})), ...
                1:numel(col{sourceLevel}), 'uni', false);
        else
            names{end+1} = arrayfun(@(i) sprintf('%2i-%s | %s (%i/%i)', sourceLevel, ...
                paddln, col{sourceLevel}{i}.getName(), i, numel(col{sourceLevel})), ...
                1:numel(col{sourceLevel}), 'uni', false);
        end
        
        %                 names{end+1} = arrayfun(@(i) sprintf('<bold>%i</bold>| %s (%i/%i)', sourceLevel, ...
        %                     obj.dataSources{sourceLevel}{i}.getName(), i, numel(obj.dataSources{sourceLevel})), ...
        %                     1:numel(obj.dataSources{sourceLevel}), 'uni', false);
        
    end
    names = horzcat(names{:});
end