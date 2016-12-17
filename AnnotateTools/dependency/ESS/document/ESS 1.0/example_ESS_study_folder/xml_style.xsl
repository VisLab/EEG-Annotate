<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:key name="SubjectGroupValue" match="/study/sessions/session/subject" use="group"/>
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<title>
					<xsl:for-each select="study">
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
{margin:30px;font-family:arial,helvetica,sans-serif;}
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
				<img style="" alt="=">
					<xsl:attribute name="src">
						<xsl:value-of select="/study/organization/logoLink"/>
					</xsl:attribute>
				</img>
				<h2>
					<xsl:for-each select="study">
						<tr>
							<h2>
								<xsl:value-of select="title"/>
							</h2>
						</tr>
					</xsl:for-each>
				</h2>
				<h3>Description:</h3>
				<p>
					<xsl:for-each select="study">
						<tr>
							<td>
								<xsl:value-of select="description"/>
							</td>
						</tr>
					</xsl:for-each>
				</p>
				<h3>Summary:</h3>
			
				<table>
					<xsl:for-each select="study/summary">
						<tr>
							<td>Number of Sessions: 
							<xsl:for-each select="/study/sessions/session/number">
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
							<xsl:when test="/study/sessions/session/subject/labId='NA'">
									<xsl:value-of select="count(/study/sessions/session/subject)"/>
							</xsl:when>
							<xsl:otherwise>
							<xsl:value-of select="count(/study/sessions/session/subject/labId[not(following::labId = .)])"/>
							</xsl:otherwise>
							</xsl:choose>
							</td>
						</tr>
						<tr>
							<td>Type of Subject Groups:
						<xsl:for-each select="/study/sessions/session/subject[generate-id()=generate-id(key('SubjectGroupValue' , group)[1])]">
									<xsl:value-of select="concat(group, '', '')"/>
									<xsl:if test="position()!=last()">
										<xsl:text>, </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<xsl:for-each select="/study/summary">
								<td>All subjects are considered healthy and normal: <xsl:value-of select="allSubjectsHealthyAndNormal"/>
								</td>
							</xsl:for-each>
						</tr>
						<tr>
							<td>Number of Channels (min to max): 
							<xsl:for-each select="/study/sessions/session/channels">
									<xsl:sort data-type="number" order="ascending"/>
									<xsl:if test="position()=1">
										<xsl:value-of select="."/>
									</xsl:if>
								</xsl:for-each> to
							<xsl:for-each select="/study/sessions/session/channels">
									<xsl:sort data-type="number" order="descending"/>
									<xsl:if test="position()=1">
										<xsl:value-of select="."/>
									</xsl:if>
								</xsl:for-each>
							</td>
						</tr>
						<tr>
							<td>Recorded Modalities: 
							<xsl:for-each select="/study/summary/recordedModalities/modality">
									<xsl:value-of select="name"/>
									<xsl:choose>
										<xsl:when test="numberOfSensors != ''"> (<xsl:value-of select="recordingDevice"/>, <xsl:value-of select="numberOfSensors"/> sensors <xsl:value-of select="numberOfChannels"/>
											<xsl:value-of select="numberOfCameras"/>)</xsl:when>
											<xsl:when test="numberOfChannels = '1' "> (<xsl:value-of select="recordingDevice"/>
											<xsl:value-of select="numberOfSensors"/>, <xsl:value-of select="numberOfChannels"/> channel<xsl:value-of select="numberOfCameras"/>)</xsl:when>
										<xsl:when test="numberOfChannels != ''"> (<xsl:value-of select="recordingDevice"/>
											<xsl:value-of select="numberOfSensors"/>, <xsl:value-of select="numberOfChannels"/> channels<xsl:value-of select="numberOfCameras"/>)</xsl:when>
										<xsl:when test="numberOfCameras = '1' "> (<xsl:value-of select="recordingDevice"/>
											<xsl:value-of select="numberOfSensors"/>
											<xsl:value-of select="numberOfChannels"/>, <xsl:value-of select="numberOfCameras"/> camera)</xsl:when>
										<xsl:when test="numberOfCameras != ''"> (<xsl:value-of select="recordingDevice"/>
											<xsl:value-of select="numberOfSensors"/>
											<xsl:value-of select="numberOfChannels"/>, <xsl:value-of select="numberOfCameras"/> cameras)</xsl:when>
										<xsl:when test="recordingDevice = ''"> <xsl:value-of select="recordingDevice"/> <xsl:value-of select="numberOfSensors"/><xsl:value-of select="numberOfChannels"/>
											<xsl:value-of select="numberOfCameras"/></xsl:when>
										<xsl:otherwise> (<xsl:value-of select="recordingDevice"/>)</xsl:otherwise>
									</xsl:choose>
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
					</xsl:for-each>
				</table>
				<xsl:choose>
				<xsl:when test="study/publications/publication/citation != ''">
				<h3>Publications:</h3>
				<table>
					<xsl:for-each select="study/publications/publication">
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
				<h3>Experimenters:</h3>
				<table>
					<xsl:for-each select="study/experimenters/experimenter">
						<tr>
							<td>
								<xsl:value-of select="name"/> (<xsl:value-of select="role"/>)
							</td>
						</tr>
					</xsl:for-each>
				</table>
				<h3>Table of Session Information:</h3>
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
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>EEG Sampling Rate (Hz)</strong>
						</td>
						<td rowspan="2" width="200" align="center" bgcolor="#CCCCCC">
							<strong>Notes</strong>
						</td>
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>EEG Recordings</strong>
						</td>
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>Channel Locations</strong>
						</td>
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>Number of Channels</strong>
						</td>
						<td rowspan="2" align="center" bgcolor="#CCCCCC">
							<strong>Channel Location Type</strong>
						</td>
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
					<xsl:for-each select="study/sessions/session">
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
							<td>
								<xsl:value-of select="eegSamplingRate"/>
							</td>
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
										<xsl:value-of select="eegRecordings"/>
									</xsl:attribute>
									<xsl:value-of select="eegRecordings"/>
								</a>
							</td>
							<td>
								<xsl:for-each select="subject">
									<p>
										<a target="_blank">
											<xsl:attribute name="href">
												<xsl:value-of select="channelLocations"/>
											</xsl:attribute>
											<xsl:value-of select="channelLocations"/>
										</a>
									</p>
								</xsl:for-each>
							</td>
							<td>
								<xsl:value-of select="channels"/>
							</td>
							<td>
								<xsl:for-each select="subject">
									<p>
										<xsl:value-of select="channelLocationType"/>
									</p>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:for-each>
				</table>
				<xsl:choose>
				<xsl:when test="study/tasks/task/description = ''"></xsl:when>
				<xsl:when test="study/tasks/task/taskLabel = ''">
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
					<xsl:for-each select="study/tasks/task">
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
				<xsl:when test="study/tasks/task/taskLabel != ''">
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
					<xsl:for-each select="study/tasks/task">
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
				<h3>Table of Event Codes:</h3>
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
					<xsl:for-each select="study/eventCodes/eventCode">
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
				<h3>Contact:</h3>
				<table>
					<xsl:for-each select="study/contact">
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
				<h3>License Agreement:</h3>
				<xsl:for-each select="study">
					<tr>
						<td>
							<xsl:value-of select="copyright"/>
						</td>
					</tr>
				</xsl:for-each>
				<xsl:for-each select="study/summary/license">
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
				<xsl:for-each select="study">
					<p>
						<tr>
							<td>
								<xsl:value-of select="IRB"/>
							</td>
						</tr>
					</p>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>
	
</xsl:stylesheet>








