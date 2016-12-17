function [isValid errorMessage]= validate_schema(xmlFile, schemaFile)
% Use Schema validation for the XML file

import java.io.*;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.*;

factory = SchemaFactory.newInstance('http://www.w3.org/2001/XMLSchema');
schemaLocation = File(schemaFile);
schema = factory.newSchema(schemaLocation);
validator = schema.newValidator();
source = StreamSource(xmlFile);

isValid = false;
try
validator.validate(source);
isValid = true;
errorMessage = [];
catch err
    errorMessage = err.message;
end;
