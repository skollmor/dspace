function [ titleStr, settings, results ] = createSequenceVariable( dataview, settings )
    % This function creates a sequence-variable. A sequence variable assigns 
    % a successor to each datapoint (the next datapoint in the sequence).
    %
    % Typically sequences are used to connect datapoints with their sequence 
    % successors through lines in the scatter-tool (see image below). Sequences can
    % also be used to transform other variables using the 'Apply Sequence-Transform' 
    % module-function.
    % 
    % The order within a sequence is defined by the sequence ordering variable.
    % The successor for each datapoint is its kth (k < 0 possible) 
    % neighbour in the sequence order variable where points violating the 
    % conditions below (see 'Defining Constraints') are excluded and only points 
    % inside the current filter are considered.
    % 
    % DSPACE-HELP-IMAGE<linkLineExample.png>
    % <h4>Defining Contraints - Grouping variables</h4>
    % If 'grouping variables' is chosen as the contraint type, only datapoints within
    % the same grouping-bin, which is any combination of unique values of all grouping 
    % variables, can be connected. Links across grouping-bins are not generated.
    % <h4>Defining Contraints - Posthoc-condition</h4>
    % If 'posthoc-condition' is chosen as the contraint type, only datapoint 
    % pairs that fulfill the provided constraint are connected. The constraint 
    % is given as a matlab expressions that returns a logical vector. Like point filers 
    % expression, they can use the table 
    %
    % >> P 
    %
    % containing the properties of the datasource as well as the index lists
    %
    % >> sources, targets
    %
    % containing indices of point pairs to be linked (source->target).
    % For instance, to only connect neighboring points that are close wrt. to the 
    % value of variable 't':
    %
    % >> abs(P.t(sources) - P.t(targets)) < 1 
    %
    % <h4>Treatment of NaNs</h4>
    % Any datapoints that have NaN values in the ordering variable or any of the 
    % binning variables are ignored.
    % <h4>Examples</h4>
    % A sequence variable can be used to connect each measurement within a trial
    % to the next measurement (with respect to time) within the same trial. Using 
    % the sequence variable trials can be visualized as connected curves in the scatter-display.
    %
    % A datasource contains x and y coordinates for eye-traces measured using an
    % eye-tracker. A sequence variable can connect datapoints representing successive gaze
    % locations. Using the sequence variable the eye traces can be visualized as
    % connected curves in the scatter display.
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

    
    titleStr = 'Essentials/Create Sequence Label';
        
    if nargin == 0
        % Function was called with 0 inputs: 
        % -- Only need to define the title (which we did already above)   
        return
    elseif nargin == 1 || (nargin == 2 && isempty(settings))
        % Function was called with 1 input or 2 inputs where the second is empty:
        % -- Only define default settings --
        varNames = dataview.getPropertyNames();
        pf = dataview.getPointFilter();
        settings = {'Description' , sprintf('Create Sequence Variable (%i points in current filter).', sum(pf)),...
            'WindowWidth', 600, 'ControlWidth', 420,...
            {'Sequence ordering variable', 'sequenceVariable'}, permuteStringOptions(varNames, dataview.SequenceName),...
            'k', 1,...
            {'Contraint type', 'groupingType'}, {'Grouping variables', 'Posthoc condition'},...
            {'Grouping variables', 'groupingVars'}, dspace.app.StringList(varNames),...
            {'Posthoc-vondition', 'condition'}, 'abs(P.t(sources)-P.t(targets)) < 1',...
            {'New variable name', 'varstem'}, 'Sequence'};
        return;
    end
    
    source = dataview.getDatasource();
    pf = dataview.getPointFilter();
    
    if strcmp(settings.groupingType, 'Grouping variables')
        groupingVars = settings.groupingVars.strings;
        splitLevels = {};
        pf2 = pf;
        for k = 1:numel(groupingVars)
            if any(isnan(source.P.(groupingVars{k})(pf)))
                pf2 = pf & ~isnan(source.P.(groupingVars{k})(pf));
                fprintf('dspacefcns.Essentials.createSequenceVariable: %i pts have NaN values in grouping variable %s.\n',...
                    sum(pf)-sum(pf2), groupingVars{k});
            end 
            splitLevels{end+1} = unique(source.P.(groupingVars{k})(pf2))';
        end
        if isempty(splitLevels)
            splits = NaN;
        else
            splits = combvec(splitLevels{:});
        end
        linkedElements = NaN(source.N, 1);
        for splitId = 1:size(splits, 2)
            pfsplit = pf;
            if ~isempty(splitLevels)
                for kk = 1:numel(groupingVars)
                    pfsplit = pfsplit & source.P.(groupingVars{kk}) == splits(kk, splitId);
                end
            else
                pfsplit = pf;
            end
            
            pfsplit_ids = reshape(find(pfsplit), [], 1);
            
            sv = source.P.(settings.sequenceVariable)(pfsplit);
            [~, order] = sort(sv);
            linkedElements(pfsplit) = [pfsplit_ids(order(2:end)); NaN];
        end
        dataview.putProperty(sprintf('%s%s', settings.varstem, settings.sequenceVariable),...
                double(linkedElements), dspace_data.PropertyDefinition([], [], sprintf('%s%s', settings.varstem, settings.sequenceVariable),...
                dspace_data.PropertyDefinition.UNIT_SEQUENCE_INDEX, []));
        
    elseif strcmp(settings.groupingType, 'Posthoc condition')
        %% Compute
        sv = dataview.getPropertyValues(settings.sequenceVariable);
        %fprintf('createSequenceVariable: Using sequence variable %s...\n', settings.sequenceVariable);
        [~, order] = sort(sv);
        invOrder(order) = 1:numel(sv);
        linkedElements = NaN(1, numel(sv));
        if settings.k == 0
            % every element points to itself
            newSequence = 1:numel(sv);
        elseif settings.k < 0
            soids = invOrder - settings.k;
            valid = soids > 0;
            linkedElements(valid) = order(soids(valid));
        elseif settings.k > 0
            soids = invOrder + settings.k;
            valid = soids <= numel(sv);
            linkedElements(valid) = order(soids(valid));
        end
        
        % remove links from points outside the point filter
        % (but links that target outside the point filter)
        linkedElements(~pf) = NaN;
        
        if ~isempty(settings.condition)
            % remove links that violate the condition
            valid = ~isnan(linkedElements);
            
            sources = find(valid);
            targets = linkedElements(valid);
            P = dataview.getAllProperties();
            
            fullCommand = [settings.condition ';'];
            valid2 = eval(fullCommand);
            
            linkedElements(sources(~valid2)) = NaN;
        end
        
        dataview.putProperty(sprintf('%s%s', settings.varstem, settings.sequenceVariable),...
            double(linkedElements'), dspace_data.PropertyDefinition([], [], sprintf('%s%s', settings.varstem, settings.sequenceVariable),...
            dspace_data.PropertyDefinition.UNIT_SEQUENCE_INDEX, []));
    else
        assert(false);
    end
    results = [];
    
end

function stringCell = permuteStringOptions(options, primary)
    if isempty(primary)
        stringCell = options;
        return
    end
    idx = find(strcmp(options, primary), 1);
    stringCell = [options(idx), options([1:idx-1 idx+1:end])];
end