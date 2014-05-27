#!/usr/bin/perl

# Program:	1PasswordBackup
# Homepage:	https://github.com/rmward/1password-backup
# Author:	R. Matthew Ward, http://rmward.com
# About:	This script finds the latest automated backup of 1Password data and copies it
# 			to a user-specified location. Its purpose is to be triggered via launchd on
#			insertion of a certain external drive, or to be triggered at regular intervals
#			to backup to a network/cloud storage location. See accompanying launchd
#			scripts in the GitHub repo. 
# Requires: File::Copy to make file companying easy; File::HomeDir for a relatively
#			portable method for determining a user's home directory.  

use File::Copy;
use File::HomeDir;

# Determine home directory. 
$homeDirectory=File::HomeDir->my_home;
# Use home directory to construct path to the 1Password backups. 
# To-do: Check other systems to see how stable this location is. In particular the hex bit may be variable. 
# Note: This also may change in future 1Password versions.  
$backupDir=$homeDirectory . "/Library/Containers/2BUA8C4S2C.com.agilebits.onepassword-osx-helper/Data/Library/Backups/";

# Get the destination directory from command line arguments. 
$destDir=shift(@ARGV);
# To-do: Some checking/sanitization to make sure this looks like a directory. 

opendir(BACKUP, $backupDir);
# Get a list of files in the backup directory. 
@names=readdir(BACKUP) or die("Unable to read file names in $backupDir: $!");
close(BACKUP);

# Keep track of the newest backup in the directory, based on timestamp in filename. 
$newestdate=0;
$newestfile="";

# Go through each file in the directory. 
foreach $name (@names)
{
	# Match against a pattern to extract time and date stamp. 
	if ($name=~/(\d{4})-(\d{2})-(\d{2}) (\d{2})_(\d{2})_(\d{2})/)
	{
		# Concatenate the time/date digits—OK to treat as integer, as far as I can tell, as digits are listed most to least significant. 
		$datestamp=$1 . $2 . $3 . $4 . $5 . $6;
		# If the concatenated stamp is numerically greater than the newest one we've seen so far. 
		if ($datestamp > $newest)
		{
			# Store it as the newest time stamp and file name. 
			$newestdate=$datestamp;
			$newestfile=$name;
		}
	}
}

# Copy the newest backup file to the destination directory. 
copy($backupDir . $newestfile, $destDir . $newestfile) or die("Unable to copy file: $!");