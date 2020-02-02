classdef About_Dataspace
    % Dataspace (short: dspace) is a set of data structures, analysis functions and a graphical user interface intended to facilitate data analysis in various fields of science.
    %
    % Copyright (C) 2020 University Zurich, Sepp Kollmorgen 
    %
    % This program is distributed in the hope that it will be useful, but WITHOUT 
    % ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
    % FOR A PARTICULAR PURPOSE.
    %
    %
    % <b>Dataspace</b> consists of two parts: 1) the 'dspace-core' and 2) the 'dspace-GUI'. 
    % 
    % <b>dspace-core</b> The dspace-core is necessary and sufficient to handle data and
    % execute datascience analysis workflows. It includes the dataspace
    % data-structures and analysis module functions. dspace-core is
    % licensed via the GNU AFFERO GENERAL PUBLIC LICENSE (see included file LICENSE).
    %
    % <b>dspace-GUI</b> The dspace-GUI is a graphical user interface for data exploration and GUI-based
    % design of new analysis workflows. dpsace-GUI is licenced under a custom license
    % that allows free use for research (see included file LICENSE).
    %
    % <b>Overview of Folders Included</b>:
    % <PRE> 
    % Tutorials/                      Tutorials, Example Scripts                     dspace-core
    % ModuleFunctions/                Factory and User-Defined Module Functions      dspace-core
    % App/                            App-internals                                  dspace-GUI
    % App_Settings/
    % Extras/ExtremeLogger/           Logging Functionionality                       dspace-GUI
    % Extras/ThirdPartyComponents/
    % +dspace_graphs/                 Package: Main Structures for Graphs            dspace-core
    % +dspace_features/               Package: Main Structures for Features          dspace-core
    % +dspace_data/                   Package: Main Structures for Data and Labels   dspace-core
    % +dspace/                        Package: Basic Functions                       dspace-core
    % LICENSE
    % README.md                       This file
    % dspace_examples.m               Script: Various Usage examples                 dspace-core
    % dspace.m                        Function: Data-Import, Start GUI               dspace-core
    % </PRE>
    %
    % 
    % <u>Concept, Design, and Development</u>: Sepp Kollmorgen
    %
    % <u>Testing and Advise</u>: Ioana Calangiu, Valerio Mante, Rudina Morina, Viktoria Obermann
    % 
    % <u>Additional Testing</u>: Renate Krause, Aniruddh Galgali, Victoria Shavina 
    %
    %
    % <b>Dataspace on Github</b>: <a href="matlab:web('https://github.com/skollmor/dspace', '-browser')">https://github.com/skollmor/dspace</a> 
    % <div style="text-align:center"> 
    % <PRE> 
    %  <a href="matlab:dspace.help('dspace.resources.docs.Introduction_to_Dataspace')">Introduction to Dataspace</a>         <a href="matlab:doc('dspace')">dspace()</a> 
    %       __       ___       __   __        __   __       
    %      |  \  /\   |   /\  /__` |__)  /\  /  ` |__       
    %      |__/ /~~\  |  /~~\ .__/ |    /~~\ \__, |___  v1.3
    %                
    % Copyright (C) 2020 University Zurich, Sepp Kollmorgen 
    % </PRE></div>

end