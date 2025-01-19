variable "authorization_type" {
  description = "What type of authorization to require on the routes"
  type        =  string
#  default     =  "AWS_IAM"
  default     = "NONE" 
}
