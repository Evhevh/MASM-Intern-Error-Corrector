# MASM Intern Error Corrector

This project is an x86 Assembly program for correcting and reversing a series of temperature readings stored in an ASCII-formatted file. It reads the file, parses the temperatures, and prints them in reverse order, separated by a delimiter.

## Features

- Reads ASCII-formatted temperature data from a file
- Parses and stores the data as integers
- Prints the temperatures in reverse order
- Handles file errors gracefully

## Build & Run

1. Open the solution (`Project.sln`) in Visual Studio with MASM support.
2. Build the project (Debug or Release).
3. Run the resulting executable (`Project.exe`).
4. When prompted, enter the name of the file containing the temperature data (e.g., `Temps090124.txt`).

## File Format

The input file should contain comma-separated integer values, e.g.:
```
-3,-2,0,3,7,10,15,20,25,30,35,40,45,42,38,34,30,25,20,15,10,5,2,-1,
```

## Author

Ethan Van Hao  
CS271 Section 402, Oregon State University
