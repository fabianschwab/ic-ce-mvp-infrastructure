terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.75.1"
    }
    curl = {
      source  = "marcofranssen/curl"
      version = "0.7.0"
    }
  }
}
