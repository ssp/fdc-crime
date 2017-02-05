# fdc-crime
## About
Little helpers to collect stats about your code using [code-maat] (https://github.com/adamtornhill/code-maat).

1. Frequency (revisions per file)
2. Frequency & CLOC (hotspot analysis)
3. Frequency & CLOC & Complexity (compliex hotspot analysis)
4. Coupling
5. Complexity trend for each file (Java only)
6. Churn (lines added, deleted, and commits per day)

## Prerequisites:
1. Skim the book "Your code as a crime scene"
2. Clone code maat (https://github.com/adamtornhill/code-maat) and code maat scripts (https://github.com/adamtornhill/maat-scripts.git)
3. Make sure you can run and build code maat (leiningen needed)
4. Instal CLOC

## Run this script
```
./fdc_crime  <your-projects-dir> <your-result-dir> <path-to-maat-scripts> <file-with-project-names> <path-to-code-maat-jar>
```
