# fdc-crime
## About
Little helpers to collect stats about your code using code-maat. It generates the following code maat reports:
 1) change frequency combined with LOC (hotspot analysis)
 2) coupling of files
 3) complexity (in terms of indendation)
 4) complexity trend for each file (Java only)
 
## Prerequisites:
1) Skim the book "Your code as a crime scene"!
2) Clone code maat (https://github.com/adamtornhill/code-maat) and code maat scripts (https://github.com/adamtornhill/maat-scripts.git)
3) Make sure you can run and build code maat
4) Instal CLOC
 
## Run this script
```
./fdc_crime  <your-projects-dir> <your-result-dir> <path-to-maat-scripts> <file-with-project-names> <path-to-code-maat-jar>
```

