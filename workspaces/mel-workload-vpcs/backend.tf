terraform {
  cloud {
    organization = "department-of-education-victoria"
    
    workspaces {
      name = "mel-workload-vpcs"
    }
  }
}