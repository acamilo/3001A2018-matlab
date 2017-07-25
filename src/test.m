testArray = zeros(15, 1, 'single')

theArray = single2byte(37, testArray)

function thing = single2byte(code, val)
    newSize = length(val) + 1;
    newArray = zeros(newSize, 1, 'single');
    for i=1:size(newArray)
        if i == 1
            newArray(i) = single(code);
        else
            newArray(i) = val(i-1);
        end
    end

    returnArray = typecast(newArray, 'uint8');
    thing = returnArray;
end