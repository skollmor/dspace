function [ titleStr, settings, results ] = binningTool( dataview, settings )
    % The binningTool module function serves to sort data into different bins. 
    % Several binning variables are created that contain (1) a bin-index for each data point,
    % (2) an index within each bin, and (3) a global bin-index (see grouping variable).
    %
    % Lets say your dataset has a total of 100 datapoints. You defined a 
    % ordering-variable (settings.orderingVariable) T indicating a measurement 
    % time. Now you want to bin the data into groups of 10 datapoints, such 
    % that the first group contains the 100 datapoints with the 10 lowest 
    % measurement times and so on:
    % <PRE> 
    % Datapoints          . . .. . .....   . ....                 ..... .. ...  .....|     
    % 
    % Ordering Variable   ----------------------------------------------------------->
    % 
    % Bins                |            |   |                          | |            | 
    % 
    % Bin Idx             1 1 11 1 11111   2 2222                 22222 33 333  33333|  
    % 
    % Idx in Bin          1 2 34 5 678910  1 2345                 67891012 345  678910
    % </PRE>
    % The bin size (settings.binSize) can be an integer or a fraction of the total number 
    % of available datapoints. This is determined by the binning mode.
    % 
    % <h3>Binning modes (settings.binningMode)</h3>
    % <h4>'Fixed Size, Back to Back, Partial Final Bin'</h4>
    % Each bin (except the last) has a fixed number of datapoints, all datapoints are covered, the last
    % bin will be incomplete unless the total number of points is a multiple of the
    % binsize.
    % 
    % <h4>'Fixed Size, Spaced'</h4>
    % Each bin has a fixed number of datapoints, not all datapoints are covered.
    % Bins are equally spaced.
    %
    % <h4>'Percentage, Spaced'</h4>
    % Binsize is a fraction between 0 and 1. Each bin has a fixed number of 
    % datapoints, not all datapoints are covered. Bins are equally spaced.
    %
    % <h4>'Percentage, Back to Back, Partial Final Stage'</h4>
    % Binsize is a fraction between 0 and 1. Each bin (except the last) has 
    % a fixed number of datapoints, all datapoints are covered, the last bin 
    % will be incomplete unless the total number of points is divisible by 
    % 1/binSize.
    % 
    % <h3> Using a grouping variable (settings.groupingVariable) </h3>
    % If a grouping variable is provided, it must be categorical. Binning then 
    % takes place seperately within each level of the grouping variable.
    % The global order of the bins is determined by the grouping variable, whereas 
    % the order within each grouping level is determined by the orderingVariable.
    % 
    % <h3>Outputs</h3>
    % - 'Global bin index' (settings.outputvar_idxGlobal)
    % 
    % - 'Bin index within group' (settings.outputvar_idxInGroup)
    %
    % - 'Item index within bin' (settings.outputvar_idxInBin)
    %
    % <h3>Treatment of NaNs</h3>
    % All outputs will be NaN for points whose orderingVariable values or  
    % groupingVariable values are NaN.
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

    
    titleStr = 'Essentials/Binning Tool';
    
    if nargin == 0
        % Function was called with 0 inputs: 
        % -- Only need to define the title (which we did already above)   
        return
    elseif nargin == 1 || (nargin == 2 && isempty(settings))
        % Function was called with 1 input or 2 inputs where the second is empty:
        % -- Only define default settings --
        varNames = dataview.getPropertyNames();
        pf = dataview.getPointFilter();
        settings = {'Description' , sprintf('Create binning variable (%i points in selection).', sum(pf)),...
            'WindowWidth', 600, 'ControlWidth', 350,...
            {'Ordering variable', 'orderingVariable'}, varNames,...
            {'Grouping variable', 'groupingVariable'}, ['---', varNames],...
            {'Retain sign of grouping variable', 'retainSign'}, true,...
            {'Bin size (#Pts>=1 or fraction [0,1[)', 'binSize'}, 200,...
            {'Max. bins per ordering level', 'maxBinsPerOrderingLevel'}, 0,...
            {'Binning mode', 'binningMode'},...
            {...
            'Fixed Size, Back to Back, Partial Final Stage',...
            'Fixed Size, Spaced',...
            'Percentage, Spaced',...
            'Percentage, Back to Back, Partial Final Stage'...
            },...
            'separator', 'Variables to Create',...
            {'Global bin index', 'outputVar_idxGlobal'}, 't_binIdx_global',...
            {'Bin index within group', 'outputVar_idxInGroup'}, 't_binIdx_inGroup',...
            {'Item index within bin', 'outputVar_idxInBin'}, 't_idx_withinBin'};
        return;
    end
    
    % Function was called with 2 arguments.
    %% -- Perform computations and create module function outputs --
    
    source = dataview.getDatasource();
    pf_unrestricted = dataview.getPointFilter();
    pf_restricted = pf_unrestricted & ~isnan(source.P.(settings.orderingVariable));
    if ~strcmp(settings.groupingVariable, '---')
        pf_restricted = pf_restricted & ~isnan(source.P.(settings.groupingVariable));
        superstages = source.P.(settings.groupingVariable)(pf_restricted);
    else
        superstages = ones(sum(pf_restricted), 1);
    end
    
    if sum(pf_unrestricted) > sum(pf_restricted)
        fprintf('dspacefcns.Essentials.binningTool: Warning! Binning or grouping variable values are NaN for %i datapoints.\n',...
            sum(pf_unrestricted) - sum(pf_restricted));
    end
    
    % Only include datapoints in binning that have non-NaN ordering and grouping
    % variable values.
    pf = pf_restricted;
    
    pfids = find(pf);
    order = source.P.(settings.orderingVariable)(pfids);
    binSize = settings.binSize;
    slevels = unique(superstages);
    
    if numel(slevels) > 1000
        fprintf('dspacefcns.Essentials.binningTool: Warning! The grouping variable %s has %i levels and might not be categorical.\n',...
            settings.groupingVariable, numel(slevels));
    end
    
    out_stageVar = NaN(numel(pfids), 1);
    out_stageInSuperstage = NaN(numel(pfids), 1);
    out_idxInStage = NaN(numel(pfids), 1);
    
    if settings.retainSign && strcmp(settings.binningMode,...
            'Percentage, Back to Back, Partial Final Stage')
        % negative stages will be numbered until zero, first positive stage
        % has index 1
        stageCount = - (1/binSize) * sum(slevels < 0);
    else
        stageCount = 0;
    end
      
    for slid = 1:numel(slevels)
        valid = superstages == slevels(slid);
        validIds = find(valid);
        nValid = numel(validIds);
        [~, idx] = sort(order(validIds));
        switch settings.binningMode
            case 'Percentage, Back to Back, Partial Final Stage'
                frac = binSize;
                assert(frac >= 0 & frac <= 1);
                stageSize = nValid*frac;
                n = round(1/frac);
               
                w0 = 0;
                for wid = 1:n
                    i1 = floor(w0+1);
                    i2 = floor(w0+stageSize);
                    out_stageVar(validIds(idx(i1:min(end,i2)))) = wid + stageCount;
                    out_idxInStage(validIds(idx(i1:min(end,i2)))) = 1:numel(validIds(idx(i1:min(end,i2))));
                    out_stageInSuperstage(validIds(idx(i1:min(end, i2)))) = wid;
                    w0 = w0 + stageSize;
                end
                
                stageCount = nanmax(out_stageVar(validIds(idx)));
                
            case 'Percentage, Spaced'
                frac = binSize;
                assert(frac >= 0 & frac <= 1);
                stageSize = floor(nValid*frac);
                n = round(1/frac);
                step = floor((nValid - n*stageSize)/(n-1));
                
                w0 = 0;
                for wid = 1:n
                    out_stageVar(validIds(idx(w0+1:w0+stageSize))) = wid + stageCount;
                    out_idxInStage(validIds(idx(w0+1:w0+stageSize))) = 1:numel(validIds(idx(w0+1:w0+stageSize)));
                    out_stageInSuperstage(validIds(idx(w0+1:w0+stageSize))) = wid;
                    w0 = w0 + stageSize + step;
                end
                
                stageCount = nanmax(out_stageVar(validIds(idx)));
                
                
            case 'Fixed Size, Back to Back, Partial Final Stage'
                
                out_stageVar(validIds(idx)) = floor((1:numel(validIds)) / binSize) + stageCount + 1;
                out_idxInStage(validIds(idx)) = 1:numel(validIds(idx));
                out_stageInSuperstage(validIds(idx)) = floor((1:numel(validIds)) / binSize) + 1;
                stageCount = nanmax(out_stageVar(validIds(idx)));
                
            case 'Fixed Size, Spaced'
                
                n = min(settings.maxBinsPerOrderingLevel, floor(nValid/binSize));
                step = floor((nValid - n*binSize)/(n-1));
                
                w0 = 0;
                for wid = 1:n
                    out_stageVar(validIds(idx(w0+1:w0+binSize))) = wid + stageCount;
                    out_idxInStage(validIds(idx(w0+1:w0+binSize))) = 1:numel(validIds(idx(w0+1:w0+binSize)));
                    out_stageInSuperstage(validIds(idx(w0+1:w0+binSize))) = wid;
                    w0 = w0 + binSize + step;
                end
                stageCount = nanmax(out_stageVar(validIds(idx)));
        end
        
        if isnan(stageCount)
            stageCount = 0;
        end
        
    end
    
    stageVar_ = NaN(numel(pf), 1);
    stageVar_(pfids) = out_stageVar;
    stageInSuperstage_ = NaN(numel(pf), 1);
    stageInSuperstage_(pfids) = out_stageInSuperstage; 
    idxInStage_ = NaN(numel(pf), 1);
    idxInStage_(pfids) = out_idxInStage;
    
    dataview.putProperty(settings.outputVar_idxGlobal, stageVar_, dspace_data.PropertyDefinition(...
        [], [], ['StageVariable_' settings.orderingVariable '_' settings.groupingVariable], '', settings));
    dataview.putProperty(settings.outputVar_idxInGroup, stageInSuperstage_, dspace_data.PropertyDefinition(...
        [], [], ['StageVariable_' settings.orderingVariable '_' settings.groupingVariable], '', settings));
    dataview.putProperty(settings.outputVar_idxGlobal, idxInStage_, dspace_data.PropertyDefinition(...
        [], [], ['StageVariable_' settings.outputVar_idxInBin '_' settings.groupingVariable], '', settings));
    
    results.settings = settings;
    
end