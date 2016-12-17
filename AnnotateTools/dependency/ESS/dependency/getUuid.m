function uuid = getUuid
    uuid = strrep(char(java.util.UUID.randomUUID), '-', '');
end