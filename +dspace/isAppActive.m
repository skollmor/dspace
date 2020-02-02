function rt = isAppActive()
   
    try
        q = evalin('base', 'dspaceApp');
    catch
        rt = false;
        return;
    end
    
    if isa(q, 'dspace.app.Dataspace')
        rt = true;
    else
        rt = false;
    end
    
end

