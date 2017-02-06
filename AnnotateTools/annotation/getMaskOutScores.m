% flag highRecall 
%   set true: to get higher recall
%   set false: to get higher precision
function sNew = getMaskOutScores(s, maskPos, cutOff)

s = s - cutOff;  % After this line, it is in the same way as zero-cutoff

sNew = zeros(size(s));

while(true)
    [theMax, thePos] = max(s);
    if theMax <= 0
        return
    end
    sNew(thePos) = s(thePos);
    startPos = thePos - maskPos + 1;
    endPos = thePos + maskPos + 1;
    realStart = max(1, startPos);
    realEnd = min(length(s), endPos);
    s(realStart:realEnd) = 0;
end


