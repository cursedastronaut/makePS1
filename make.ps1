#Handmade by Galaad Martineaux
#FORMAT: $folder = 'path\to\folder'
$folder_include = 'include', 'headers'
$folder_libs = 'libs'
$folder_objects = 'objects'
$folder_source = 'src', 'src2'
$folder_runtime = '.'
$exe_name = 'test.exe' #FORMAT: test.exe
$compiler = 'g++.exe'
$compilation_arguments = ''

if ($args -contains "-help") {
	Write-Output "Help - make.ps1 (by Galaad Martineaux)"
	Write-Output "	.\make.ps1			| Will compile according to the script"
	Write-Output "	.\make.ps1 -Debug	| Displays compiling commands "
	Write-Output "	.\make.ps1 -run		| Runs the file after compiling."
	Write-Output "	.\make.ps1 -obj		| Compiles only up to the object step."
	Write-Output ""
	Exit
}

#Please refrain from editing further from this
$currentDirectory = (Get-Location).Path


#STEP 1: FIND EVERY .CPP FILE IN INCLUDE FOLDERS AND SUBFOLDERS

$cppFiles = Get-ChildItem -Path $folder_include -Filter "*.cpp" -File -Recurse | Resolve-Path -Relative
$cppFiles = $cppFiles | ForEach-Object {
	$newFullName = $_.Replace($currentDirectory, ".")
	New-Object System.IO.FileInfo -ArgumentList $newFullName
}

#STEP 2: FIND EVERY SUBFOLDER IN INCLUDE FOLDER, TO INCLUDE THEM
$subIncludeFolders = foreach ($tempdir in $folder_include) {
    Get-ChildItem -Path $tempdir -Directory -Recurse
}
$subIncludeFolders = $subIncludeFolders | ForEach-Object {
    $newFullName = $_.FullName.Replace($currentDirectory, ".")
    New-Object System.IO.FileInfo -ArgumentList $newFullName
}

foreach ($sub in $subIncludeFolders) {
	$folder_include_new += " -I$sub";
}
foreach ($tempdir in $folder_include) {
	$folder_include_new += " -I$tempdir";
}

#STEP 3: COMPILE EVERY .CPP FILE IN AN .OBJ OBJECT FILE INTO THE OBJECT FOLDER
foreach ($file in $cppFiles) {
	$outputName = "$folder_objects\" + $file.BaseName + ".obj"
	$command = "$compiler " + $file + " $folder_include_new $compilation_arguments -c -o " + $outputName
	Write-Output "Compiling $file..."
	
	if ($args -contains "-Debug") {
		Write-Host "Command: $command" -ForegroundColor Blue
	}
	
	Invoke-Expression $command
	if ($LASTEXITCODE -ne 0) { Exit }
}

#STEP 4: FIND EVERY .CPP FILE IN SOURCE FOLDERS AND SUBFOLDERS
$cppFiles = foreach ($tempdir in $folder_source) {
	Get-ChildItem -Path $tempdir -Filter "*.cpp" -File -Recurse | Resolve-Path -Relative
}
$cppFiles = $cppFiles | ForEach-Object {
	$newFullName = $_.Replace($currentDirectory, ".")
	New-Object System.IO.FileInfo -ArgumentList $newFullName
}

#STEP 5: COMPILE EVERY .CPP FILE IN AN .OBJ OBJECT FILE INTO THE OBJECT FOLDER
foreach ($file in $cppFiles) {
	$outputName = "$folder_objects\" + $file.BaseName + ".obj"
	$command = "$compiler " + $file + " $folder_include_new $compilation_arguments -c -o " + $outputName
	Write-Output "Compiling $file..."
	
	if ($args -contains "-Debug") {
		Write-Host "Command: $command" -ForegroundColor Blue
	}
	
	Invoke-Expression $command
	if ($LASTEXITCODE -ne 0) { Exit }
}

if ($args -contains "-obj") {
	Write-Output "Done."
	if ($args -contains "-run") {Write-Warning "-run ignored as -obj was specified." }
	Exit
}

#STEP 6: FIND EVERY .OBJ FILE IN OBJECTS FOLDER
$objFiles = Get-ChildItem -Path $folder_objects -Filter "*.obj" -File | Resolve-Path -Relative
$objFiles = $objFiles | ForEach-Object {
	$newFullName = $_.Replace($currentDirectory, ".")
	New-Object System.IO.FileInfo -ArgumentList $newFullName
}

#STEP 7: COMPILE THEM ALL INTO AN EXECUTABLE
#g++ [includes] [libs] [objects] [arguments] [name]
$command = "$compiler $folder_include_new -L$folder_libs"
foreach ($file in $objFiles) {
	$command += " $file"
}
$command += " $compilation_arguments  -o $folder_runtime\$exe_name"

if ($args -contains "-Debug") {
	Write-Host "Command: $command" -ForegroundColor Blue
}

Write-Output "Compiling $folder_runtime\$exe_name..."
Invoke-Expression $command

if ($LASTEXITCODE -ne 0) { Exit }
Write-Output "Done."
if ($args -contains "-run") {
	Write-Output "________________"
	Write-Output ""
	Invoke-Expression "$folder_runtime\$exe_name"
}
