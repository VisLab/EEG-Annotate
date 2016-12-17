function isMonotonic = check_monotonic(x, propertyName)
if isempty(x)
    isMonotonic = true;
else
    isMonotonic = all(diff(x) >= 0);      
end;

if nargin > 1 && ~isMonotonic
    warning('Property "%s" is NOT monotonic.', propertyName)
end;