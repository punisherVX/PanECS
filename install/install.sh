#!/usr/bin/env bash

ELASTICSEARCH_HOST="127.0.0.1"
PORT="9200"
LOGSTASH_HOST="127.0.0.1"
DIRECTORY="docker"
INDEX_PATTERN_GO=0
PARAMS=""

while (( "$#" )); do
  case "$1" in
    -e|--ehost)
      ELASTICSEARCH_HOST=$2
      shift 2
      ;;
    -p|--port)
      PORT=$2
      shift 2
      ;;
    -l|--lhost)
      LOGSTASH_HOST=$2
      shift 2
      ;;
    -c|--logstash_config)
      DIRECTORY=$2
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


#
#  Install all of the template mappings into Elasticsearch
#
printf "\n\n--- INSTALLING TEMPLATE MAPPINGS ---\n"
FILES=./elasticsearch/mappings/*_template.json

for MAP_FILE in $FILES
do
  NAME=`echo $MAP_FILE |awk -F'[/_]' '{print $4}'`
  printf "\n$(tput setaf 6)Installing $NAME mappings$(tput sgr 0)\n"
  curl -XPUT -H'Content-Type: application/json' \
    http://$ELASTICSEARCH_HOST:$PORT/_template/$NAME?pretty \
    -d @./$MAP_FILE
done

# 
# Copy the logstash conf file over to the local install if that's what we are using
#
if [ "$DIRECTORY" != "docker" ]; then
    printf "\n$(tput setaf 6)Copying config file to /etc/logstash/$DIRECTORY$(tput sgr 0)\n"
    sudo cp logstash/palo-alto-networks.conf /etc/logstash/$DIRECTORY/
fi

#
#  Check the template mappings and set up for installing index patterns and 
#  dashboards
# 
printf "\n\n--- CHECKING TEMPLATE MAPPINGS ---\n"

# Check to make sure that the threat and traffic index templates exist
curl -I http://$ELASTICSEARCH_HOST:$PORT/_template/panw-threat |grep "HTTP/1.1 200"

# If the return code from grep is not 0 then that means it doesn't exist.  
if [ $? -eq 0 ]; then
    printf "    * $(tput setaf 10)Threat mappings properly installed$(tput sgr 0)\n"
    curl -I http://$ELASTICSEARCH_HOST:$PORT/_template/panw-threat |grep "HTTP/1.1 200"
    INDEX_PATTERN_GO=1
    
    # Create a dummy document so the panw-threat index gets created
    echo "bogus,bogus,bogus,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,," > /dev/udp/$LOGSTASH_HOST/5551
    
    # Now check traffic template
    curl -I http://$ELASTICSEARCH_HOST:$PORT/_template/panw-traffic |grep "HTTP/1.1 200"
    
    if [ $? -eq 0 ]; then
        printf "    * $(tput setaf 10)Traffic mappings properly installed$(tput sgr 0)\n"
        # Create a dummy document so the panw-traffic index gets created
        echo "bogus,bogus,bogus,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,," > /dev/udp/$LOGSTASH_HOST/5550
    else
        printf "    === $(tput setaf 9)[WARNING]$(tput sgr 0) There is a problem with the traffic mappings"
        printf "but we can still continue. Please check when installation is done ===\n\n"
    fi
else
    printf "    === $(tput setaf 9)[WARNING]$(tput sgr 0) There is a problem with the mappings"
    printf "so we will not install the index-patterns or dashboards. Please troubleshoot when installation is done ==="
    INDEX_PATTERN_GO=0
    
fi

# 
# Install dummy data to create the indexes

printf "\n\n--- SETTING UP INDEXES ---\n"

if [ $INDEX_PATTERN_GO == 1 ]; then
    curl -X POST -H 'kbn-xsrf: true' http://localhost:5601/api/saved_objects/_import --form file=@.elasticsearch/assets/dashboards.ndjson
else
    printf "    === $(tput setaf 9)[WARNING]$(tput sgr 0) Skipping installation of dashboards and index-patterns ===\n"
fi

