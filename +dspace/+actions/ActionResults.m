classdef ActionResults < handle
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
        sourceName
        settings
        results
        actionName
        moduleFcnName
        pointFilterContainer
        timeAtExecution
    end
    
    methods
        
        function obj = ActionResults(sourceName, settings, results,...
                name, moduleFcnName, pfc, timeAtExecution)
            obj.sourceName = sourceName;
            obj.settings = settings;
            obj.results = results;
            obj.actionName = name;
            obj.moduleFcnName = moduleFcnName;
            obj.pointFilterContainer = pfc;
            if nargin < 7
                obj.timeAtExecution = now;
            else
                obj.timeAtExecution = timeAtExecution;
            end
        end
        
        function str = getDescriptor(obj)
            str = obj.actionName;
        end
        
        function mb = getMegabytes(obj)
            bytes = 0;
            Xv_ = obj.settings; %#ok<NASGU>
            q = whos('Xv_'); clear Xv_;
            bytes = bytes + q.bytes;
            
            Xv_ = obj.results; %#ok<NASGU>
            q = whos('Xv_'); clear Xv_;
            bytes = bytes + q.bytes;
            
            Xv_ = obj.pointFilterContainer; %#ok<NASGU>
            q = whos('Xv_'); clear Xv_;
            bytes = bytes + q.bytes;
            
            mb = bytes / 1024^2;
        end
        
        function printCode(obj, optNumber)
            settings_ = obj.settings;
            if isempty(settings_)
                if nargin == 2 && ~isempty(optNumber)
                    fprintf('\n%%%% %i. Run %s\n%%Missing settings struct (could not generate code).\n',...
                        optNumber, obj.actionName);
                else
                    fprintf('\n%%%% Run %s\n%%Missing settings struct (could not generate code).\n', obj.actionName);
                end
                return;
            end
            try
                settings_ = rmfield(settings_, 'WindowWidth');
                settings_ = rmfield(settings_, 'ControlWidth');
                settings_ = rmfield(settings_, 'runAll');
            catch
            end
            str = gencode(settings_, 'settings');
            
            if nargin == 2 && ~isempty(optNumber)
                fprintf('\n%%%% %i. Run %s\n', optNumber, obj.actionName);
            else
                fprintf('\n%%%% Run %s\n', obj.actionName);
            end
            fprintf('settings = [];\n');
            for k = 1:numel(str)
                fprintf('%s\n', str{k});
            end
            fprintf('view = dspace.Dataview.getConfiguredDefaultView(dsource);\n');
            fprintf('[~, ~, results] = %s(view, settings);\n\n', obj.moduleFcnName);
        end
        
    end
end

