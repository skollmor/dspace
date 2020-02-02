    % This example recreates the MNIST datasource from 
    % http://yann.lecun.com/exdb/mnist/
    %
    % You can load a subsampled version (10k images) from the folder /Tutorials/MNIST_Datasource
    % (for instance using the dataspace GUI).
    %
    % XXXNAT TODO: test
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


%% Load MNIST data
% To recreate the datasource, first obtain the mnist dataset: http://yann.lecun.com/exdb/mnist/
% then unpack archives using (in matlab)
% gunzip('*.gz');

images_tr = loadMNISTImages('train-images-idx3-ubyte');
labels_tr = loadMNISTLabels('train-labels-idx1-ubyte');

images_te = loadMNISTImages('t10k-images-idx3-ubyte');
labels_te = loadMNISTLabels('t10k-labels-idx1-ubyte');

%% Create datasource
% The datasource will have one datapoint for each image from the mnist dataset 
% each datapoint has a couple of associated properties such as label (which digit) and whether 
% it is part of the test set as well as a vector representation containing the image itself.
% In dataspace, properties are referred to as variables and stored in a table. Coordinates 
% are stored as special objects (instances of descendants of the Coordinate.m class).


% 1. Create table of labels (columns: labels, rows: datapoints)
T = table();
T.idx = NaN(70000, 1);
T.label = NaN(70000, 1);
T.is_test_set = zeros(70000, 1);

T.idx = (1:70000)';
T.label(1:60000) = labels_tr;
T.label(60001:70000) = labels_te;
T.is_test_set(60001:70000) = 1;

% 2. Create Coordinates holding the images
% First argument is a matrix with datapoint it its rows and dimension
% across columns (the images are reshaped to be 784x1 each and stored in
% the rows of images_tr and images_te)
imgF = dspace_features.StandardFeatures([images_tr' ; images_te'], 'Raw MNIST Images',...
    dspace_features.FeatureLayout([28, 28], [min(images_tr(:)), max(images_tr(:))], 1:784, [28, 28]));

% 3. Create datasource
source = dspace(T); 
source.addFeatures(imgF); 

% 4. Only retain a subset (to save diskspace; 10k for the example)
% nth = 7;
% source.P = source.P(1:nth:end, :);
% source.C{1}.Xf = sparse(source.C{1}.Xf(1:nth:end, :));

% 5. Correct ordering for display purposes
for k = 1:size(source.F{1}.Xf, 1)
    tmp = reshape(source.F{1}.Xf(k, :), 28, 28);
    tmp = tmp(end:-1:1, :);
    source.F{1}.Xf(k, :) = reshape(tmp, 1, []);
end
source.Name = 'MNIST Dataset';

% Display source in dataspace
dspace(source);
%dspace.modules{4}.setColormap('cubehelix-A');
