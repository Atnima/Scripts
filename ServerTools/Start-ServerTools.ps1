#requires -version 2
<#
.SYNOPSIS
  OSD and Client Side Scipts that require server processing.

.DESCRIPTION
  This script is designed to process functions that cannot be performed on the client.
  The script is currently designed to complete AD Group Migrations for new PC's.

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         Adam Stevens
  Creation Date:  12/03/2018
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
#. "C:\Scripts\Functions\Logging_Functions.ps1"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\Windows\Temp"
$sLogName = "<script_name>.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Write-XMLFile {
    # Initial script credit to Sathish Nadarajan.
    # Copied and modified by Adam Stevens
    # Source: http://www.sharepointpals.com/post/How-to-Create-XML-Files-as-Output-of-PowerShell-Execution-SharePoint-2013

    Param(
        [parameter(Mandatory=$true)]
        [String]
        $XMLPath,
        [parameter(Mandatory=$true)]
        [String]
        $XMLComment,
    )
    
    # Assign the CSV and XML Output File Paths
    # $XML_Path = "D:\Sathish\Article\Sample.xml"
    # Not required due to the use of the $XMLPath parameter
    
    # Create the XML File Tags

    $xmlWriter = New-Object System.XMl.XmlTextWriter($XMLPath,$Null)
    $xmlWriter.Formatting = 'Indented'
    $xmlWriter.Indentation = 1
    $XmlWriter.IndentChar = "`t"
    $xmlWriter.WriteStartDocument()
    $xmlWriter.WriteComment("$Comment")
    $xmlWriter.WriteStartElement('JobInfo')
    $xmlWriter.WriteEndElement()
    $xmlWriter.WriteEndDocument()
    $xmlWriter.Flush()
    $xmlWriter.Close()

    $xmlDoc = [System.Xml.XmlDocument](Get-Content $XMLPath);
    
    $QueuedJobNode = $xmlDoc.CreateElement("QueuedJob")
    $xmlDoc.SelectSingleNode("//JobInfo").AppendChild($QueuedJobNode)
    
    $JobTypeElement = $QueuedJobNode.AppendChild($xmlDoc.CreateElement("JobType"));
    $JobTypeTextNode = $JobTypeElement.AppendChild($xmlDoc.CreateTextNode("ADGroupMigration"));

    $ExistingPCElement = $QueuedJobNode.AppendChild($xmlDoc.CreateElement("ExistingDevice"));
    $ExistingPCTextNode = $ExistingPCElement.AppendChild($xmlDoc.CreateTextNode("RSSO-108194"));

    $NewPCElement = $QueuedJobNode.AppendChild($xmlDoc.CreateElement("NewDevice"));
    $NewPCTextNode = $NewPCElement.AppendChild($xmlDoc.CreateTextNode("D103818"));

    $JobStatusElement = $QueuedJobNode.AppendChild($xmlDoc.CreateElement("JobStatus"));
    $StatusTextNode = $JobStatusElement.AppendChild($xmlDoc.CreateTextNode("Pending"));

    $xmlDoc.Save($XMLPath)

    

    # $xmlWriter = New-Object System.XMl.XmlTextWriter($XML_Path,$Null)
    # $xmlWriter.Formatting = 'Indented'
    # $xmlWriter.Indentation = 1
    # $XmlWriter.IndentChar = "`t"
    # $xmlWriter.WriteStartDocument()
    # $xmlWriter.WriteComment('Get the Information about the web application')
    # $xmlWriter.WriteStartElement('WebApplication')
    # $xmlWriter.WriteEndElement()
    # $xmlWriter.WriteEndDocument()
    # $xmlWriter.Flush()
    # $xmlWriter.Close()
     
    # Create the Initial  Node
    # $xmlDoc = [System.Xml.XmlDocument](Get-Content $XMLPath);
    # $siteCollectionNode = $xmlDoc.CreateElement("SiteCollections")
    # $xmlDoc.SelectSingleNode("//WebApplication").AppendChild($siteCollectionNode)
    # $xmlDoc.Save($XMLPath)

    # $xmlDoc = [System.Xml.XmlDocument](Get-Content $XMLPath);
    # $siteCollectionNode = $xmlDoc.CreateElement("SiteCollection")
    # $xmlDoc.SelectSingleNode("//WebApplication/SiteCollections").AppendChild($siteCollectionNode)
    # $siteCollectionNode.SetAttribute("Name", "SiteCollectionTitle")
     
    # $subSitesNode = $siteCollectionNode.AppendChild($xmlDoc.CreateElement("SubSites"));
    # $subSitesNode.SetAttribute("Count", "45")
    # $xmlDoc.Save($XMLPath)
     
    # $subSiteNameNode = $subSitesNode.AppendChild($xmlDoc.CreateElement("SubSite"));
    # $subSiteNameNode.SetAttribute("Title", "Web title")
     
    # $ListsElement = $subSiteNameNode.AppendChild($xmlDoc.CreateElement("Lists"));
    # $ListElement = $ListsElement.AppendChild($xmlDoc.CreateElement("List"));
    # $ListElement.SetAttribute("Title", "ListTitle")
     
    # $RootFolderElement = $ListElement.AppendChild($xmlDoc.CreateElement("RootFolder"));
    # $RootFolderTextNode = $RootFolderElement.AppendChild($xmlDoc.CreateTextNode("Root folder Title"));
     
    $xmlDoc.Save($XMLPath)
    
}

<#

Function <FunctionName>{
  Param()
  
  Begin{
    Log-Write -LogPath $sLogFile -LineValue "<description of what is going on>..."
  }
  
  Process{
    Try{
      <code goes here>
    }
    
    Catch{
      Log-Error -LogPath $sLogFile -ErrorDesc $_.Exception -ExitGracefully $True
      Break
    }
  }
  
  End{
    If($?){
      Log-Write -LogPath $sLogFile -LineValue "Completed Successfully."
      Log-Write -LogPath $sLogFile -LineValue " "
    }
  }
}

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
#Script Execution goes here
#Log-Finish -LogPath $sLogFile