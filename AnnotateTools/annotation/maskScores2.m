function sNew = maskScores2(s, maskPos)

%fprintf('maskScore, min, %f, max, %f\n', min(s), max(s));

% move s so that it has zero min.
% Now it inspects more samples than before.
s = s - min(s);

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
