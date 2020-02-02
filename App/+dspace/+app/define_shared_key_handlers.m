function [ handlers ] = define_shared_key_handlers()
    %
    % 
    %
    %<PRE>
    % This file is part of dspace-GUI.
    % 
    % Copyright (C) 2020 University Zurich, Sepp Kollmorgen
    % 
    % dspace-GUI is licenced under a custom license (see LICENSE file).
    % 
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    % </PRE>
    % <b>Dataspace on Github</b>: <a href="matlab:web('https://github.com/skollmor/dspace', '-browser')">https://github.com/skollmor/dspace</a>

    
    if ismac
       
        handlers = {@dspace.keyfcns.propertyCycler_mac, @dspace.keyfcns.sourceCycler_mac,...
            @dspace.keyfcns.focussedItemCycler};
    
    elseif isunix
    
        handlers = {@dspace.keyfcns.propertyCycler, @dspace.keyfcns.sourceCycler,...
            @dspace.keyfcns.focussedItemCycler};
    
    elseif ispc
    
        handlers = {@dspace.keyfcns.propertyCycler, @dspace.keyfcns.sourceCycler,...
            @dspace.keyfcns.focussedItemCycler};
       
    else
        
        assert(false, 'Platform not supported');
        
    end
    
    
end

