#Set system parameters
$env:Path += ";C:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3"; <# System variable to the folder containing the python executable #>
$env:PATHEXT += ";.py";

#Update the dates
$assignments_csv = $PSScriptRoot + "\assignment.csv" <# set relative path to the assignments csv, in same folder as this #> 
$csv = import-csv $assignments_csv <# grab CSV data as a hierarchical object #>
$csv | foreach-object { <# for each row of the CSV data... #>
	$_.Due_Date = ([datetime]($(Get-date).AddDays(3))).ToString('%M/%d/yyyy %h:mm:ss') <# add 2 weeks to the current date and replace in the due date column of csv #>
}
$csv | select-object * | export-csv -notype $assignments_csv <# Exports the CSV with updated due dates, todays date plus 2 weeks #>

#Delete all assignments
$log_file = $PSScriptRoot + "\log.txt" <# set relative path to the assignments csv, in same folder as this #> 
$delete_assignments = $PSScriptRoot + "\delete_assignments_by_query.py" <# set relative path to delete assignments script, in same folder as this script #> 
& python.exe $delete_assignments <# execute delete assignments script #>`
	-u operations_epug <# dispatcher username#> `
	-p T3amEsr1 <# dispatcher password#> `
	-url "https://org.maps.arcgis.com" <# AGOL URL #> `
	-pid "ProjectID" <# Workforce Project ID #> `
	-logFile $log_file <# Log file on your system, will create if not already existing #> `
	-where "1=1" <# 1 equals 1, delete all #>
	
#Create assignments from CSV
$create_assignments = $PSScriptRoot + "\create_assignments_from_csv.py" <# set relative path to create assignments script, in same folder as this #> 
& python.exe $create_assignments <# Execute the create assignment from csv file located in same folder #> `
	-csvFile $assignments_csv <# Location of the csv which has the assignments information #>`
	-u dispatcher_username  <# dispatcher username #>`
	-p dispatcher_password <# dispatcher password#> `
	-url "https://org.maps.arcgis.com" <# AGOL URL #> `
	-pid "ProjectID" <# Workforce Project ID #> `
	-xField "xField" <# field name for the X coordinates #> `
	-yField "yField" <# field name for the Y coordinates #> `
	-assignmentTypeField "Type" <# field name for the assignment type #> `
	-locationField "Location" <# field name for the location description #> `
	-descriptionField "Description" <# field name for the description of the assignment #> `
	-priorityField "Priority" <# field name for the priority level #> `
	-workOrderIdField "Work_Order_Id" <# field name for the work order ID #> `
	-workerField "workerField" <# field name for the worker ID #> `
	-dueDateField "Due_Date" <# field name for the due date of the assignment #> `
	-attachmentFileField "Attachment" <# field name for any attachment to include for project #> `
	-logFile $log_file <# location of log file, same from earlier #> `
	-timezone "US/Eastern" <# Time zone #>