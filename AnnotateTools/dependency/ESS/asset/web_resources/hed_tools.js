var isNode=new Function("try {return this===global;}catch(e){return false;}");

if (isNode()){
	var _ = require("underscore");
	var fs = require('fs');
}

function median(values) {
	values.sort( function(a,b) {return a - b;} );
	var half = Math.floor(values.length/2);
	if(values.length % 2)
	return values[half];
	else
	return (values[half-1] + values[half]) / 2.0;
}

function hedStringToTags(hedString){
	hedString = hedString.trim();
	hedString = hedString.replace(/\(/g, ""); // need to use g to make it global replace
	hedString = hedString.replace(/\)/g, "");
	hedString = hedString.replace(/~/g, ",");
	hedString = hedString.replace(/\\/g, "/");
	var hedTags = hedString.split(',');
	for (var i = 0; i < hedTags.length; i++) {
		hedTags[i] = standardizedHedTag(hedTags[i]);
	}
	return hedTags;
}

function standardizedHedTag(hedTag){
	var trimmedTag = hedTag.trim();
	trimmedTag = trimmedTag.replace(/\\/g, "/");
	// remove the trailing /
	if (trimmedTag.indexOf('/', 0) == 0){
		trimmedTag = trimmedTag.slice(1, trimmedTag.length-1);
	}
	// remove the leading /
	if (trimmedTag.lastIndexOf('/') == trimmedTag.length-1){ // remove the trailing /
		trimmedTag = trimmedTag.slice(0, trimmedTag.length-1);
	}
	return trimmedTag;
}

function makeAllParentHedTags(hedTag)
{
	var parentTags = [];
	hedTag = standardizedHedTag(hedTag); // leading and trailing /s can mess this algorithm up.
	parentTags[0] = hedTag;
	var startSearchIndex = 0;
	var i = 0;
	while (i>-1 && startSearchIndex < hedTag.length) {
		var i = hedTag.indexOf('/', startSearchIndex);
		if (i>-1){
			startSearchIndex = i+1;
			parentTags.push(hedTag.slice(0, i));
		}
	}
	return 	parentTags
}

function eventCodeNumberOfInstancesToTagCount (eventArray, ignoreTagArray){ // assumes event object has 'numberOfInstances' and 'tag' fields.
// ignoreTagArray contains tags that are not to be counted and are fully removed.
var ignoreTagArray = typeof ignoreTagArray !== 'undefined' ?  ignoreTagArray :['Attribute/Onset', 'Attribute/Offset', 'Event/Label', 'Event/Description', 'Sensory presentation/Visual/Rendering type/Screen/2D'];
var tagAndCount = [];
for (var i = 0; i < eventArray.length; i++) {
	var parentHedTags = [];
	var eventHedTags = hedStringToTags(eventArray[i].tag);

	// remove all the tags to be ignored
	var cleanedEventHedTags = [];
	for (var j = 0; j < eventHedTags.length; j++) {
		var shouldBeIgnored = false;
		for (var k = 0; k < ignoreTagArray.length; k++) {
			if (isTagChild(ignoreTagArray[k], eventHedTags[j], true)){
				shouldBeIgnored = true;
				break;
			}
		}
		if (!shouldBeIgnored)
		cleanedEventHedTags.push(eventHedTags[j]);
	}
	eventHedTags = cleanedEventHedTags;

	for (var j = 0; j < eventHedTags.length; j++) {
		parentHedTags = parentHedTags.concat(makeAllParentHedTags(eventHedTags[j]));
	}

	parentHedTags = _.uniq(parentHedTags); // remove repeats in each hed string

	for (var k = 0; k < parentHedTags.length; k++) {
		if (parentHedTags[k] in tagAndCount){
			tagAndCount[parentHedTags[k]].count = tagAndCount[parentHedTags[k]].count + eventArray[i].numberOfInstances;
            if (eventArray[i].numberOfInstances>0){
			     tagAndCount[parentHedTags[k]].logCount = tagAndCount[parentHedTags[k]].logCount + Math.log(eventArray[i].numberOfInstances);
            }
		}
		else {
			tagAndCount[parentHedTags[k]] = {};
			tagAndCount[parentHedTags[k]].count = eventArray[i].numberOfInstances;
            if (eventArray[i].numberOfInstances > 0){
			     tagAndCount[parentHedTags[k]].logCount = Math.log(eventArray[i].numberOfInstances);
            } else
            {
                tagAndCount[parentHedTags[k]].logCount = 0;
            }

		}
	}
}
console.log(tagAndCount);
return tagAndCount;
}

function isTagChild(parentTag, potentialChild, selfIsChild){
	// self is defined here as NOT a child
	if (parentTag == potentialChild){
		return selfIsChild;
	}
	return potentialChild.indexOf(parentTag + '/') > -1;
}

function isTagImmediateChild(parentTag, potentialImmediateChild){ // returns true only if the potential child only is  only level HED level lower
	if (isTagChild(parentTag, potentialImmediateChild, false))
	{
		var difference = potentialImmediateChild.slice(parentTag.length+1, potentialImmediateChild.length);
		return  difference.indexOf('/') == -1; // there are / s left so there is no other level in between
	}
	else return false;
}

function getChildD3Hierarchy(currentTag, tagCount, useLogCount){

	// make a numerical array containing just counts
	var countArray = [];
	for (var tag in tagCount) {
		if (tagCount.hasOwnProperty(tag)) {
			countArray.push(tagCount[tag].count);
		}
	}

	var useLogCount = typeof useLogCount !== 'undefined' ?  useLogCount : Math.max.apply(null, countArray) > 10 * median(countArray);

	var currentTagHierarchy = {};
	currentTagHierarchy.name = currentTag + ' (' + tagCount[currentTag].count + ')';
	if (useLogCount){
		currentTagHierarchy.size = tagCount[currentTag].logCount;
	} else {
		currentTagHierarchy.size = tagCount[currentTag].count;
	}

	for (var tag in tagCount) {
		if (tagCount.hasOwnProperty(tag)) {
			if (isTagImmediateChild(currentTag, tag)){

				if (currentTagHierarchy.hasOwnProperty('children') == false) { // onbly add children property is a child exists
					currentTagHierarchy.children = [];
				}

				currentTagHierarchy.children.push(getChildD3Hierarchy(tag, tagCount, useLogCount));
			}
		}
	}
	return currentTagHierarchy;
}

function convertToD3Hierarchy(tagCount, useLogCount){

	var hierarchy = {};
	hierarchy.name = 'HED';
	hierarchy.children = [];
	// find the topmost tags as they have no parents
	var tagHasAnyParent = [];
	for (var tag1 in tagCount) {
		if (tagCount.hasOwnProperty(tag1)){
			tagHasAnyParent[tag1] = false;
			for (var tag2 in tagCount) {
				if (tagCount.hasOwnProperty(tag2)){
					tagHasAnyParent[tag1] = tagHasAnyParent[tag1] | isTagChild(tag2, tag1, false);
				}
			}
		}
	}

	for (var tag in tagCount) {
		if (tagCount.hasOwnProperty(tag)){
			if (tagHasAnyParent[tag] == false){
				hierarchy.children.push(getChildD3Hierarchy(tag, tagCount, useLogCount));
			}
		}
	}

	return hierarchy;
}

// ---------------------------------------- test -------------------------

//var eventArray = [{numberOfInstances:5, tag:'/Participant/Effect/Cognitive/Target/'},
//{numberOfInstances:10, tag:'Event/Categorty/Stimulus'},{numberOfInstances:10, tag:'Event/Categorty/Check, Event/Categorty'}];

//console.log(isTagImmediateChild('Participant/Effect', 'Participant/Effect/Cognitive'));
//var tagCount = eventCodeNumberOfInstancesToTagCount(eventArray);
//console.log(tagCount);

//console.log(hedStringToTags('Event/Categorty/check, Event/Categorty'));
//console.log(makeAllParentHedTags('/Participant/Effect/Cognitive/Target/'));
//var d3hierarchyJson = JSON.stringify(convertToD3Hierarchy(tagCount));
//console.log(d3hierarchyJson);

if (isNode()){
    var eventArray = [{numberOfInstances:5, tag:'/Participant/Effect/Cognitive/Target/'},
        {numberOfInstances:10, tag:'Event/Categorty/Stimulus'},{numberOfInstances:10, tag:'Event/Categorty/Check, Event/Categorty'}];
    
    var tagCount = eventCodeNumberOfInstancesToTagCount(eventArray);
    var d3hierarchyJson = JSON.stringify(convertToD3Hierarchy(tagCount));
	fs.writeFile("/home/nima/Documents/mycode/matlab/ESS_scripts/treemap/hedcount.json", d3hierarchyJson, function(err) {
		if(err) {
			return console.log(err);
		}
		console.log("The file was saved!");
	});
}
