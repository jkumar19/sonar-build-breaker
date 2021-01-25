#!/bin/bash

set -e

############################################
##### function to display script usage #####
############################################
function usage()
{
    echo "########################################################"
    echo " Usage: $0 "
    echo "    --branch=<GIT_BRANCH> --sonar-token=<SONAR_TOKEN>"
    echo "    --sonar-url=<SONAR_URL> --project-key=<PROJECT_KEY>"
    echo "########################################################"
    exit 0
}

###################################
##### function to exit script #####
###################################
function die()
{
    local message=$1
    [ -z "$message" ] && message="Died"
    echo -e "$message at ${BASH_SOURCE[1]}:${FUNCNAME[1]} line ${BASH_LINENO[0]}." >&2
    exit 1
}

############################################
##### function to check sonar analysis #####
############################################
function sonarAnalysisStatus()
{
    echo "==> validating current analysis status, please wait..."
    sleep 60
    analysisStatus=$(curl -s -u ${SONAR_TOKEN}: "$SONAR_URL/api/ce/activity?component=${PROJECT_KEY}" | jq '.tasks[] | "\(.branch) \(.status)"' | grep "$GIT_BRANCH" | head -1 | awk '{print $NF}')
    analysisStatus=$(echo $analysisStatus  | tr -d "\"\`'")
    [ "$analysisStatus" != "SUCCESS" ] && die "ERROR => sonar analysis for branch $GIT_BRANCH and project $PROJECT_KEY failed, exiting..."
    analysisID=$(curl -s -u ${SONAR_TOKEN}: "$SONAR_URL/api/ce/activity?component=${PROJECT_KEY}" | jq '.tasks[] | "\(.branch) \(.id) \(.analysisId)"' | grep "$GIT_BRANCH" | head -1 | awk '{print $NF}')
    [ -z "$analysisID" ] && die "ERROR => failed to fetch analysis id, exiting..."
    analysisID=$(echo "$analysisID" | tr -d "\"\`'")
    echo "==> current sonar analysis ID for branch $GIT_BRANCH is: $analysisID"
    qualityGatesStatus=$(curl -s -u ${SONAR_TOKEN}: "$SONAR_URL/api/qualitygates/project_status?analysisId=${analysisID}" | jq -r .projectStatus.status)
    [ "$qualityGatesStatus" != "OK" ] && die "ERROR => Quality Gates for branch $GIT_BRANCH and project $PROJECT_KEY failed, exiting..."
    echo "==> Sonar Analysis for branch $GIT_BRANCH and project $PROJECT_KEY passed"
}

for i in "$@"; do                                                  
case $i in                 
  --sonar-url=*)                                                
      SONAR_URL="${i#*=}"                                         
      shift                                                        
      ;;                   
  --project-key=*)                                  
      PROJECT_KEY="${i#*=}"                         
      shift                                         
      ;;                                            
  --sonar-token=*)                                  
      SONAR_TOKEN="${i#*=}"                                                                 
      shift                                                                                         
      ;;                                                                                            
  --branch=*)                                                                                       
      GIT_BRANCH="${i#*=}"                                                                          
      shift                                                                                         
      ;;                                                                                            
  --help)                                                                                           
      usage                                                                                         
      ;;                                                                                            
  *)                                                                                                
      die "$i is not a supported option, exiting..."                                                
      ;;                                                                                            
esac                                                                                                
done                                                                                                
                                                                                                    
[ -z "$SONAR_URL" ] && die "pass SONAR_URL with --sonar-url=<SONAR_URL> switch, exiting...."        
[ -z "$SONAR_TOKEN" ] && die "pass SONAR_TOKEN with --sonar-token=<SONAR_TOKEN> switch, exiting...."                                                                                 
[ -z "$PROJECT_KEY" ] && die "pass PROJECT_KEY with --project-key=<PROJECT_KEY> switch, exiting...."
[ -z "$GIT_BRANCH" ] && die "pass GIT_BRANCH with --branch=<GIT_BRANCH> switch, exiting..."
                                                                                   
sonarAnalysisStatus
