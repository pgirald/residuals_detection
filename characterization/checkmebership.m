function checkmebership(A,B)
    A = strcat('"',A,'"');
    B = strcat('"',B,'"');
    result = ~ismember(A,B);
    if any(result)
        error(strcat("The options [", join(A(result == 1), ", "), "] are not valid", ...
            ". The accepeted options are : [", join(B,", "), "]."));
    end
end

