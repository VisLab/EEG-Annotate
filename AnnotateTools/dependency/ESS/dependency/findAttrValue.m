function cl_out = findAttrValue(obj,attrName,varargin)

   % Determine if first input is object or class name
   if ischar(obj)
      mc = meta.class.fromName(obj);
   elseif isobject(obj)
      mc = metaclass(obj);
   end

   % Initialize and preallocate
   ii = 0; numb_props = length(mc.PropertyList);
   cl_array = cell(1,numb_props);

   % For each property, check the value of the queried attribute
   for  c = 1:numb_props

      % Get a meta.property object from the meta.class object
      mp = mc.PropertyList(c); 

      % Determine if the specified attribute is valid on this object
      if isempty (findprop(mp,attrName))
         error('Not a valid attribute name')
      end
      attrValue = mp.(attrName);

      % If the attribute is set or has the specified value,
      % save its name in cell array
      if attrValue
         if islogical(attrValue) || strcmp(varargin{1},attrValue)
            ii = ii + 1;
            cl_array(ii) = {mp.Name}; 
         end
      end
   end
   % Return used portion of array
   cl_out = cl_array(1:ii);
end