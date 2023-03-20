##################################################################################
# VARIABLES
##################################################################################

variable "region" {default = "eu-west-2"}


variable "win_amis" {
    type = map(string) 
    default = { 
        eu-west-2 = "ami-0d850e86c113a7ae1"
        eu-west-1 = "ami-024c9f52099a0575d"     
    }
}

variable "http_port" {default = 80}
variable "http_port_win" {default = 8080}
variable "https_port" {default = 443}
variable "aurora_db_port" {default = 3306}
variable "reach_api_autoscale_min_instances" {default = "5"}
variable "reach_api_autoscale_max_instances" {default = "8"}

variable "network_address_space" {type = map(string)}
// variable "db_credentials" {type = map(string)}

#####################################################
#                   RDS Scaling
#####################################################
// variable "reach_rds_max_capacity" {default = 8}
// variable "reach_rds_min_capacity" {default = 1}
// variable "mysql_max_connections" {default = 1000}
// variable "slowquerytime" {default=2}
variable "subnet_count" {type = map(number)}
// variable "max_connections_percent" {default = 100}
// variable "connection_borrow_timeout" {default = 120}
// variable "idle_client_timeout" {default = 1800}

// variable "rds_timeout" {default=10000}
// variable "rds-secrets-arn" {default = "arn:aws:secretsmanager:eu-west-1:"}



