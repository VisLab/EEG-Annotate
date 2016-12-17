function [toolsVersion, level1SchemaVersion, level2SchemaVersion, levelDerivedSchemaVersion] = get_ess_versions
% [toolsVersion, level1SchemaVersion, level2SchemaVersion, levelDerivedSchemaVersion] = get_ess_versions
% Returns semver (see semver.org) versions for ESS tools and schemas for different study levels. 

toolsVersion = '2.0.1';
level1SchemaVersion = '2.3.1';
level2SchemaVersion = '1.1.0';
levelDerivedSchemaVersion = '1.0.0';
