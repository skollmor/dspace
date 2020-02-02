# Dataspace v. 1.3

**Dataspace (short: dspace) is a set of data structures, analysis functions and 
a graphical user interface intended to facilitate data analysis in various 
fields of science.**

![Dataspace for Zebra Finch Song Development](https://raw.githubusercontent.com/skollmor/dspace/master/App/Docs/+dspace/+resources/images/FullApp.png)

This version of Dataspace is released concurrently with the research paper:

*Kollmorgen, S., Hahnloser, R.H.R. & Mante, V. Nearest neighbours reveal fast and slow components of motor learning. Nature 577, 526-530 (2020). https://doi.org/10.1038/s41586-019-1892-x*

### How to Use Dataspace
Checkout (or copy) the dspace-repository to your local machine. In Matlab, run the function 
dspace() located in the main dataspace folder:
```
dspace();
```

To learn more, and access documentation and tutorials, type in Matlab:
``` 
doc dspace
```

A few quick examples that you can start with immediately are given in a script:
```
edit dspace_examples.m
```

# Why use Dataspace?
Dataspace is build with practical application in mind - to be as simple as possible 
while still being comprehensive enough for most data-science workflows. Dataspace 
combines a powerful GUI with a code-based workflow that offers total control and facilitates 
code reusability and transparency. Dataspace enables users to perform many analyses tasks
without writing any code at all. At the same time Dataspace is designed to not limit the expert 
programmer but to supplement and improve their workflow.

# Tested Environments
Dataspace is tested on: 
- Windows 8.1 and Windows 10 using Matlab versions 2018b-2019b
- macOS Mojave (Version 10.14.6) using Matlab 2019b (not yet optimized)
- Linux Ubuntu 16.04 LTS using Matlab 2018b (not yet optimized)

Dataspace makes use of the following Matlab toolboxes (the toolboxes need to be installed):
- distrib_computing_toolbox
- matlab
- statistics_toolbox

# Citations
Please cite the paper mentioned above if you use Dataspace.

# Folders
Dataspace comes in two parts: the **dspace-core** and the **dspace-GUI**. 

**dspace-core**: The dspace-core is necessary and sufficient to handle data and 
execute datascience analysis workflows. It includes the dataspace 
data-structures and analysis module functions. dspace-core is 
licensed via GNU AFFERO GENERAL PUBLIC LICENSE (see included file LICENSE).

**dspace-GUI**: The dspace-GUI is a graphical user interface for data exploration and GUI-based 
design of new analysis workflows. dpsace-GUI is licenced under a custom license 
that allows free use for research (see included file LICENSE).

**Overview of dspace-core and dspace-GUI**:
```
Tutorials/                      Tutorials, Example Scripts                     dspace-core
ModuleFunctions/                Factory and User-Defined Module Functions      dspace-core
App/                            App-internals                                  dspace-GUI
App_Settings/
Extras/ExtremeLogger/           Logging Functionionality                       dspace-GUI
Extras/ThirdPartyComponents/               
+dspace_graphs/                 Package: Main Structures for Graphs            dspace-core
+dspace_features/               Package: Main Structures for Features          dspace-core
+dspace_data/                   Package: Main Structures for Data and Labels   dspace-core
+dspace/                        Package: Basic Functions                       dspace-core
LICENSE                         
README.md                       This file                                       
dspace_examples.m               Script: Various Usage examples                 dspace-core
dspace.m                        Function: Data-Import, Start GUI               dspace-core

                            __       ___       __   __        __   __
                           |  \  /\   |   /\  /__` |__)  /\  /  ` |__
                           |__/ /~~\  |  /~~\ .__/ |    /~~\ \__, |___

                      Copyright (C) 2020 University Zurich, Sepp Kollmorgen 
```
