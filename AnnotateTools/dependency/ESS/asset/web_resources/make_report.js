// --------------------------------  Functions  --------------------------------------
function makeIntoArray(variable){
	if (variable.constructor != Array){
		return Array(variable);
	}
	else return variable;
}

function countArrayValues(arr) { // returns two arrays, one unique values and the other counts for them.
	var a = [], b = [], prev;

	arr.sort();
	for ( var i = 0; i < arr.length; i++ ) {
		if ( arr[i] !== prev ) {
			a.push(arr[i]);
			b.push(1);
		} else {
			b[b.length-1]++;
		}
		prev = arr[i];
	}

	return {uniqueValues:a, counts:b};
}

function textFromItemsAndCounts(itemStrings, itemCounts, quantityString){
	var text = '';
	if (arguments.length<3)
	var quantityString = '';
	for (var n= 0; n < itemStrings.length;n++) {
		if (itemStrings[n] != undefined)
		text +=  itemStrings[n].toString() + ' (' + itemCounts[n].toString() + quantityString + ')';
		if (n<itemStrings.length - 1)
		text += ', ';
	}
	return text;
}

function isAvailable(stringValue) {
	return stringValue != 'NA' || stringValue != '-' || stringValue != ' ';
}

function getLevelHierarchy(studyObj){
	var studyLevelHierarchy = [];
	var studyLevelHierarchyType = [];
	var currentLevel = study;
	while (true) {
		studyLevelHierarchy.unshift(currentLevel);
		if ("parentStudy" in currentLevel){
			studyLevelHierarchyType.unshift('level-derived');
			currentLevel = currentLevel.parentStudyObj;
		}
		else if ("studyLevel1" in currentLevel) {
			studyLevelHierarchyType.unshift('level2');
			currentLevel = currentLevel.studyLevel1;
		} else if ("eventSpecificationMethod" in currentLevel) {
			studyLevelHierarchyType.unshift('level1');
			break;
		}
	}
	return ({'studyLevelHierarchy': studyLevelHierarchy, 'studyLevelHierarchyType':studyLevelHierarchyType});
}

// -----------------------------------------------------------------------------

result = getLevelHierarchy(study);
var level1Study = result.studyLevelHierarchy[0];

var extracted = {}; // data extracted from study JSON object and sent to AngularJS (as $Scope)
extracted.level1 = {};
extracted.level2 = {};
extracted.levelDerived = {};
extracted.level1.shortDescription = level1Study.shortDescription;
extracted.level1.title = study.title;
extracted.level1.fullDescription = level1Study.description;
extracted.level1.showNotice = true;
extracted.level2.showNotice = false;
extracted.levelDerived.showNotice = false;

extracted.level1.numberOfSessions = level1Study.sessions.length;
extracted.level1.id = level1Study.id;

// count the number of subjects by looking at labIds. LabIds that are not provided,
//  i.e. are either NA or - are assumed to be unique.
var labsIds = [];
var groups = [];
for (var i=0; i < level1Study.sessions.length; i++) {
	for (var j=0; j < level1Study.sessions[i].subjects.length; j++) {
		var labIdValue = level1Study.sessions[i].subjects[j].labId;
		if (labIdValue == 'NA' || labIdValue == '-'){
			labIdValue = Math.floor((1 + Math.random()) * 0x1000000000000).toString();
		}
		labsIds[i] = labIdValue;
		groups.push(level1Study.sessions[i].subjects[j].group);
	}
}

// look into recordingParameterSets associated with session records
var numberOfRecordingEEGChannels = [];
var modalitiesInDataRecording = []; // what modalities are in the data recording
var channelLocationTypes = [];
var dataRecording = [];
var eegSamplingFrequency = [];
for (var i=0; i < level1Study.sessions.length; i++){
	for (var j=0; j < level1Study.sessions[i].dataRecordings.length; j++){
		var parameterSetLabel = level1Study.sessions[i].dataRecordings[j].recordingParameterSetLabel;
		for (var k=0; k < level1Study.recordingParameterSets.length; k++){
			if (level1Study.recordingParameterSets[k].recordingParameterSetLabel == parameterSetLabel){
				var modalitiesInParamerSet = [];
				var  modalityNumberOfChannels = [];
				for (var m=0; m < level1Study.recordingParameterSets[k].modalities.length; m++){
					modalitiesInParamerSet.push(level1Study.recordingParameterSets[k].modalities[m].type);
					var numberOfChannels = 1 + parseInt(level1Study.recordingParameterSets[k].modalities[m].endChannel) - parseInt(level1Study.recordingParameterSets[k].modalities[m].startChannel);
					modalityNumberOfChannels.push(numberOfChannels);
					if (level1Study.recordingParameterSets[k].modalities[m].type.toUpperCase() == 'EEG'){
						numberOfRecordingEEGChannels.push (numberOfChannels);
						// using th length of dataRecording as a proxy for the numberof data recordings so far
						eegSamplingFrequency[dataRecording.length] = level1Study.recordingParameterSets[k].modalities[m].samplingRate;
						channelLocationTypes[dataRecording.length] = level1Study.recordingParameterSets[k].modalities[m].channelLocationType;
					}
				}
				modalitiesInDataRecording = modalitiesInDataRecording.concat(_.uniq(modalitiesInParamerSet));
			}

		}

		// create text, listing modalities with their number of channels in paranthesis
		modalitiesAndTheirChannelsText = textFromItemsAndCounts(modalitiesInParamerSet, modalityNumberOfChannels);

		dataRecording.push({
			'sessionNumber': level1Study.sessions[i].number,
			'taskLabel': level1Study.sessions[i].dataRecordings[j].taskLabels.toString(),
			'sessionLabId': level1Study.sessions[i].labId,
			'channelLocationsFilename': level1Study.sessions[i].subjects[0].channelLocations,
			'subjectGroup': level1Study.sessions[i].subjects[0].group,
			'subjectGender': level1Study.sessions[i].subjects[0].gender,
			'subjectYOB': level1Study.sessions[i].subjects[0].YOB,
			'subjectAge': level1Study.sessions[i].subjects[0].age,
			'subjectLabId': level1Study.sessions[i].subjects[0].labId,
			'subjectHandedness': level1Study.sessions[i].subjects[0].hand,
			'filename': level1Study.sessions[i].dataRecordings[j].filename,
			'eventInstanceFile': level1Study.sessions[i].dataRecordings[j].eventInstanceFile,
			'originalFileNameAndPath': level1Study.sessions[i].dataRecordings[j].originalFileNameAndPath,
			'modalitiesAndTheirChannelsText': modalitiesAndTheirChannelsText,
			'eegSamplingFrequency': eegSamplingFrequency[channelLocationTypes.length-1]
		})
	}
}

extracted.level1.numberOfSubjects = _.uniq(labsIds).length;
extracted.level1.subjectGroup = _.uniq(groups).toString();
extracted.level1.eventSpecificationMethod =  level1Study.eventSpecificationMethod;

// count the number of recordings that the same number of channels
var result = countArrayValues(numberOfRecordingEEGChannels);
var uniqueEEGChannelNumbers = result.uniqueValues;
var numberOfRecordingsWithChannelNumber = result.counts;

// form the string that contains number of EEG channels and the number of data recordings associated with each (in parenthesis)
extracted.level1.numberOfChannels = textFromItemsAndCounts(uniqueEEGChannelNumbers, numberOfRecordingsWithChannelNumber, ' recordings');

// count the number of recordings that the same number of channels
var result = countArrayValues(modalitiesInDataRecording);
var uniqueModalities = result.uniqueValues;
var numberOfRecordingsWithModality = result.counts;


// form the string that contains different modalities and the number of data recordings associated with each (in parenthesis)
extracted.level1.modalities = textFromItemsAndCounts(uniqueModalities, numberOfRecordingsWithModality, ' recordings');

var result = countArrayValues(channelLocationTypes);
extracted.level1.channelLocationTypes = textFromItemsAndCounts(result.uniqueValues, result.counts, ' recordings');

extracted.level1.totalSize = level1Study.summary.totalSize;
extracted.level1.licenseType = level1Study.summary.license.type;

extracted.level1.fundingOrganization = [];
for (var i=0; i < level1Study.projectFunding.length; i++){
	extracted.level1.fundingOrganization += level1Study.projectFunding[i].organization;
	if (level1Study.projectFunding[i].grantId != '' && level1Study.projectFunding[i].grantId != 'NA' && level1Study.projectFunding[i].grantId != '-' )
	extracted.level1.fundingOrganization += ' (' + level1Study.projectFunding[i].grantId + ')';
	if (i<level1Study.projectFunding.length - 2)
	xtracted.level1.fundingOrganization += ', ';
}

// Publications
//level1Study.publications =[{'citation': 'some citation 1', 'link': 'http://google.com', 'DOI': 'w5745874584854'},{'citation': 'some citation 2', 'link': '', 'DOI': 'gzsgsg'}];

extracted.level1.publications = [];
for (var i=0; i < level1Study.publications.length; i++){
	var text = level1Study.publications[i].citation;
	var link = level1Study.publications[i].link;
	if (level1Study.publications[i].DOI != '' || level1Study.publications[i].DOI != 'NA' || level1Study.publications[i].DOI != '-'){
		text = text + ', DOI: ' + level1Study.publications[i].DOI;
		if (link == ''){
			link = 'http://dx.doi.org/' + level1Study.publications[i].DOI;
		}
	}
	extracted.level1.publications[i]= {'text': text, 'link':link};
}
// hide publications section when informationis not available
extracted.level1.showPublications = level1Study.publications[0].citation != 'NA' &&  level1Study.publications[0].citation != '-' && level1Study.publications[0].citation != '';

// experimenters
extracted.level1.experimenters = [];
for (var i=0; i < level1Study.experimenters.length; i++){
	if (isAvailable(level1Study.experimenters[i].givenName) || isAvailable(level1Study.experimenters[i].familyName)){
		if (isAvailable(level1Study.experimenters[i].additionalName))
		var middleNameSpace = ' ';
		else
		var middleNameSpace = '';

		var text = level1Study.experimenters[i].givenName + middleNameSpace + level1Study.experimenters[i].additionalName + ' ' + level1Study.experimenters[i].familyName;
	} else var text = '';

	var role = level1Study.experimenters[i].role;
	if (role != ''){
		text = role + ': ' + text;
		extracted.level1.experimenters.push(text);
	}
}

// point of contact
// show the section if it is specified.
extracted.level1.showPointOfContact = level1Study.contact.email != '' || level1Study.contact.email != '-' || level1Study.contact.email != '-';
extracted.level1.pointOfContact = '';
if (isAvailable(level1Study.contact.givenName) || isAvailable(level1Study.contact.familyName)){
	if (isAvailable(level1Study.contact.additionalName))
	var middleNameSpace = ' ';
	else
	var middleNameSpace = '';
	extracted.level1.pointOfContact = level1Study.contact.givenName + middleNameSpace + level1Study.contact.additionalName + ' ' + level1Study.contact.familyName;
}

if (extracted.level1.pointOfContact !=''){
	extracted.level1.pointOfContact += ', ';
}
extracted.level1.pointOfContact += 'Email: ' + level1Study.contact.email;

if (extracted.level1.pointOfContact !=''){
	extracted.level1.pointOfContact += ', ';
}
if (extracted.level1.pointOfContact !='' && isAvailable(level1Study.contact.phone)){
	extracted.level1.pointOfContact += 'Phone: ' + level1Study.contact.phone;
}


// hide publications section when informationis not available
extracted.level1.showExperimenters = extracted.level1.experimenters.length != 1 || extracted.level1.experimenters[0] != '';
extracted.level1.rootURI = level1Study.rootURI;
if (extracted.level1.rootURI == '.') // make it proper relative link
extracted.level1.rootURI = '..';

var level1DataRecordingsColumnDefs = [
	{headerName: "Session", field: "sessionNumber", minWidth: 100, width:100, pinned: true, checkboxSelection: false},
	{headerName: "Task", field: "taskLabel", minWidth: 100, width:100, pinned: true},
	{headerName: "EEG Sampling Rate (Hz)", field: "eegSamplingFrequency", minWidth: 200, width:200},
	{headerName: "Modalities (number of channels)", field: "modalitiesAndTheirChannelsText", minWidth: 250, width:250},
	{headerName: "Session Lab Id", field: "sessionLabId", minWidth: 150, width:150},
	{headerName: "Notes", field: "notes", minWidth: 100, width:100},
	{headerName: "Filename", field: "filename", minWidth: 300, width:300,
	template: '<a href="' + extracted.level1.rootURI + '/session/{{data.sessionNumber}}/{{data.filename}}""><span ng-bind="data.filename"></span></a>'},
	{headerName: "Original Filename", field: "originalFileNameAndPath", minWidth: 100, width:300},
	{headerName: "Channel Locations", field: "channelLocationsFilename", minWidth: 100, width:300,
	template: '<a href="' + extracted.level1.rootURI + '/session/{{data.sessionNumber}}/{{data.channelLocationsFilename}}""><span ng-bind="data.channelLocationsFilename"></span></a>'},
	{headerName: "Subject", cellStyle:{textAlign: 'center', color: 'red'},  children: [
		{headerName: "Group", field: "subjectGroup", minWidth: 80, width:80},
		{headerName: "Gender", field: "subjectGender", minWidth: 100, width:100},
		{headerName: "YOB", field: "subjectYOB", minWidth: 100, width:100},
		{headerName: "Age", field: "subjectAge", minWidth: 70, width:70},
		{headerName: "Handedness", field: "subjectHandedness", minWidth: 130, width:130},
		{headerName: "Lab Id", field: "subjectLabId", minWidth: 130, width:130}
	]},
];


function autoSizeAllGridColumns() {
	var allColumnIds = [];
	level1DataRecordingsColumnDefs.forEach( function(columnDef) {
		allColumnIds.push(columnDef.field);
		if (columnDef.children)
		for (var i = 0; i < columnDef.children.length; i++) {
			allColumnIds.push(columnDef.children[i].field);
		}
	});
	extracted.level1.dataRecordingsGridOptions.columnApi.autoSizeColumns(allColumnIds);
}

function whenLevel1DataRecordingsGridIsReady (event){
	autoSizeAllGridColumns();
	// do it again in 1 second so Angular ha time to dynamically render all filenames
	setTimeout(autoSizeAllGridColumns, 1000);
}

extracted.level1.dataRecordingsGridOptions = {
	columnDefs: level1DataRecordingsColumnDefs,
	rowData: dataRecording,
	enableColResize: true,
	enableSorting: true,
	//	unSortIcon: true,
	enableFilter: true,
	suppressMenuHide: true,
	angularCompileRows: true, // for template
	onReady: whenLevel1DataRecordingsGridIsReady
};
// without this if there is only one row it becomes hidden.
if (extracted.level1.dataRecordingsGridOptions.rowData.length == 1){
	extracted.level1.dataRecordingsGridOptions.rowHeight = 50;
}


// run the grid filter only when there was not a chage of value right before it.
// this is to prevent stuttering.

var lastTimeLevel1DatarecordingsFilterChanged = new Date();

function filterLevel1DataRecordingsIfNoChange(value) {
	var thisTime = new Date();
	if (thisTime.getTime() - lastTimeLevel1DatarecordingsFilterChanged.getTime() > 200){
		extracted.level1.dataRecordingsGridOptions.api.setQuickFilter(value);
	}
}

function onLevel1DataRecordingsFilterChanged(value) {
	lastTimeLevel1DatarecordingsFilterChanged = new Date();
	setTimeout(filterLevel1DataRecordingsIfNoChange, 300, value);
}

// task grid
var level1TasksColumnDefs = [
	{headerName: "Task Label", field: "taskLabel", minWidth: 200, width:200},
	{headerName: "Description", field: "description", minWidth: 400, width:400},
	{headerName: "HED Tags", field: "tag", minWidth: 400, width:400}
];


extracted.level1.tasksGridOptions = {
	columnDefs: level1TasksColumnDefs,
	rowData:level1Study.tasks,
	enableColResize: true,
	enableSorting: true,
	enableFilter: true,
};
// without this if there is only one row it becomes hidden.
if (extracted.level1.tasksGridOptions.rowData.length == 1){
	extracted.level1.tasksGridOptions.rowHeight = 55;
}

// Events grid
var level1EventsColumnDefs = [
	{headerName: "Event Code", field: "code", minWidth: 150, width:150, pinned: true},
	{headerName: "Task", field: "taskLabel", minWidth: 200, width:200},
	{headerName: "Number of Instances", field: "numberOfInstancesAsString", minWidth: 200, width:200},
	{headerName: "Label", field: "label", minWidth: 400, width:400},
	{headerName: "Description", field: "description", minWidth: 200, width:500, cellStyle: {'white-space': 'pre-wrap'}},
	{headerName: "HED Tags", field: "tag", minWidth:2300, width:600,cellStyle: {'white-space': 'pre-wrap'}}
];

var eventData = level1Study.eventCodes;
for (var i = 0; i < eventData.length; i++) {
	if (eventData[i].numberOfInstances>=0)	{
		eventData[i].numberOfInstancesAsString = eventData[i].numberOfInstances.toLocaleString();
	}
	else eventData[i].numberOfInstancesAsString = 'NA'
}


var lastTimeLevel1EventsFilterChanged = new Date();

function filterLevel1EventsIfNoChange(value) {
	var thisTime = new Date();
	if (thisTime.getTime() - lastTimeLevel1EventsFilterChanged.getTime() > 200){
		extracted.level1.eventsGridOptions.api.setQuickFilter(value);
	}
}

function onLevelEventsFilterChanged(value) {
	lastTimeLevel1DatarecordingsFilterChanged = new Date();
	setTimeout(filterLevel1EventsIfNoChange, 300, value);
}

extracted.level1.eventsGridOptions = {
	columnDefs: level1EventsColumnDefs,
	rowData:eventData,
	enableColResize: true,
	enableSorting: true,
	enableFilter: true,
	suppressMenuHide: true,
	rowHeight: 60
};

//license section
extracted.level1.showLicensePart = isAvailable(level1Study.summary.license.link) ||  isAvailable(level1Study.summary.license.type) ||  isAvailable(level1Study.summary.license.text);
extracted.level1.licenseType = level1Study.summary.license.type;
extracted.level1.showLicenseLink = isAvailable(level1Study.summary.license.link);
extracted.level1.licenseLink = level1Study.summary.license.link;
extracted.level1.showLicenseText = isAvailable(level1Study.summary.license.text);
extracted.level1.licenseText = level1Study.summary.license.text;

// IRB section
extracted.level1.showIRBPart = isAvailable(level1Study.IRB);
extracted.level1.IRBtext = level1Study.IRB;

// copyright section
extracted.level1.showCopyRight = isAvailable(level1Study.copyright);
extracted.level1.copyrightText  = level1Study.copyright;

//-----------------------  Adding HEd Count Treemap  ---------------------------

function addTreemap(root, divId, width, height){

	var color = d3.scale.category20c();

	var treemap = d3.layout.treemap()
	.size([width, height])
	.padding(4)
	.value(function(d) { return d.size; });

	var div = d3.select(divId)
	.style("position", "relative")
	//.style("width", width + "px")
	//	.style("width", "90%")
	.style("height", height + "px");

	div.selectAll(".treemapNode")
	.data(treemap.nodes(root))
	.enter().append("div")
	.attr("class", "treemapNode")
	.style("left", function(d) { return d.x + "px"; })
	.style("top", function(d) { return d.y + "px"; })
	.style("width", function(d) { return Math.max(0, d.dx - 1) + "px"; })
	.style("height", function(d) { return Math.max(0, d.dy - 1) + "px"; })
	.style("background", function(d) { return d.children ? color(d.name) : null; })
	.text(function(d) { return d.children ? null : d.name; });
}

//var d3Hierarchy = {"name":"HED","children":[{"name":"Event (366208)","size":76.44999894343063,"children":[{"name":"Event/Category (366208)","size":76.44999894343063,"children":[{"name":"Event/Category/Experimental stimulus (355520)","size":52.419370438462124,"children":[{"name":"Event/Category/Experimental stimulus/Instruction (6912)","size":8.841014310483892,"children":[{"name":"Event/Category/Experimental stimulus/Instruction/Fixate (6912)","size":8.841014310483892},{"name":"Event/Category/Experimental stimulus/Instruction/Detect (6912)","size":8.841014310483892}]}]},{"name":"Event/Category/Participant response (9464)","size":16.920749041896222},{"name":"Event/Category/Experiment control (8136)","size":15.950893773556164,"children":[{"name":"Event/Category/Experiment control/Sequence (8136)","size":15.950893773556164,"children":[{"name":"Event/Category/Experiment control/Sequence/Block (1224)","size":7.1098794630722715},{"name":"Event/Category/Experiment control/Sequence/Trial (6912)","size":8.841014310483892}]}]}]}]},{"name":"Item (355520)","size":52.419370438462124,"children":[{"name":"Item/Natural scene (344799)","size":29.846825183809244,"children":[{"name":"Item/Natural scene/Arial (344799)","size":29.846825183809244,"children":[{"name":"Item/Natural scene/Arial/Satellite (344799)","size":29.846825183809244}]}]},{"name":"Item/Object (3976)","size":8.288031567776464,"children":[{"name":"Item/Object/Vehicle (3976)","size":8.288031567776464,"children":[{"name":"Item/Object/Vehicle/Aircraft (3976)","size":8.288031567776464,"children":[{"name":"Item/Object/Vehicle/Aircraft/Airplane (3976)","size":8.288031567776464}]}]}]},{"name":"Item/2D shape (6912)","size":8.841014310483892,"children":[{"name":"Item/2D shape/Cross (6912)","size":8.841014310483892}]},{"name":"Item/Symbolic (3809)","size":13.731530944168998,"children":[{"name":"Item/Symbolic/Character (3809)","size":13.731530944168998,"children":[{"name":"Item/Symbolic/Character/Letter (3809)","size":13.731530944168998}]}]}]},{"name":"Participant (364984)","size":69.34011948035835,"children":[{"name":"Participant/Effect (364984)","size":69.34011948035835,"children":[{"name":"Participant/Effect/Cognitive (348608)","size":43.57835612797824,"children":[{"name":"Participant/Effect/Cognitive/Expected (340823)","size":21.55879361603278,"children":[{"name":"Participant/Effect/Cognitive/Expected/Non-target (340823)","size":21.55879361603278}]},{"name":"Participant/Effect/Cognitive/Target (3976)","size":8.288031567776464},{"name":"Participant/Effect/Cognitive/Feedback (3809)","size":13.731530944168998,"children":[{"name":"Participant/Effect/Cognitive/Feedback/Correct (3550)","size":8.174702882469461},{"name":"Participant/Effect/Cognitive/Feedback/Deterministic (3809)","size":13.731530944168998},{"name":"Participant/Effect/Cognitive/Feedback/Incorrect (259)","size":5.556828061699537}]}]},{"name":"Participant/Effect/Body part (9464)","size":16.920749041896222,"children":[{"name":"Participant/Effect/Body part/Arm (9464)","size":16.920749041896222,"children":[{"name":"Participant/Effect/Body part/Arm/Hand (9464)","size":16.920749041896222,"children":[{"name":"Participant/Effect/Body part/Arm/Hand/Finger (9464)","size":16.920749041896222}]}]}]},{"name":"Participant/Effect/Visual (10721)","size":22.57254525465289}]}]},{"name":"Action (9464)","size":16.920749041896222,"children":[{"name":"Action/Button press (9464)","size":16.920749041896222,"children":[{"name":"Action/Button press/Keyboard (9464)","size":16.920749041896222}]}]},{"name":"Attribute (20185)","size":39.49329429654911,"children":[{"name":"Attribute/Object side (9464)","size":16.920749041896222,"children":[{"name":"Attribute/Object side/Left (5010)","size":8.51919119407891},{"name":"Attribute/Object side/Right (4454)","size":8.401557847817314}]},{"name":"Attribute/Visual (10721)","size":22.57254525465289,"children":[{"name":"Attribute/Visual/Color (10721)","size":22.57254525465289,"children":[{"name":"Attribute/Visual/Color/Gray (6912)","size":8.841014310483892},{"name":"Attribute/Visual/Color/White (3809)","size":13.731530944168998}]},{"name":"Attribute/Visual/Fixation point (6912)","size":8.841014310483892}]},{"name":"Attribute/Language (3809)","size":13.731530944168998,"children":[{"name":"Attribute/Language/Unit (3809)","size":13.731530944168998,"children":[{"name":"Attribute/Language/Unit/Word (3809)","size":13.731530944168998,"children":[{"name":"Attribute/Language/Unit/Word/Adjective (3809)","size":13.731530944168998},{"name":"Attribute/Language/Unit/Word/Correct (3550)","size":8.174702882469461},{"name":"Attribute/Language/Unit/Word/Wrong (259)","size":5.556828061699537}]}]}]}]}]};
var d3Hierarchy = convertToD3Hierarchy(eventCodeNumberOfInstancesToTagCount(level1Study.eventCodes));

//---------------------- setting up AngularJS ----------------------------------

angular.module('essReportApp',  ["agGrid"]).controller('ReportController', function($scope) {
	// transfer key values from extracted to $scope so they are placed in the html template
	for (var key in extracted) {
		// skip loop if the property is from prototype
		if (!extracted.hasOwnProperty(key)) continue;
		$scope[key] = extracted[key];
	}
	addTreemap(d3Hierarchy, "#treemap", 1200, 800);
});
