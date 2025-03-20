resource "aws_db_parameter_group" "mysql_pg" {
  name   = "mysql-pg"
  family = "mysql8.0"  

  description = "MySQL RDS Parameter Group"

  parameter {
    name  = "max_connections"
    value = "200" 
  }

  parameter {
    name  = "slow_query_log"
    value = "1" 
  }

  parameter {
    name  = "long_query_time"
    value = "2"  
  }

  parameter {
    name  = "log_output"
    value = "FILE"  
  }
}
