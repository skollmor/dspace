classdef Introduction_to_Dataspace
    % Dataspace (short: dspace) is a set of data structures, analysis functions and 
    % a graphical user interface intended to facilitate data analysis in various 
    % fields of science. 
    %  
    % Dataspace is build with practical application in mind - to be 
    % as simple as possible while still being comprehensive enough for most data-science
    % workflows. 
    % Dataspace combines a powerful GUI with a code-based workflow
    % that offers total control and facilitates code reusability and transparency. Dataspace 
    % enables users to perform many analyses tasks
    % without writing any code at all. At the same time Dataspace is designed to not limit
    % the expert programmer but to supplement and improve their workflow.
    %
    %
    % DSPACE-HELP-IMAGE<FullApp.png>
    %
    % <H3>Datasources and Data-collections</H3>
    % Dataspace handles all data as '<b>datasources</b>', which are grouped in '<b>data-collections</b>'. A datasource may
    % for instance hold the observations of one experiment while a collection may hold
    % an entire series of such experiments. 
    % 
    % A datasource can hold four main types of data: <i>Labels, Features, Graphs, and Actions</i>.
    % <PRE>
    %  #  age    gender       test_result      | Feature: Cardiogram  | Graph: Relatives 
    %  _  ___    ______    __________________  |                      |
    %  1  40       F       -0.681559682509183  |   1 x 10000 double   |    3, 58, 84
    %  2  31       M       -0.260139430391064  |   1 x 10000 double   |    45, 59, 81
    %  3  41       F       -0.228795364308812  |   1 x 10000 double   |    1, 58, 84
    %  ... 
    % [----------------Labels-----------------] [------Features------] [-----Graphs-----]</PRE> 
    % <i>Example</i>: Datapoints (rows) represent hypothetical patients. A feature 'cardiogram' 
    % holds hypothetical scalar measurements for 10000 timepoints for each patient. A graph
    % 'Relatives' holds the IDs of related patients also included in the dataset.
    %
    % Datasources are typically instances of the class <a href="matlab:doc('dspace_data.TableDataSource')">dspace_data.TableDataSource</a>.
    % 
    % Data-collections are instances of the class <a href="matlab:doc('dspace_data.DataCollection')">dspace_data.DataCollection</a>.
    % 
    % The <i>easiest way</i> to create datasources and data-collections is 
    % to use the function <a href="matlab:doc('dspace')">dspace()</a>.
    %
    % <b>Labels.</b>
    % Labels can be continuous or categorical. They are stored as columns in
    % a Matlab <a href="matlab:doc('table')">table</a>.
    %
    % Additional information regarding labels can be stored in the dedicated type
    % <a href="matlab:doc('dspace_data.PropertyDefinition')">dspace_data.PropertyDefinition</a>.
    %
    % <b>Features.</b>
    % Features encapsulate richer data, such as video frames, neural activity patterns,
    % images, sound-segments, etc. Features are stored and handled by 
    % dedicated feature-objects that are derived from the class 
    % <a href="matlab:doc('dspace_features.AbstractFeatures')">dspace_features.AbstractFeatures</a>.
    %
    % Dataspace supports hierarchies of features - one feature is expressed 
    % as a transformation of one or more other features - and on-demand-computation - 
    % features are computed dynamically when needed. Note that you can generate features 
    % automatically from standard Matlab data using the convenient function 
    % <a href="matlab:doc('dspace')">dspace()</a>. 
    % 
    % <b>Graphs.</b>
    % Relationships between datapoints can be expressed through graphs. In Dataspace
    % graphs are represented by dedicated graph-objects. Graphs are derived from the class 
    % <a href="matlab:dspace.help('dspace_graphs.AbstractGraph')">dspace_graphs.AbstractGraph</a>.
    %
    % <b>Actions.</b>
    % Dataspace keeps a log of actions that create or transform data. It can automatically
    % produce code to reproduce the actions performed, including parameters. To facilitate code
    % reusability actions are specified as '<b>module-functions</b>'. Existing Matlab 
    % workflows can be wrapped in module-functions with minimal effort (see below).
    % 
    % <H2 id="MNIST">Working with the Dataspace-App: MNIST Example</H3>
    % The Dataspace-App (dspace-GUI) has just a few components to control which dataset is loaded 
    % and how it is processed and displayed. Before we look at them in detail, 
    % we consider an example: the MNIST dataset of
    % handwritten digits. 
    %
    % Unless the Dataspace GUI is active, start it using
    %
    % >> dspace();
    %
    % A part of the MNIST dataset (10k digits) is included with Dataspace
    % as a Data-Collection. Select 'Load Collection' in the data selector
    % and load the dataset from the main dataspace folder:
    %
    % >> dataspace-root/Tutorials/MNIST_Datasource/mnist10k.dataCollection
    %
    % In this example, PCA and a t-SNE embedding have already been computed. 
    % Use the Scatter-Tool and Feature-Viewer to visualize them.
    %
    % DSPACE-HELP-VIDEO<mnist_all_v2_part1>
    %
    % For data that can be visualized as images, such as the MNIST digits, the 
    % overlay can be useful:
    %
    % DSPACE-HELP-VIDEO<mnist_all_v2_part2>
    %
    % We can study the local structure of the MNIST dataset focusing on one
    % digit at a time using the Filter-tool, that we link to one of the 
    % controllers:
    %
    % DSPACE-HELP-VIDEO<mnist_all_v2_part3>
    %
    % You can directly compute analyses in Dataspace. Below we compute principal 
    % components. Implementing your own analysis so they can be launched in the same
    % way is straight forward (see below, 'Module-Functions').
    %
    % <h4>Computing PCA and t-SNE</h4> 
    %
    % DSPACE-HELP-VIDEO<mnist_all_v2_part4>
    %
    % Or type 'Principal' in the Action-Selector, select 'Principal Component Analysis' 
    % and click the launch-button. Use the '..?' button to obtain help on the various 
    % parameters. 
    %
    % To compute the t-SNE representation use the dataspace-function 
    % Essentials/Features/Embed Features using t-SNE.
    %
    % Exploring graphs over datasets, such as nearest neighbour graphs can be useful.
    % Below we use the Scatter-Tool and Feature-Viewer to visualize the local neighbourhoods
    % (high dimensional k-NN) of datapoints of the mnist dataset.
    %
    % DSPACE-HELP-VIDEO<mnist_all_v3_part5_v2>
    %
    % <H2 id="ScriptBasedWorkflow">Working using Scripts</H2>
    % Sometimes it is useful to run scripts or code snippets on data loaded
    % in the Dataspace-app. This is very easy since the currently loaded datasource 
    % is available on the MATLAB command line (unless disabled) as the global variable
    %
    % >> dsource
    %  
    % Likewise, the current dataview (which holds information on selected properties
    % etc.) is available as the global variable
    %
    % >> dview
    %
    % The Dataspace-App instance itself (holds all loaded datasources etc.)
    % is available in the Matlab (base) workspace as 
    %
    % >> dspaceApp
    %
    % The global variable dspaceApp provides access to the Dataspace app.
    % 
    % To gain access to the parent collection of a datasource, you can use:
    %
    % >> dsource.parentCollection 
    % 
    % A useful commands to get a textual overview of a datasource is
    %
    % >> dsource.info()
    %
    % which produces output like:
    %
    % <PRE>
    % ----- MNIST 10k -----
    % #Pts: 10000; UID: Tutorials/MNIST Example Source
    %             ------- LABELS (8):
    %                         8 Label(s) in .L     :   0.001 gb
    %  6 Label Property Definition(s) in .Ldef     :   0.000 gb
    %             ----- FEATURES (2):
    %                         Raw MNIST Images ( 1):   0.022 gb    (dspace_features.StandardFeatures)
    %      pca_Raw MNIST Images_reconstruction ( 2):   0.002 gb    (dspace_features.LinearDerivedFeatures)
    %             ------- GRPAHS (2):
    %                      E_d100_p30_bhLocals ( 1):   0.007 gb    (dspace_graphs.PrecomputedGraph)
    %                        E_d100_p30_2D_NNs ( 2):   0.000 gb    (dspace_graphs.RealtimeLabelNNGraph)
    %             ------- OTHERS (1):
    %                                 .various     :   0.000 gb
    %              ----- ACTIONS (4):
    %                         Essentials/Features/Embed Features using t-SNE ( 1):   0.003 mb
    %                       Essentials/Features/Principal Component Analysis ( 2):   0.009 mb
    %                           Essentials/Organize Datasource/Delete Graphs ( 3):   0.001 mb
    %           Essentials/Graphs/Create Nearest Neighbour Graph from Labels ( 4):   0.001 mb
    % TOTAL: 0.032 GB
    % </PRE>
    %
    % To display an overview of an entire data-collection you can use:
    % 
    % >> dsource.ParentCollection.info()
    %
    % You can load and save data-collections without involving the Dataspace-GUI. 
    % In that case you may need to add Dataspace's paths to the Matlab path without
    % starting the GUI or creating data (as the function dspace() does). You can use:
    %
    % >> dspace.start('-nogui')
    %
    % Loading, saving and processing is explained in several example scripts 
    % in the /Tutorials/scripts folder inside the dataspace main folder:
    %
    % 1. Loading and saving of data-collections: 
    %
    % <a href="matlab:edit('dspaceScript_loadAndSaveSources.m')">dspaceScript_loadAndSaveSources.m</a>.
    %
    % 2. Processing of data: 
    %
    % <a href="matlab:edit('dspaceScript_processLoadedSources.m')">dspaceScript_processLoadedSources.m</a>.
    %
    % 3. Datasource for the complete MNIST dataset (the 
    % dataset needs to be downloaded first): 
    %
    % <a href="matlab:edit('dspaceScript_createMnistSource.m')">dspaceScript_createMnistSource.m</a>.
    %
    % <H2 id="MNIST">Elements of the GUI</H2>
    % This chapter describes the components of the dataspace-app.
    % Depending on yout build of Dataspace they might appear visually different.
    %
    % <h4>The Data-Selector</h4>
    % DSPACE-HELP-IMAGE<ControlWnd_img1_v2.png>
    %
    % The left-most, long, selector allows you to select the current datasource
    % Clicking on the circle-symbol brings up a context menu that allows you to select 
    % which modules are visible, to change the current perspective (window layout),
    % to save and manage new persepectives, and to link Scatter-Tools and Binning-Tools
    % together such that their axes change in synchrony. 
    %
    % <h4>The Action-Selector</h4>
    % The Action-Selector allows to search and execute analysis operations  
    % called module-functions (see below).
    % 
    % DSPACE-HELP-IMAGE<ActionSelector_img1_v2.png>
    %
    % <a href="matlab:dspace.help('dspace.modules.ActionSelector')">The Action-Selector</a>
    %
    % Module-functions can also be launched from the main menu (e.g. 'Essentials').
    %
    % <h4>The Filter-Tool</h4>
    % The Filter-Tool allows to filter data using logical expressions.
    % 
    % DSPACE-HELP-IMAGE<PointFilterManager_img1_v2.png>
    % 
    % <a href="matlab:dspace.help('dspace.modules.PointFilterAndHighlightsManager_v2')">The Filter-Tool</a>
    %
    % <h4>The Dataview</h4>
    % The Dataview allows to share properties between modules 
    % (such as labels selected or graphs).
    % 
    % DSPACE-HELP-IMAGE<PropertyList_img1_v2.png>
    % 
    % <a href="matlab:dspace.help('dspace.modules.PropertyList')">The Dataview</a>
    % 
    % And finally, there are 3 components to view the data:
    % <h4>The Scatter-Tool</h4>
    % 
    % DSPACE-HELP-IMAGE<ScatterTool_img1_v2.png>
    %
    % <a href="matlab:dspace.help('dspace.modules.ScatterDisplay_v2')">The Scatter-Tool</a>
    %
    % <h4>The Feature-Viewer</h4>
    % The feature viewer visualizes features for the currently selected 
    % datapoints.
    %
    % DSPACE-HELP-IMAGE<CoordinateViewer_img1_v2.png>
    % 
    % <a href="matlab:dspace.help('dspace.modules.XfViewer')">The Feature-Viewer</a>
    %
    % <h4>The Binning-Tool</h4>
    % The binning module serves to compute histograms and conditional 
    % expectations.
    % 
    % DSPACE-HELP-IMAGE<BinningTool_img1_v2.png>
    % 
    % <a href="matlab:dspace.help('dspace.modules.BinningTool_v2')">The Binning-Tool</a>
    %
    % <h4>Module-Functions</h4>
    % Through module-functions you can perform a range of analyses in Dataspace. 
    % Module-functions can be searched and executed using the Action-Selector (see above).
    % You can also find them in the main menu (e.g. 'Essentials'). When you execute 
    % a module function inside the GUI, the 'launch-dialog' allows you to alter
    % settings and parameters of the module function and to execute it on one or several
    % datasources.
    %
    % DSPACE-HELP-IMAGE<moduleFunction_img1.png>
    %
    % You can see a complete list of all available module-functions by selecting
    % "..?/List of Installed Functions" in the main menu.
    % 
    % It is easy to write you own module functions (see below). They can be launched from 
    % inside the GUI in the same way.
    % 
    % <h4>Docking/Always on Top</h4>
    % All of these components can be minimized, docked and undocked via the
    % arrow buttons, and provide specific information and help via the ..?
    % button. When undocked, all modules can be fixed on top of all other windows 
    % via the triangle- and parallogram-button.
    % 
    % <H2 id="IMPORT">Importing Data</H2>
    % There are 3 ways to import data into Dataspace
    % 
    % <H4>1. Using the function dspace()</H4>
    % The easiest way to import data into Dataspace is to use the function
    % <a href="matlab:doc('dspace')">dspace()</a>.
    %
    % This function creates Dataspace datasources from standard Matlab data types.
    % Please look at its documentation and the examples provided therein.
    %
    % <H5>Example A</H5> 
    % <PRE>
    % % a. Creating a TableDataSource using the dspace() function:
    % imgs = randn(10000, 100, 100);                 % make random images
    % imgs = convn(imgs, ones(1, 10, 10), 'same');   % smooth the images (looks cool)
    % random_values = randn(10000, 1);               % create some random values
    % source = dspace(random_values, imgs);          % make TableDataSource 
    % source.name = "Example Random Data";           % name the source
    % % dspace(source); % start the Dataspace GUI
    % </PRE>
    % <H4>2. Using the GUI based import</H4>
    % If the Dataspace GUI is started, you can select Home/Import Data from
    % Matlab Workspace to import data already in the Matlab workspace. Only
    % data suitable for import (i.e. tables, vectors, matrices, and certain cell arrays) 
    % is displayed. 
    %
    % In order to import data from external files (e.g. tab or comma separated
    % tables), you need to load it into the Matlab workspace first. Select 
    % Home/Import Data into Matlab Workspace. This will start the Matlab import 
    % assistant (see <a href="https://au.mathworks.com/help/matlab/ref/importtool-app.html">Matlab Import Tool</a>). 
    %
    % Once you imported data to the Matlab workspace, select Home/Import Data from
    % Matlab Workspace.
    % 
    % <H4>3. Using the low-level interface</H4>
    % For maximum control and flexibility create datasources directly.
    % Consult the documentation of the main classes holding data:
    %
    % <a href="matlab:doc('dspace_data.TableDataSource')">dspace_data.TableDataSource</a>
    %
    % <a href="matlab:doc('dspace_features.AbstractFeatures')">dspace_features.AbstractFeatures</a>.
    %
    % <H5>Example B</H5> 
    % <PRE>
    % random_values = randn(10000, 1);                                 % create some random values
    % source = dspace_data.TableDataSource("Example Random Data");     % make TableDataSource 
    % source.L.random_values = random_values;                          % add variable
    % % dspace(source); % start the Dataspace GUI
    % </PRE>
    % <H2 id="MODULEFCNS">Writing Dataspace Module-Functions</H2>
    % In Dataspace most analyses are implemented as Module-Functions. Module-Functions
    % are stored in the ModuleFunctions folder in the Dataspace main-folder.
    %
    % Start writing new Module-Functions by making a copy of ModuleFunctions/dspace_moduleFcn_template.m
    % and then editing it appropriately (See also the comments in dspace_moduleFcn_template.m).
    %
    % <a href="matlab:edit dspace_moduleFcn_template">dspace_moduleFcn_template.m</a>
    %
    % After you have created a new module function you have to save the .m function 
    % in the folder: 
    %
    % >> ModuleFunctions/AUTO-INCLUDE 
    %
    % so Dataspace can find it. You can also add your new function to the 
    % dspace_moduleFunction_inclusionList_std.m file.
    %
    % <H2 id="TROUBLESHOOTING">Trouble-Shooting</H2>
    % In case something goes wrong inside the Dataspace-GUI and 
    % the GUI starts behaving strangely, you can try restarting Dataspace using
    %
    % >> dspaceApp.restart();
    %
    % Alternatively you can also open a new instance of Dataspace on the currently 
    % loaded data using 
    %
    % >> dspace(dsource.ParentCollection);
    %
    % This will overwrite the workspace variables dspaceApp, dview,
    % and dsource. It will not close old Dataspace instances.
    %
    % If some windows won't close you can use the Matlab command
    %
    % >> close all force
    %
    % Afterwards you can restart dspace using either dspaceApp.restart() or 
    % dspace(dsource.ParentCollection).
    % 
    % <div style="text-align:center"> 
    % <PRE> 
    %   <a href="matlab:web('https://github.com/skollmor/dspace', '-browser')">Dataspace on Github</a>               <a href="matlab:doc('dspace')">dspace()</a>    
    %       __       ___       __   __        __   __       
    %      |  \  /\   |   /\  /__` |__)  /\  /  ` |__       
    %      |__/ /~~\  |  /~~\ .__/ |    /~~\ \__, |___  v1.3
    %                
    % Copyright (C) 2020 University Zurich, Sepp Kollmorgen 
    % </PRE></div>
end

