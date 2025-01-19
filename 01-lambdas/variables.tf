# Boolean Variable for Anonymous Access
# Determines whether to enable anonymous access to the deployed Cloud Functions (public invocation).
variable "authorization_type" {
  description = "What type of authorization to require on the routes"
  type        =  string  # Data type of the variable (boolean).
  default     =  "AWS_IAM" 
}
