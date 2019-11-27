# **PanECS**  

PanECS (_pronounced "panex"_) is an [Elastic Common Schema](https://www.elastic.co/blog/introducing-the-elastic-common-schema) implementation for gathering all logging information from the Palo Alto Networks Next Generation Firewall and the Traps application. By adhering to the standards of the ECS, these logs can be used in an ECS based Elasticsearch implementation and utilized to perform searches against, and create visualizations for, common data from differing vendors/hosts/apps/device-types all within the same context.    

This repository includes:
- A docker-compose file that can be used to implement a containerized [ELK stack](https://www.elastic.co/webinars/introduction-elk-stack) if you don't already have one
- A Logstash [configuration file](install/logstash/palo-alto-networks.conf) that will ingest, filter/dissect and enrich events from both the NGFW and Traps.
- Elasticsearch [mappings](https://github.com/PaloAltoNetworks/PanECS/install/elasticsearch/mappings) for each of the log event types from the NGFW and Traps.
- Kibana example vizualizations and dashboards that display information from the different log types.


For more information on each of the above, details of each and installation notes see the [Wiki](https://github.com/PaloAltoNetworks/PanECS/wiki) or follow the links below if they align with what you are looking for:


