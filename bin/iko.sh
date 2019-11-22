#!/bin/bash
#
# This bash script (short for import kibana objects) is used to import 
# dashboards and their supporting index-patterns, searches and visualizations.  
# To use this, you must have an ndjson file already built.  Use eko.sh to export
# the dashboards, and all supporting objects, from another system to use here.
#
# NOTE:  This is a kibana API, not an Elasticsearch API - therefore you must 
#        have a working instance of kibana for this to work.

SCRIPTNAME=$0
KIBANA_HOST="127.0.0.1"
PORT="5601"
INFILE=""
PARAMS=""

function usage {
    printf "\n$(tput setaf 9)Usage$(tput sgr 0):\n"
    printf "$SCRIPTNAME -i|--infile <string> [-h|--hostname <string>] [-p|--port <string>]\n  "
    printf "  -i|--infile: $(tput setaf 6)required$(tput sgr 0) name of file to import\n   "
    printf " -h|--host:   $(tput setaf 3)optional$(tput sgr 0) IP/hostname of Kibana server - default is localhost\n   "
    printf " -p|--port:   $(tput setaf 3)optional$(tput sgr 0) Port of Kibana server - default is 5601\n\n   "
    
    exit 1
}

while (( "$#" )); do
  case "$1" in
    -h|--host)
      KIBANA_HOST=$2
      shift 2
      ;;
    -p|--port)
      PORT=$2
      shift 2
      ;;
    -i|--infile)
      INFILE=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      printf "\n$(tput setaf 9)ERROR$(tput sgr 0): Unsupported flag $1, exiting\n" >&2
      usage
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
eval set -- "$PARAMS"

# Check to make sure the kibana server is up
until nc -zw 1 $KIBANA_HOST $PORT; do sleep 1; done

if [ $INFILE == "" ]; then
    printf "\n Must specify the name of the file to import\n"
    usage
elif [ ! -f $INFILE ]; then
    printf "\n The file $INFILE does not exist, please check the name and try again\n"
    usage
else
    printf "\nImport objects from $INFILE\n"
    curl -X POST "localhost:5601/api/kibana/dashboards/import" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d @$INFILE
fi