function [ titlestr, settings, results ] = freezeFeatures( dataview, settings )
    % Transfixes the given coordinates for points in current pointfilter into
    % new hardcoded coordinates.
    %
    % Use this to cache coordinates.
    %
    % See also dspace_features.PartialStandardCoordinates.
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
        titlestr = 'Essentials/Features/Freeze to Standard Features';
        return;
    end
    
    [pf, ~, pfc] = dataview.getPointFilter();
    np = sum(pf);
    source = dataview.dataSource;
    ftNames = cellfun(@(x) x.getIdentifier(), source.coordinates, 'uni', false);
    
    titlestr = sprintf('Freeze features (%i points).', np);
    
    if nargin < 2 || isempty(settings)
        settings = {'Description', titlestr,...
            'WindowWidth', 500,...
            'ControlWidth', 250,...
            {'Features to Freeze', 'featureName'}, ftNames,...
            {'New Feature Name', 'newname'}, 'Frozen',...
            'separator', 'Advanced',...
            {'Use Feature Cutout', 'useCutout'}, false,...
            {'Recompute Feature Range', 'recomputeRange'}, false};
        return;
    end
    
    cid = find(strcmp(settings.featureName, ftNames), 1);
    parc = source.coordinates{cid};
    pLayout = source.coordinates{cid}.getLayout();
    
    pfIds = find(pf);
    np = numel(pf);
    
    if settings.useCutout
        nLayout = dspace_features.FeatureLayout(pLayout.cutoutDimension, pLayout.range,...
            1:numel(pLayout.cutoutIndices), pLayout.cutoutDimension);
        fprintf('Obtaining features %s...\n', parc.getIdentifier());
        X = parc.getDataMatrix(source, pfIds);
        ncoordinates = dspace_features.StandardFeatures(X(:, pLayout.cutoutIndices), pfIds, np, settings.newname, nLayout);
    else
        nLayout = pLayout.copy();
        
        fprintf('Obtaining features %s...\n', parc.getIdentifier());
        X = parc.getDataMatrix(source, pfIds);
        ncoordinates = dspace_features.StandardFeatures(X, pfIds, np, settings.newname, nLayout);
        %Xtest = ncoordinates.getDataMatrix(source, pfIds);
        %assert(isequaln(X, Xtest));
    end
    
    if settings.recomputeRange
        fprintf('Recomputing feature range...\n');
        range = prctile(X(1:13:end), [0.01, 99.99]);
        fprintf('Set layout.range to [%2.3f, %2.3f].\n', range(1), range(2));
        ncoordinates.layout.range = range;
    end
    
    cid_new = find(strcmp(ncoordinates.getIdentifier(), ftNames), 1);
    if ~isempty(cid_new)
        fprintf('Overwriting existing features %s in slot %i.\n', ncoordinates.getIdentifier(), cid_new);
        source.coordinates{cid_new} = ncoordinates;
        results.coordinateId = cid_new;
    else
        fprintf('Creating new features %s in slot %i.\n', ncoordinates.getIdentifier(), numel(source.coordinates) + 1);
        source.coordinates{end+1} = ncoordinates;
        results.coordinateId = numel(source.coordinates);
    end
    results.settings = settings;
    results.pfIds = pfIds;
    
end