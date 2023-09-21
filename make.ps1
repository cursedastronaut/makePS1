#Handmade by Galaad Martineaux
#FORMAT: $folder = '.\path\to\folder'
$folder_header = '.\headers'
$folder_include = '.\include'
$folder_objects = '.\objects'
$folder_source = '.\src'
$folder_runtime = '.\runtime'
$exe_name = 'test.exe' #FORMAT: test.exe
$compiler = 'g++'

#Please refrain from editing further from this
$currentDirectory = (Get-Location).Path

#STEP 1: FIND EVERY .CPP IN SOURCE FOLDER
$cppFiles = Get-ChildItem -Path $folder_source -Filter "*.cpp" -File | Resolve-Path -Relative
$cppFiles = $cppFiles | ForEach-Object {
	$newFullName = $_.Replace($currentDirectory, ".")
	New-Object System.IO.FileInfo -ArgumentList $newFullName
}

#STEP 2: COMPILE EVERY .CPP FILE IN AN .OBJ OBJECT FILE INTO THE OBJECT FOLDER
foreach ($file in $cppFiles) {
	$outputName = "$folder_objects\" + $file.BaseName + ".obj"
	$command = "$compiler " + $file + " -I$folder_header -I$folder_include -c -o " + $outputName
	Write-Output "Compiling $file..."
	
	Write-Debug "Command: $command"
	
	Invoke-Expression $command
	if ($LASTEXITCODE -ne 0) { Exit }
}

#STEP 3: FIND EVERY .OBJ FILE IN OBJECTS FOLDER
$objFiles = Get-ChildItem -Path $folder_objects -Filter "*.obj" -File | Resolve-Path -Relative
$objFiles = $objFiles | ForEach-Object {
	$newFullName = $_.Replace($currentDirectory, ".")
	New-Object System.IO.FileInfo -ArgumentList $newFullName
}

#STEP 4: COMPILE THEM ALL INTO AN EXECUTABLE
$command = "$compiler -o $folder_runtime\$exe_name"
foreach ($file in $objFiles) {
	$command += " $file"
}

Write-Debug "Command: $command"

Write-Output "Compiling $folder_runtime\$exe_name"
Invoke-Expression $command

if ($LASTEXITCODE -ne 0) { Exit }
if ($args -contains "-run") {
	Invoke-Expression "$folder_runtime\$exe_name"
}