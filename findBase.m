function val = findBase( A, B )
    i = 1;
    val = 0;
    while i <=size(B,1) && val == 0
        if( strcmp(A{1},B{i,1}) && strcmp(A{2},B{i,2}) )
            val = i;
        else
            i = i+1;
        end
    end
    if val == 0
        val  = NaN;
    end
end