function [val type] = findBase(A, B, C)
    i = 1;
    found = 0;
    while i <=size(B,1) && found == 0
        if( strcmp(A{1},B{i,1}) && strcmp(A{2},B{i,2}) )
            found = i;
        else
            i = i+1;
        end
    end
    if(~strcmp("",B{found,4}))
        i = 1;
        val = 0;
        while i <=size(C,1) && val == 0
            if( strcmp(C{i,1},B{found,1}) && strcmp(C{i,2},B{found,4}) )
                val = i;
            else
                i = i+1;
            end
        end
        type = B{found,3};
    else
        val  = NaN;
        type = '';
    end
    if val == 0
        val  = NaN;
        type = '';
    end
end