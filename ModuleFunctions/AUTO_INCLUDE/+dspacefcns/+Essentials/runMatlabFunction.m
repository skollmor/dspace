function [ titleStr, settings, results ] = runMatlabFunction( dataview, settings )
    % Run matlab commands on the current datasource. The matlab commands have 
    % to be specified as a one or several matlab expressions that may use the variables:
    % 
    % >> dsource
    %
    % >> dview
    %
    % >> pf        
    %
    % Where pf is the current filter (evaluated on the current source)
    % as a logical vector. If run in batch mode, dsource, dview and pf will 
    % refer to the datasource currently being processed. Make sure that none 
    % of the expressions override dsource, dview or pf. Multiple expressions are
    % executed in sequence.
    %
    % Note that dsource.parentCollection.sources.main{j} always gives you access 
    % to the jth datasource on level <main> of your collection. This is used in the 
    % following example:
    % <h4>Example: Copying a variable to multiple sources</h4>
    % >> dsource.P.someVariable = dsource.parentCollection.sources.main{1}.P.someVariable 
    % 
    % If run in batch mode, this command would copy a variable ('someVariable') 
    % from the 1st source on level <main> to all the sources selected for batching.
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


    titleStr = 'Essentials/Run Matlab Commands';
    
    if nargin == 0
        % Function was called with 0 inputs: 
        % -- Only need to define the title (which we did already above)   
        return
    elseif nargin == 1 || (nargin == 2 && isempty(settings))
        % Function was called with 1 input or 2 inputs where the second is empty:
        % -- Only define default settings --
        if nargin < 2 || isempty(settings)
            settings = {'Description' , 'Run matlab commands on datasource (commands are run in sequence).',...
                'WindowWidth', 700, 'ControlWidth', 550,...
                {'Expr1', 'matlabExpression1'},...
                    'dsource.P(1, :)',...
                {'Expr2', 'matlabExpression2'}, '',...
                {'Expr3', 'matlabExpression3'}, ''};
            return;
        end
    end
    
    protected_settings____ = settings;
    protected_titleStr____ = titleStr;
    
    % Define dsource, dview and pf 
    dsource = dataview.dataSource;  
    dview = dataview;
    [pf, ~, pfContainer] = dataview.getPointFilter();
    
    % Run the three lines (if provided) in sequence. The workspace for the commands 
    % is the one inside this function.
    if ~isempty(protected_settings____.matlabExpression1)
        eval(protected_settings____.matlabExpression1);
    end
    if ~isempty(protected_settings____.matlabExpression2)
        eval(protected_settings____.matlabExpression2);
    end
    if ~isempty(protected_settings____.matlabExpression3)
        eval(protected_settings____.matlabExpression3);
    end
    
    titleStr = protected_titleStr____;
    results = [];
end

