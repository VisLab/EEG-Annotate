<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- Start of defining keys for finding distinct values -->
	<xsl:key name="SubjectGroupValue" match="/studyLevel1/sessions/session/subject" use="group"/>
	<xsl:key name="ModalityTypeGroupValue" match="/studyLevel1/recordingParameterSets/recordingParameterSet/channelType/modality" use="type" />
	<xsl:key name="ModalityChannelLocationTypeGroupValue" match="/studyLevel1/recordingParameterSets/recordingParameterSet/channelType/modality" use="channelLocationType" />
<!--  	maybe could be used later: <xsl:key name="keyRecordingParameterSetLabel" match="/studyLevel1/recordingParameterSets/recordingParameterSet" use="recordingParameterSetLabel" /> -->
<!-- End of definig keys -->
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<title>
					<xsl:for-each select="studyLevel1">
						<tr>
							<td>
								<xsl:value-of select="title"/>
							</td>
						</tr>
					</xsl:for-each>
				</title>
			</head>
			<style type="text/css">
body
{margin:30px;font-family:arial,helvetica,sans-serif; background-color:white}
table
{
border-collapse: collapse;
}
.tablebody
{
text-align: center;
}
.tablebody
tr:nth-of-type(odd) {
  background-color:whitesmoke;
} 
.tablebody
tr:nth-of-type(even) {
  background-color:#E6E6E6;
} 
} 
license
{
font-family:Arial
font-size= 7pt
}


</style>
			<body>
			<xsl:for-each select="/studyLevel1/organization">
			<xsl:if test="logoLink != 'NA'">
				<img style="" alt="">
					<xsl:attribute name="src">
						<xsl:value-of select="logoLink"/>
					</xsl:attribute>
				</img>
				</xsl:if>
				</xsl:for-each>
				<h2>
					<xsl:for-each select="studyLevel1">
						<tr>
							<h2>
								<xsl:value-of select="title"/>
							</h2>
						</tr>
					</xsl:for-each>
				</h2>
				<p>This study is an <a href="http://www.eegstudy.org/#level1">ESS Standard Data Level 1 container</a>. This means that it contains raw, unprocessed EEG data (and possibly other modalities) arranged in a standard manner. You use the data in the container folder as usual or use <a href="https://github.com/BigEEGConsortium/ESS">ESS tools (MATLAB)</a> to automate access and proceesing.  For more information pleasee visit <a href="http://www.eegstudy.org/">eegstudy.org</a>.</p>
				<h3>Short Description</h3>
				<p>
					<xsl:for-each select="studyLevel1">
						<tr>
							<td>
								<xsl:value-of select="shortDescription"/>
							</td>
						</tr>
					</xsl:for-each>
				</p>
				<h3>Full Description</h3>
				<p>
					<xsl:for-each select="studyLevel1">
						<tr>
							<td>
								<xsl:value-of select="description" disable-output-escaping="yes" />
							</td>
						</tr>
					</xsl:for-each>
				</p>				
				<h3>Summary</h3>
			
				<table>
					<xsl:for-each select="studyLevel1/summary">
						<tr>
							<td>Number of Sessions: 
							<xsl:for-each select="/studyLevel1/sessions/session/number">
									<xsl:sort data-type="number" order="descending"/>
									<xsl:if test="position()=1">
										<xsl:value-of select="."/>
									</xsl:if>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>Number of Subjects: 
							<xsl:choose>
							<xsl:when test="/studyLevel1/sessions/session/subject/labId='NA'">
									<xsl:value-of select="count(/studyLevel1/sessions/session/subject)"/>
							</xsl:when>
							<xsl:otherwise>
							<xsl:value-of select="count(/studyLevel1/sessions/session/subject/labId[not(following::labId = .)])"/>
							</xsl:otherwise>
							</xsl:choose>
							</td>
						</tr>
						<tr>
							<td>Type of Subject Groups:
						<xsl:for-each select="/studyLevel1/sessions/session/subject[generate-id()=generate-id(key('SubjectGroupValue' , group)[1])]">
									<xsl:value-of select="concat(group, '', '')"/>
									<xsl:if test="position()!=last()">
										<xsl:text>, </xsl:text>
									</xsl:if>
						</xsl:for-each>
							</td>
						</tr>
						<tr>
							<xsl:for-each select="/studyLevel1/summary">
								<td>All subjects are considered healthy and normal: <xsl:value-of select="allSubjectsHealthyAndNormal"/>
								</td>
							</xsl:for-each>
						</tr>						
						<tr>
							<xsl:for-each select="/studyLevel1">
								<td>Primary source of event information: <xsl:value-of select="eventSpecificationMethod"/>
								</td>
							</xsl:for-each>
						</tr>
						<tr>
							<td>Number of Channels (all modalities, min to max): 
							<xsl:for-each select="/studyLevel1/recordingParameterSets/recordingParameterSet/channelType/modality/endChannel">
									<xsl:sort data-type="number" order="ascending"/>
									<xsl:if test="position()=1">
										<xsl:value-of select="."/>
									</xsl:if>
								</xsl:for-each> to
							<xsl:for-each select="/studyLevel1/recordingParameterSets/recordingParameterSet/channelType/modality/endChannel">
									<xsl:sort data-type="number" order="descending"/>
									<xsl:if test="position()=1">
										<xsl:value-of select="."/>
									</xsl:if>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>Recorded Modalities: 
							<xsl:for-each select="/studyLevel1/recordingParameterSets/recordingParameterSet/channelType/modality[generate-id()=generate-id(key('ModalityTypeGroupValue' , type)[1])]">
									<xsl:value-of select="concat(type, '', '')"/>
									<xsl:if test="position()!=last()">
										<xsl:text>, </xsl:text>
									</xsl:if>
							</xsl:for-each>
							</td>	
						</tr>
						<tr>
							<td>Channel Location Type(s): 
							<xsl:for-each select="/studyLevel1/recordingParameterSets/recordingParameterSet/channelType/modality[generate-id()=generate-id(key('ModalityChannelLocationTypeGroupValue' , channelLocationType)[1])]">
									<xsl:value-of select="concat(channelLocationType, '', '')"/>
									<xsl:if test="position()!=last()">
										<xsl:text>, </xsl:text>
									</xsl:if>
							</xsl:for-each>
							</td>
							
						</tr>
						<tr>
							<td>Total Size: <xsl:value-of select="totalSize"/>
							</td>
						</tr>
						<tr>
							<td>License Type: <xsl:value-of select="license/type"/>
							</td>
						</tr>
						<tr>
							<td>Funding Organization: <xsl:value-of select="/studyLevel1/project/funding/organization"/>
							</td>
						</tr>						
					</xsl:for-each>
				</table>
				<xsl:choose>
				<xsl:when test="studyLevel1/publications/publication/citation != ''">
				<h3>Publications</h3>
				<table>
					<xsl:for-each select="studyLevel1/publications/publication">
						<tr>
							<td>
								<xsl:value-of select="citation"/>
							</td>
						</tr>
						<tr>
							<td>
								<a target="_blank">
									<xsl:attribute name="href">
										<xsl:value-of select="link"/>
									</xsl:attribute>
									<xsl:value-of select="link"/>
								</a>
							</td>
						</tr>
						<xsl:for-each select="DOI">
							<tr>
								<td>DOI:
						<a target="_blank">
										<xsl:attribute name="href">http://dx.doi.org/<xsl:value-of select="."/>
										</xsl:attribute>
										<xsl:value-of select="."/>
									</a>
								</td>
							</tr>
						</xsl:for-each>
					</xsl:for-each>
				</table>
				</xsl:when>
				</xsl:choose>
				<h3>Experimenters</h3>
				<table>
					<xsl:for-each select="studyLevel1/experimenters/experimenter">
						<tr>
							<td>
								<xsl:value-of select="name"/> (<xsl:value-of select="role"/>)
							</td>
						</tr>
					</xsl:for-each>
				</table>
				<h3>Session Information</h3>
				<table width="1300" height="800" border="1" class="tablebody">
					<tr>
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>Session</strong>
						</td>
						<td rowspan="2" width="70" align="center" bgcolor="#CCCCCC">
							<strong>Purpose</strong>
						</td>
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>Lab Id</strong>
						</td>
						<td colspan="6" align="center" bgcolor="#CCCCCC">
							<strong>Subject</strong>
						</td>
						<!--<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>EEG Sampling Rate (Hz)</strong>
						</td> -->
						<td rowspan="2" width="200" align="center" bgcolor="#CCCCCC">
							<strong>Notes</strong>
						</td>
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>EEG Recordings</strong>
						</td>
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>Channel Locations</strong>
						</td>
						<!--<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>Number of Channels</strong>
						</td>-->
						<!--<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>Channel Location Type</strong>
						</td>-->
					</tr>
					<tr>
						<td align="center" bgcolor="#CCCCCC">
							<strong>Lab Id</strong>
						</td>
						<td align="center" bgcolor="#CCCCCC">
							<strong>Group</strong>
						</td>
						<td width="40" align="center" bgcolor="#CCCCCC">
							<strong>Gender</strong>
						</td>
						<td width="45" align="center" bgcolor="#CCCCCC">
							<strong>YOB</strong>
						</td>
						<td width="40" align="center" bgcolor="#CCCCCC">
							<strong>Age</strong>
						</td>
						<td width="55" align="center" bgcolor="#CCCCCC">
							<strong>Hand</strong>
						</td>
					</tr>
					<xsl:for-each select="studyLevel1/sessions/session">
						<tr height="30">
							<td>
								<xsl:value-of select="number"/>
							</td>
							<td>
							<xsl:choose>
							<xsl:when test="taskLabel != ''"><xsl:value-of select="purpose"/> (Task <xsl:value-of select="taskLabel"/>)</xsl:when>
							<xsl:otherwise><xsl:value-of select="purpose"/></xsl:otherwise>
							</xsl:choose>
							</td>
							<td>
								<xsl:value-of select="labId"/>
							</td>
							<td>
								<xsl:for-each select="subject">
									<p>
										<xsl:value-of select="labId"/>
									</p>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="subject">
									<p>
										<xsl:value-of select="group"/>
									</p>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="subject">
									<p>
										<xsl:value-of select="gender"/>
									</p>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="subject">
									<p>
										<xsl:value-of select="YOB"/>
									</p>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="subject">
									<p>
										<xsl:value-of select="age"/>
									</p>
								</xsl:for-each>
							</td>
							<td>
								<xsl:for-each select="subject">
									<p>
										<xsl:value-of select="hand"/>
									</p>
								</xsl:for-each>
							</td>
							<!--<td>
								<xsl:value-of select="eegSamplingRate"/>
							</td>-->
							<td>
								<xsl:for-each select="notes">
									<xsl:value-of select="note"/>
					
										<a target="_blank">
											<xsl:attribute name="href">
												<xsl:value-of select="link"/>
											</xsl:attribute>
											<xsl:value-of select="linkName"/>
										</a>								
								</xsl:for-each>
							</td>
							<td>
								<a target="_blank">
									<xsl:attribute name="href">
										session/<xsl:value-of select="number"/>/<xsl:value-of select="dataRecordings/dataRecording/filename"/>
									</xsl:attribute>
									<xsl:value-of select="dataRecordings/dataRecording/filename"/>
								</a>
							</td>
							<td>
									<xsl:for-each select="subject">
									<p>
										<a target="_blank">
											<xsl:attribute name="href">
												session/<xsl:value-of select="../number"/>/<xsl:value-of select="channelLocations"/>
											</xsl:attribute>
											<xsl:value-of select="channelLocations"/>
										</a>
									</p>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:for-each>
				</table>
				<xsl:choose>
				<xsl:when test="studyLevel1/tasks/task/description = ''"></xsl:when>
				<xsl:when test="studyLevel1/tasks/task/taskLabel = ''">
				<h3>Study Paradigm and Context</h3>
				<table width="700"  border="1" class="tablebody">
					<tr>
						<td align="center" bgcolor="#CCCCCC">
							<strong>Description </strong>
						</td>
						<td align="center" bgcolor="#CCCCCC">
							<strong>Tag</strong>
						</td>
					</tr>
					<xsl:for-each select="studyLevel1/tasks/task">
						<tr height="35">
								<td>
									<xsl:value-of select="description"/>
								</td>
								<td>
									<xsl:value-of select="tag"/>
								</td>
								
							</tr>
							</xsl:for-each>
				</table>
				</xsl:when>
				<xsl:when test="studyLevel1/tasks/task/taskLabel != ''">
				<h3>Study Paradigm and Context</h3>
				<table width="700"  border="1" class="tablebody">
					<tr>
					<td  align="center" bgcolor="#CCCCCC">
						 <strong>Task</strong>
						</td>
						<td align="center" bgcolor="#CCCCCC">
							<strong>Description </strong>
						</td>
						<td align="center" bgcolor="#CCCCCC">
							<strong>Tag</strong>
						</td>
					</tr>
					<xsl:for-each select="studyLevel1/tasks/task">
						<tr height="35">
								<td>
									<xsl:value-of select="taskLabel"/>
								</td>
								<td>
									<xsl:value-of select="description"/>
								</td>
								<td>
									<xsl:value-of select="tag"/>
								</td>
								
							</tr>
							</xsl:for-each>
				</table>
				</xsl:when>
				
				</xsl:choose>
				<h3>Event Codes</h3>
				<table width="770"  border="1" class="tablebody">
					<tr>
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>Event Code</strong>
						</td>
						<td colspan="3" align="center" bgcolor="#CCCCCC">
							<strong>Condition</strong>
						</td>
					</tr>
					<tr>
						<td align="center" bgcolor="#CCCCCC">
							<strong>Label</strong>
						</td>
						<td align="center" bgcolor="#CCCCCC">
							<strong>Description</strong>
						</td>
						<td width="260" align="center" bgcolor="#CCCCCC">
							<strong>Tag</strong>
						</td>
					</tr>
					<xsl:for-each select="studyLevel1/eventCodes/eventCode">
						<tr height="35">
							<td>
							<xsl:choose> 
							<xsl:when test="taskLabel != ''"> Task <xsl:value-of select="taskLabel"/>: <xsl:value-of select="code"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="code"/></xsl:otherwise>
							</xsl:choose> 
							</td>
							<xsl:for-each select="condition">
								<td>
									<xsl:value-of select="label"/>
								</td>
								<td>
									<xsl:value-of select="description"/>
								</td>
								<td>
									<xsl:value-of select="tag"/>
								</td>
							</xsl:for-each>
						</tr>
					</xsl:for-each>
				</table>
				<h3>Contact</h3>
				<table>
					<xsl:for-each select="studyLevel1/contact">
						<tr>
							<td>
							<xsl:choose>
								<xsl:when test="name != ''">For data results or more information regarding this study contact: <xsl:value-of select="name"/></xsl:when>
							</xsl:choose>
							</td>
						</tr>
						<tr>
						<td>
							<xsl:choose>
								<xsl:when test="email != ''"> phone: <xsl:value-of select="email"/></xsl:when>
							</xsl:choose>
							</td>
						</tr>
						<tr>
							<td>
							<xsl:choose>
								<xsl:when test="phone != ''"> phone: <xsl:value-of select="phone"/></xsl:when>
							</xsl:choose>
							</td>
						</tr>
					</xsl:for-each>
				</table>
				<h3>License Agreement</h3>
				<xsl:for-each select="studyLevel1">
					<tr>
						<td>
							<xsl:value-of select="copyright"/>
						</td>
					</tr>
				</xsl:for-each>
				<xsl:for-each select="studyLevel1/summary/license">
					<tr>
						<td>
							<xsl:value-of select="text"/>
						</td>
					</tr>
					<p>
						<a target="_blank">
							<xsl:attribute name="href">
								<xsl:value-of select="link"/>
							</xsl:attribute>License link
			</a>
					</p>
				</xsl:for-each>
				<xsl:for-each select="studyLevel1">
					<p>
						<tr>
							<td>
								<xsl:value-of select="IRB"/>
							</td>
						</tr>
					</p>
				</xsl:for-each>
				<p>This report is automically generated from an XML file in EEG Study Schema (ESS) version <xsl:for-each select="studyLevel1"><xsl:value-of select="essVersion"/>	</xsl:for-each>. To learn more about ESS and download tools for automated import of ESS-formatted information (e.g. into Matlab) please visit  <a href="http://www.eegstudy.org">eegstudy.org</a>.</p>
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>








