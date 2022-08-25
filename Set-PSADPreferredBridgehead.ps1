<#
.SYNOPSIS 
Sets the specified DC as the preferred bridgehead server. 

.DESCRIPTION
Sets the specified DC as the preferred bridgehead server. 

.PARAMETER PartnerDC
[string] Specify the DC you wish to make the preferred bridgehead. 

.EXAMPLE
PS> Set-PSADPreferredBridgehead.ps1 -PartnerDC TESTDC01

.NOTES
.COPYRIGHT
Copyright (c) ActiveDirectoryKC.NET. All Rights Reserved

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The website "ActiveDirectoryKC.NET" or it's administrators, moderators, 
affiliates, or associates are not affilitated with Microsoft and no 
support or sustainability guarantee is provided. 

.VERSION  1.0
.LINK
https://github.com/ActiveDirectoryKC/Set-PSADPreferredBridgehead.ps1

#>
param(
    [Parameter(Mandatory=$true,HelpMessage="Changes the specified DC as the preferred bridgehead server.")]
    [string]$PartnerDC
)

$PartnerDCObject = Get-ADDomainController -Filter "Name -eq '$PartnerDC' -or Hostname -eq '$PartnerDC'" # Resolve the PartnerDC parameter.
$ConfigDN = (Get-ADRootDSE -Server $PartnerDCObject.Hostname).configurationNamingContext # Get the Configuration partition DN. 
$IPContainer = (Get-ADObject -Filter "Name -eq 'IP'" -SearchBase $ConfigDN -Server $PartnerDCObject.Hostname).distinguishedName  # Get the IP Container DN
$DCComputerObjectDN = $PartnerDCObject.ComputerObjectDN # Get the PartnerDCObject DN
$DCServerObject = Get-ADObject -LDAPFilter "(&(objectClass=server)(serverReference=$DCComputerObjectDN))" -SearchBase $ConfigDN -Server $PartnerDCObject.Hostname # Get the DC Server Object from config partition.

# Change the preferred bridgehead. 
Set-ADObject -Identity $DCServerObject -Replace @{ "bridgeheadTransportList" = "$IPContainer" } -Server $PartnerDCObject.Hostname