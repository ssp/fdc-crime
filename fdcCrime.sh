#!/bin/bash
set -e
# 
# ABOUT:
# This is a simple bash script that generates the following code maat reports:
# 1) change frequency combined with LOC (hotspot analysis)
# 2) coupling of files
# 3) complexity (in terms of indendation)
# 4) complexity trend for each file (Java only)
# 
# PREREQUISITES:
# 1) Skim the book "Your code as a crime scene"!
# 2) Clone code maat (https://github.com/adamtornhill/code-maat) and code maat scripts (https://github.com/adamtornhill/maat-scripts.git)
# 3) Make sure you can run and build code maat
# 4) Instal CLOC
# 
# RUN THIS SCRIPT
# ./fdc_crime  <your-projects-dir> <your-result-dir> <path-to-maat-scripts> <file-with-project-names> <path-to-code-maat-jar>

function run_code_maat_analysis {
    echo "Running code maat analysis $1 $2 $3"
    java -jar $PATH_TO_CODE_MAAT_JAR -l $1 -c git -a $2 > $3
}
#where are your projects?
BASE_PATH=$1 
#where should the script write results to?
RESULTS_DIR=$2 
#where are the maat scripts?
SCRIPTS_DIR=$3 
#which projects?
#PROJECTS=
readarray PROJECTS < $4 
PATH_TO_CODE_MAAT_JAR=$5 #where to find code-maat?

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ];
then
    echo "Please supply arguments BASE_PATH, RESULT_DIR, SCRIPTS_DIR, PROJECTS, and PATH_TO_CODE_MAAT_JAR"
    exit
fi

mkdir -p ${RESULTS_DIR}


while read -r line; do
    PROJECT="$line"
    echo "Processing project $PROJECT"

    PROJECT_RESULT_DIR=${RESULTS_DIR}/${PROJECT}
    mkdir -p ${PROJECT_RESULT_DIR}
    EVO_LOG="${PROJECT_RESULT_DIR}/${PROJECT}_evo.log"
    CLOC_LOG="${PROJECT_RESULT_DIR}/${PROJECT}_cloc.csv"
    echo "$CLOC_LOG"
    FREQ_LOG="${PROJECT_RESULT_DIR}/${PROJECT}_freq.csv"
    CHURN_LOG="${PROJECT_RESULT_DIR}/${PROJECT}_churn.csv"
    COUPLING_LOG="${PROJECT_RESULT_DIR}/${PROJECT}_coupling.csv"
    COMP_FREQ_LOG="${PROJECT_RESULT_DIR}/${PROJECT}_comp_freq.csv"
    COMP_FREQ_COMPL_LOG="${PROJECT_RESULT_DIR}/${PROJECT}_comp_freq_compl.csv"

    cd ${BASE_PATH}/${PROJECT}/
    echo `pwd` 
    echo "Running git log for project $PROJECT"
    echo "$EVO_LOG"
    git log --pretty=format:'[%h] %an %ad %s' --date=short --numstat --before=2016-03-20 > ${EVO_LOG}

    echo "Running CLOC for $PROJECT"
    cloc  ./ --by-file --csv --report-file=${CLOC_LOG}
    
    run_code_maat_analysis ${EVO_LOG} revisions ${FREQ_LOG}
    run_code_maat_analysis ${EVO_LOG} abs-churn ${CHURN_LOG}
    run_code_maat_analysis ${EVO_LOG} coupling ${COUPLING_LOG}
    python ${SCRIPTS_DIR}/merge/merge_comp_freqs.py ${FREQ_LOG} ${CLOC_LOG} > ${COMP_FREQ_LOG} 
    
    INPUT=${COMP_FREQ_LOG}
    OLDIFS=$IFS
    IFS=,
    [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
    echo 'Module,Revisions,Code,n,total,mean,sd,max' > "${COMP_FREQ_COMPL_LOG}"
    while read module revisions code
    do
        if [[ "$module" == *.java ]]
        then
         COMPLEXITY=$(python ${SCRIPTS_DIR}/miner/complexity_analysis.py $module |sed -n 2p)
         COMPLEXITY_CSV=$(echo ${COMPLEXITY} | sed -e "s/\t/,/g")
         echo $COMPLEXITY_CSV
         echo "$module,$revisions,$code,$COMPLEXITY_CSV"  >> "${COMP_FREQ_COMPL_LOG}"
         GIT_FIRST=$(git log --pretty=format:%H | tail -1)
         GIT_HEAD=$(git rev-parse HEAD)
         COMPLEXITY_HISTORY_LOG=$(echo "${PROJECT_RESULT_DIR}/${PROJECT}/$module" | sed "s/.*\///")
         cd ${BASE_PATH}/${PROJECT}/
         mkdir -p ${PROJECT_RESULT_DIR}/trend
         python ${SCRIPTS_DIR}/miner/git_complexity_trend.py --start ${GIT_FIRST} --end ${GIT_HEAD} --file $module > "${PROJECT_RESULT_DIR}/trend/$COMPLEXITY_HISTORY_LOG.trend"
        fi
    done < $INPUT
    IFS=$OLDIFS
    sed -i 's/ /,/g' ${COMP_FREQ_COMPL_LOG}
done < "$4"
