#Handmade by Galaad Martineaux
#FORMAT: $folder = '.\path\to\folder'
$folder_include = '.\include'
$folder_libs = '.\libs'
$folder_objects = '.\objects'
$folder_source = '.\src'
$folder_runtime = '.\runtime'
$exe_name = 'test.exe' #FORMAT: test.exe
$compiler = 'g++.exe'
$compilation_arguments = '-L.\libs -L./libs/libglfw3.a -lglfw3 -lgdi32 -lstdc++ -lopengl32 '

if ($args -contains "-help") {
	Write-Output "Help - make.ps1 (by Galaad Martineaux)"
	Write-Output "	.\make.ps1			| Will compile according to the script"
	Write-Output "	.\make.ps1 -Debug	| Displays compiling commands "
	Write-Output "	.\make.ps1 -run		| Runs the file after compiling."
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
$subIncludeFolders = Get-ChildItem -Path $folder_include -Directory -Recurse
$subIncludeFolders = $subIncludeFolders | ForEach-Object {
    $newFullName = $_.FullName.Replace($currentDirectory, ".")
    New-Object System.IO.FileInfo -ArgumentList $newFullName
}

foreach ($sub in $subIncludeFolders) {
	$folder_include += " -I$sub";
}



#STEP 3: COMPILE EVERY .CPP FILE IN AN .OBJ OBJECT FILE INTO THE OBJECT FOLDER
foreach ($file in $cppFiles) {
	$outputName = "$folder_objects\" + $file.BaseName + ".obj"
	$command = "$compiler " + $file + " -I$folder_include $compilation_arguments -c -o " + $outputName
	Write-Output "Compiling $file..."
	
	Write-Debug "Command: $command"
	
	Invoke-Expression $command
	if ($LASTEXITCODE -ne 0) { Exit }
}

#STEP 4: FIND EVERY .CPP FILE IN SOURCE FOLDERS AND SUBFOLDERS
$cppFiles = Get-ChildItem -Path $folder_source -Filter "*.cpp" -File -Recurse | Resolve-Path -Relative
$cppFiles = $cppFiles | ForEach-Object {
	$newFullName = $_.Replace($currentDirectory, ".")
	New-Object System.IO.FileInfo -ArgumentList $newFullName
}

#STEP 5: COMPILE EVERY .CPP FILE IN AN .OBJ OBJECT FILE INTO THE OBJECT FOLDER
foreach ($file in $cppFiles) {
	$outputName = "$folder_objects\" + $file.BaseName + ".obj"
	$command = "$compiler " + $file + " -I$folder_include $compilation_arguments -c -o " + $outputName
	Write-Output "Compiling $file..."
	
	Write-Debug "Command: $command"
	
	Invoke-Expression $command
	if ($LASTEXITCODE -ne 0) { Exit }
}

#STEP 6: FIND EVERY .OBJ FILE IN OBJECTS FOLDER
$objFiles = Get-ChildItem -Path $folder_objects -Filter "*.obj" -File | Resolve-Path -Relative
$objFiles = $objFiles | ForEach-Object {
	$newFullName = $_.Replace($currentDirectory, ".")
	New-Object System.IO.FileInfo -ArgumentList $newFullName
}

#STEP 7: COMPILE THEM ALL INTO AN EXECUTABLE
$command = "$compiler  -o $folder_runtime\$exe_name $compilation_arguments"
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
