# ELK (Elasticsearch-Logstash-Kibana) Stack Project

## Prerequisites

## Introduction

## Vagrant and VMs

## Ansible Provisioning

## Packer Image Building

## Terraform

## TODO and Iteration
* [ ] Separate the Vagrantfile to create two machines to be closer to the end product on AWS
	* [ ] (one with ELK stack and one with just beats)
* [ ] AWS Account To Run Packer/Terraform
* [ ] Terraform:
	* [ ] IAM profiles
	* [ ] Cloudwatch and VPC Endpoint
	* [ ] Generate SSL certificate with AWS Certificate Manager
	* [ ] Use the aforementioned certificate in multiple target groups to redirect to ASG
* [ ] Authentication for ELK
	* [ ] TLS
	* [ ] Password for Elastic
