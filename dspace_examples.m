% To get to know dataspace, selection "..?/Introduction to Dataspace" from 
% the main menu of the Dataspace-App or type in Matlab:
% dspace.help('dspace.resources.docs.Introduction_to_Dataspace')

%% IRIS Dataset
load fisheriris;
X = meas.';
Y = species;
irisData = table(X(1, :)', X(2, :)', X(3, :)', X(4, :)', Y, 'VariableNames',...
{'sepal_length_cm', 'sepal_width_cm', 'petal_length_cm', 'petal_width_cm',...
'target_label'});
irisFeatures = X';
dspace(irisData, irisFeatures);

%% Matlab's Synthetic Digit Dataset (requires neural network toolbox)
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos','nndatasets','DigitDataset');
imds = imageDatastore(digitDatasetPath,'IncludeSubfolders',true,'LabelSource','foldernames');
imgs = imds.readall();
labels = double(imds.Labels);
idx = (1:numel(labels))';
source = dspace(imgs, labels, idx);
source.name = 'Matlab Synthetic Digits Dataset';
dspace(source);

%% Random Smoothed Data
imgs = randn(10000, 100, 100);
imgs = convn(imgs, ones(1, 10, 10), 'same');
random_values = randn(10000, 1);
idx = (1:10000)';
dspace('unrelatedNumbers', random_values, 'Random Images', imgs, 'IndexVar', idx);

%% Random Smoothed Data - Cell Arrays
% Features could also be packed as cell array of dimension Nx1 of same size numeric matrices
% where N is the number of datapoints
imgs = randn(10000, 100, 100);
imgs = convn(imgs, ones(1, 10, 10), 'same');
random_values = randn(10000, 1);
idx = (1:10000)';
imgs_cell = arrayfun(@(i) squeeze(imgs(i, :, :)), (1:size(imgs, 1))', 'uni', false);
dspace('unrelatedNumbers', random_values, 'Random Images', imgs_cell, 'IndexVar', idx);


%% Random Data with Drift
nEpochs = 40;                                          % number of epochs (e.g. days)
nSubEpochs = 5;                                        % number of sub epochs  (e.g. periods in day)
%nSamples - 250;
nSamples = 1000;                                       % samples per subEpoch
dim = 150;
%dim = 25;                                              % data dimension
N = nEpochs * nSubEpochs * nSamples;                   % total number of datapoints
productionTime = (1:N)';                               % production time for each datapoint
epoch = ceil(productionTime/(nSubEpochs*nSamples));
subEpoch = floor(mod(productionTime-1, (nSubEpochs*nSamples))/nSamples) + 1;
data = randn(N, dim) + (1:N)'/N * 2;
dspace(data, epoch, subEpoch, productionTime);