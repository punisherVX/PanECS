#!/bin/bash
#
# This bash script (short for export kibana objects) is used to export all 
# dashboards and their supporting index-patterns, searches and visualizations.  
#
# If you only want to export particular items, meaning not EVERYTHING, then see
# the following links:
#   https://www.elastic.co/guide/en/kibana/current/dashboard-api-export.html 
#   https://www.elastic.co/guide/en/kibana/current/saved-objects-api-export.html
#
# NOTE:  This is a kibana API, not an Elasticsearch API - therefore you must 
#        have a working instance of kibana for this to work.

KIBANA_HOST="127.0.0.1"
PORT="5601"
OUTFILE="dashboards-export-$(date +'%Y%m%d%H%M').json"
PARAMS=""

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
    -o|--outfile)
      OUTFILE=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      printf "\n$(tput setaf 9)ERROR$(tput sgr 0): Unsupported flag $1, exiting\n" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
eval set -- "$PARAMS"

# This was relatively easy to figure out - heh
DASH_LIST=$(sed -e 's/^"//' -e 's/"$//' <<<`curl -s http://localhost:9200/.kibana/_search?pretty |grep '_id" : "dashboard:' |awk -F[:,] {'print $3'}`)

for DASH in $DASH_LIST
do
    curl -XGET -H'Content-Type: application/json' \
         http://$KIBANA_HOST:$PORT/api/kibana/dashboards/export?dashboard=$DASH >>$OUTFILE
done
