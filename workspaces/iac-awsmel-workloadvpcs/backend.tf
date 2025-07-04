terraform {
  cloud {
    organization = "department-of-education-victoria"
    
    workspaces {
      name = "iac-awsmel-workloadvpcs"
    }
  }
}