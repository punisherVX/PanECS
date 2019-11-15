#!/usr/bin/env bash

ELASTICSEARCH_HOST="127.0.0.1"
PORT="9200"
PARAMS=""

while (( "$#" )); do
  case "$1" in
    -h|--host)
      ELASTICSEARCH_HOST=$2
      shift 2
      ;;
    -p|--port)
      PORT=$2
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


# Check to make sure we can get to Elasticsearch or all of this is moot
printf "\n\n--- CHECKING ELASTICSEARCH CONNECTIVITY ---\n"
curl $ELASTICSEARCH_HOST:$PORT >/dev/null 2>&1
if [ $? -eq 0 ]; then
    printf "    * $(tput setaf 10)Elasticsearch is up and running$(tput sgr 0)\n"
else
    printf "    - There is no connection to Elasticsearch, exiting\n"
    exit 7
fi

printf "\n\n--- INSTALLING TEMPLATE MAPPINGS ---\n"
printf "\n$(tput setaf 6)Installing af-details mapping$(tput sgr 0)\n"
curl -XPUT -H'Content-Type: application/json' \
    'http://localhost:9200/af-details/' \
    -d @./elasticsearch/mappings/af-details.json

printf "\n\n$(tput setaf 6)Installing threat mapping$(tput sgr 0)\n"
curl -XPUT -H'Content-Type: application/json' \
    'http://localhost:9200/_template/threat?pretty' \
    -d @./elasticsearch/mappings/threat_template_mapping.json

printf "\n$(tput setaf 6)Installing domain detail mapping$(tput sgr 0)\n"
curl -XPUT -H'Content-Type: application/json' \
    'http://localhost:9200/sfn-domain-details/' \
    -d @./elasticsearch/mappings/sfn-domain-details.json

printf "\n\n$(tput setaf 6)Installing tag mapping$(tput sgr 0)\n"
curl -XPUT -H'Content-Type: application/json' \
    'http://localhost:9200/sfn-tag-details/' \
    -d @./elasticsearch/mappings/sfn-tag-details.json