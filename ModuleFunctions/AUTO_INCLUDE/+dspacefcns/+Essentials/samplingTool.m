function [ titleStr, settings, results ] = samplingTool( dataview, settings )
    % The samplingTool serves to subsample data. Based on one or several binning
    % variables (settings.binningVars), datapoints are selected such that the 
    % number of datapoints falling into each bin is either limited by some upper bound (Max-mode)
    % or constant across bins (Exact-mode).
    %
    % A sampling variable is created that will be NaN for points outside the current filter,
    % 1 for selected (sampled) points and 0 otherwise.
    %
    % <h4>'Exact' - Sampling</h4>
    % Each bin will either be empty (if not enough datapoints fall into it) or contains
    % exactly #Pts (settings.lsize) elements.  
    % <h4>'Max' - Sampling</h4>
    % Each bin will have at most #Pts (settings.lsize) elements.
    % <h4>Treatment of NaNs</h4>
    % NaNs in the binning variables are treated like normal values. In particular all 
    % NaNs are treated as identical.
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

    
    titleStr = 'Essentials/Select Datapoints/Sampling Tool';
    
    if nargin == 0
        % Function was called with 0 inputs: 
        % -- Only need to define the title (which we did already above)   
        return
    elseif nargin == 1 || (nargin == 2 && isempty(settings))
        % Function was called with 1 input or 2 inputs where the second is empty:
        % -- Only define default settings --
        pf = dataview.getPointFilter();
        varNames = dataview.getPropertyNames();
        settings = {'Description' , sprintf('Create sampling variable (%i points in current filter)', sum(pf)),...
            'WindowWidth', 500, 'ControlWidth', 350,...
            {'Binning variables', 'binningVars'}, dspace.app.StringList(varNames),...
            {'Mode', 'mode'}, {'Exact', 'Max'},...
             {'#Pts in bin', 'lsize'}, 5000,...
            {'New variable name', 'varName'}, 'samplingVar'};
        return;
    end
    
    % Function was called with 2 arguments.
    %% -- Perform computations and create module function outputs --
    
    source = dataview.getDatasource();
    pf = dataview.getPointFilter();
    selectedVars = settings.binningVars.strings;
    uvals = cell(1, numel(selectedVars));
    for vid = 1:numel(selectedVars)
        if any(isnan(source.P.(selectedVars{vid})(pf)))
            fprintf(['dspacefcns.Essentials.samplingTool: Variable %s is NaN for %i '...
                'datapoints inside the current filter.'], selectedVars{vid},...
                sum(isnan(source.P.(selectedVars{vid})(pf))));
        end
        pf2 = pf & ~isnan(source.P.(selectedVars{vid}));
        uvals{vid} = unique(source.P.(selectedVars{vid})(pf2))';
        if any(isnan(source.P.(selectedVars{vid})(pf)))
            uvals{vid}(end+1) = NaN;
        end
    end
    
    samplingVar = NaN(source.N, 1);
    if numel(selectedVars) == 0
        samplingVar(pf) = sample(settings.mode, settings.lsize, sum(pf));
    else
        allBins = combvec(uvals{:});
        for binId = 1:size(allBins, 2)
            pf2 = pf;
            for vid = 1:numel(selectedVars)
                if isnan(allBins(vid, binId))
                    pf2 = pf2 & isnan(source.P.(selectedVars{vid}));
                else
                    pf2 = pf2 & source.P.(selectedVars{vid}) == allBins(vid, binId);
                end
            end
            samplingVar(pf2) = sample(settings.mode, settings.lsize, sum(pf2));
        end  
    end
      
    samplingVar = double(samplingVar);
    
    dataview.putProperty(settings.varName,...
        samplingVar, dspace_data.PropertyDefinition([], [], settings.varName, '', []));
    
    results.newVariableName = settings.varName;
    
end

function s = sample(mode, nPts, nTotal)
    s = false(nTotal, 1);
    switch mode
        case 'Exact'
            if nTotal < nPts
                % Not enough elements in bin. Sample will be empty
            else
                chosenIds = randperm(nTotal, nPts);
                s(chosenIds) = true; 
            end       
        case 'Max'
                if nTotal > nPts
                    chosenIds = randperm(nTotal, nPts);
                    s(chosenIds) = true;
                else
                    % No need to subsample, take all points.
                    s(:) = true;
                end
        otherwise
            assert(false);
    end
end
