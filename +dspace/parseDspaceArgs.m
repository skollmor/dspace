function source = parseDspaceArgs(dataArgs, inputNames, idxOfFirstArgument)
    % Internal function used by dspace().
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

    
    assert(numel(dataArgs) > 0);
    assert(numel(dataArgs) == numel(inputNames));
    assert(idxOfFirstArgument <= numel(dataArgs));
    
    matrixData = {};
    matrixNames = {};
    matrixArgId = [];
    countMatrixData = 0;
    
    categoricalData = {};
    categoricalDataNames = {};
    categoricalDataArgId = [];
    countCategoricalData = 0;
    source_name = 'New source';
    for k = 1:numel(dataArgs)
        
        arg = dataArgs{k};
        
        if istable(arg)
            source_name = inputNames{k};
            T = arg;
            for varidx = 1:numel(T.Properties.VariableNames)
                name = T.Properties.VariableNames{varidx};
                M = T.(name);
                if isnumeric(M)
                    matrixData{1, countMatrixData+1} = M; %#ok<*AGROW>
                    rowCount(1, countMatrixData+1) = size(M, 1);
                    matrixNames{1, countMatrixData+1} = name;
                    matrixArgId(1, countMatrixData+1) = k-1+idxOfFirstArgument;
                    countMatrixData = countMatrixData + 1;
                elseif iscell(M)
                    % categorical
                    categoricalData{1, countCategoricalData+1} = M;
                    categoricalDataNames{1, countCategoricalData+1} = name;
                    categoricalDataArgId(1, countCategoricalData+1) = k-1+idxOfFirstArgument;
                    countCategoricalData = countCategoricalData + 1;
                else
                    warning('dspace: could not parse table colum (%s) in input %i; column ignored.\n',...
                        name, k-1+idxOfFirstArgument);
                end
            end   
        elseif isnumeric(arg)
            % vectors and matrices
            matrixData{1, countMatrixData+1} = arg;
            rowCount(1, countMatrixData+1) = size(arg, 1); 
            % fetch name of ith input argument
            matrixNames{1, countMatrixData+1} = inputNames{k};
            matrixArgId(1, countMatrixData+1) = k-1+idxOfFirstArgument;
            countMatrixData = countMatrixData + 1;
        elseif iscell(arg)
            % allow coordinates defined as cell arrays of numerical vectors
            % of constant dimension
            if all(cellfun(@(e) isnumeric(e), arg(:)))
                unl = unique(cellfun(@(e) numel(e), arg(:)));
                udims = unique(cellfun(@(e) numel(size(e)), arg(:)));
                if numel(unl) ~= 1 || numel(udims) ~= 1 || ~ismember(udims, [1, 2]) 
                    warning('dspace: could not parse input %i (%s); input is a cell array with numeric elements but they don''t have fixed size (1xD or D1xD2); input ignored.\n',...
                        k-1+idxOfFirstArgument, inputNames{k});
                    continue
                end
                matrixData{1, countMatrixData+1} = arg;
                rowCount(1, countMatrixData+1) = size(arg, 1); 
                % fetch name of ith input argument
                matrixNames{1, countMatrixData+1} = inputNames{k};
                matrixArgId(1, countMatrixData+1) = k-1+idxOfFirstArgument;
                countMatrixData = countMatrixData + 1;
            else
                %if all(cellfun(@(e) isstring(e) || ischar(e) || iscategorical(e), arg(:)))
            
                % categorical vectors (e.g. string labels)
                categoricalData{1, countCategoricalData+1} = arg;
                categoricalDataNames{1, countCategoricalData+1} = inputNames{k};
                categoricalDataArgId(1, countCategoricalData+1) = k-1+idxOfFirstArgument;
                countCategoricalData = countCategoricalData + 1;
            end
        else
            warning('dspace: could not parse input %i (%s); input ignored.\n',...
                        k-1+idxOfFirstArgument, inputNames{k});
        end
        
    end
    
    N = mode(rowCount);
    fprintf('dspace(): %i matrix/vector inputs; %i categorical inputs; %i datapoints; creating datasource...\n', countMatrixData, countCategoricalData, N);
    
    source = dspace_data.TableDataSource(source_name);    
    source.P.idx = (1:N)';
    
    % Process numeric input data
    for k = 1:countMatrixData
        if size(matrixData{k}, 1) ~= N
            warning('dspace: input %i (%s) has %i rows instead of %i (number of datapoints); input ignored.\n',...
                matrixArgId(k), matrixNames{k}, size(matrixData{k}, 1), N);
            continue
        end 
        if isnumeric(matrixData{k})
            if size(matrixData{k}, 2) == 1
                source.P.(matrixNames{k}) = matrixData{k};
            else
                sz = size(matrixData{k});
                if numel(sz) == 2
                    % layout as row vectors
                    layout = dspace_features.FeatureLayout([1, sz(2)], [], 1:sz(2), [1, sz(2)]);
                    X = matrixData{k};
                elseif numel(sz) == 3
                    % layout as matrices
                    layout = dspace_features.FeatureLayout([sz(2), sz(3)], [], 1:sz(2)*sz(3), [sz(2), sz(3)]);
                    X = zeros(N, sz(2)*sz(3), 'single');
                    for jj = 1:N
                        X(jj, :) = reshape(squeeze(matrixData{k}(jj, end:-1:1, :)), 1, sz(2)*sz(3)); 
                    end
                    % matrixData{k} = reshape(permute(matrixData{k}, [3, 1, 2]), [sz(2)*sz(3), N])';
                    % X = matrixData{k};
                else
                    warning('dspace: input %i (%s) is neither a NxD nor a NxD1xD2 matrix (N = %i, number of datapoints); input ignored.\n',...
                        matrixArgId(k), matrixNames{k}, N);
                    continue;
                end
                % Create Coordinates
                C = dspace_features.StandardFeatures(X, matrixNames{k}, layout);
                source.addFeatures(C);
            end
        elseif iscell(matrixData{k})
            dim1 = unique(cellfun(@(e) size(e, 1), matrixData{k}));
            dim2 = unique(cellfun(@(e) size(e, 2), matrixData{k}));
            if numel(dim1) ~= 1 || numel(dim2) ~= 1
                warning('dspace: input %i (%s) is a cell array but contains neither all 1xD nor a D1xD2 matrices; input ignored.\n',...
                    matrixArgId(k), matrixNames{k});
                continue;
            end
            X = zeros(N, dim1*dim2, 'single');
            for jj = 1:N
                X(jj, :) = reshape(matrixData{k}{jj}(end:-1:1, :), 1, dim1*dim2);
            end
            layout = dspace_features.FeatureLayout([dim1, dim2], [], 1:dim1*dim2, [dim1, dim2]);
            C = dspace_features.StandardFeatures(X, matrixNames{k}, layout);
            source.addFeatures(C);
        else
            assert(false);
        end
    end
    
    % Process categorical input data
    for k = 1:countCategoricalData
        if iscell(categoricalData{k})
            if size(categoricalData{k}, 1) ~= N
                warning('dspace: input %i (%s) has %i rows instead of %i (number of datapoints); input ignored.\n',...
                    categoricalDataArgId(k), categoricalDataNames{k}, size(categoricalData{k}, 1), N);
                continue
            end
            if numel(categoricalData{k}) ~= N
                warning('dspace: input %i (%s) must be a column vector (Nx1) (N = %i, number of datapoints); input ignored.\n',...
                    categoricalDataArgId(k), categoricalDataNames{k}, N);
                continue
            end
            
            [categories, ~, categoryIds] = unique(categoricalData{k});
            source.Pdef.(categoricalDataNames{k}) = dspace_data.PropertyDefinition(...
                1:numel(categories), categories, [], [], []);
            source.P.(categoricalDataNames{k}) = categoryIds;
        else
            assert(false);
        end
    end
end
