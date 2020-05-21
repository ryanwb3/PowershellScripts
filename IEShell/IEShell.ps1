<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.175
	 Created on:   	5/21/2020 2:30 PM
	 Created by:   	rbley
	 Organization: 	Public Library of Cincinnati and Hamilton County
	 Filename:     	IEShell
	===========================================================================
	.DESCRIPTION
		This script was used to serve a web page in a kiosk form. In our 
		library it serves as a kiosk to search the catalog, apply for a library 
		card, or place a reservation on a computer. There were requirements for 
		different tabs and a quick way to get back to the homepage. The script 
		is used as a logon script in conjunction with removing explorer.exe as 
		the default shell. Various other IE and Windows GPO's are used to lock 
		the machines options from being changed. A Squid proxy is also used to 
		prevent web surfing on these kiosk devices.

		$targetprocess can easily be changed to another browser process like
		chrome or firefox. Note that the start-process $targetprocess may need 
		the full path to your process if the exe is not in your system path
#>

# Variable(s)
$targetprocess = "iexplore"

# Create forever loop
while ($true)
{
	#Grab process if available
	$process = Get-Process -Name $targetprocess
	
	#If the process has yet to be found
	while (!($process))
	{
		#Grab process if available
		$process = Get-Process -Name $targetprocess
		
		#If no process is found
		if (!($process))
		{
			#Start the process
			start-process $targetprocess
		}
		#Sleep before looping again
		start-sleep -s 5
	}
	
	#Process was found
	if ($process)
	{
		#Wait for the process to exit
		$process.WaitForExit()
		
		#Wait before relaunching
		start-sleep -s 2
		
		#Relaunch the Process
		start-process $targetprocess
	}
}


