# make.ps1 - What is it ?
``make.ps1`` is a PowerShell script that can help with compiling C++, or C programs. (Made to work with GCC)

To use it, download it and edit the first variables so they represent your project.

# How to use it - Examples
### 0 - Arguments
To summon the help, just type ``make.ps1 -help``. It will override every other argument.

- ``-help``     - Displays the help prompt.
- ``-run``      - Runs the executable file compiled after compilation. (No ``-obj``).
- ``-Debug``    - Displays compiling commands.
- ``-obj``      - Compiles into objects, but does not compile the final executable. 
### 1 - Directories
Let's assume this is your project directories:
```powershell
.\headers\
.\externals
    src\
        helloworld.cpp
    include\
        helloworld.h
.\libs\
    libstandard.a
.\objects\
.\runtime\
    final_executable.exe
.\src\
    main.cpp
    main.h
    foo.cpp
```
The beginning of make.ps1 would be:
```ps1
$source_file_ext = "cpp"
$folder_include = 'externals\include'
$folder_libs = 'libs'
$folder_objects = 'objects'
$folder_source = 'src', 'externals\src'
$folder_runtime = 'runtime'
$exe_name = 'final_executable.exe' #FORMAT: test.exe
$compiler = 'g++.exe'
$compilation_arguments = '-lstandard'
```
#### Notes
Compiled executable will be written in ``.\runtime\`` under the name ``final_executable.exe``.

Files are compiled as objects in ``.\objects\``.

## Credits
Made by [cursedastronaut](https://github.com/cursedastronaut).
Tested with MinGW-W64 GCC/G++ 12.2.0.

Feel free to edit, as long as you credit.