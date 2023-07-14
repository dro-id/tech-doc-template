/***************************
*** System Model for XXX ***
****************************/
// When your workspace become very large break it into several files and include them

// Context
!constant ORGANISATION_NAME "!Organisation"
!constant ORGANISATION_REPO "https://example.com/"
!constant PLATFORM_NAME "Platform"
!constant PRODUCT_NAME "Product"

// Import common scripts
//!include ${ORGANISATION_REP}/scripts/standard_utils.dsl

// Your system workspace
// TODO: Extend from the global platform  model
//workspace extends "${ORGANISATION_REP}/${PLATFORM_NAME}.dsl" {
workspace {

    !identifiers hierarchical

    model {
    
        properties {
            structurizr.groupSeparator "::"
        }  
        
        group "${ORGANISATION_NAME}::${PLATFORM_NAME}::${PRODUCT_NAME}" {
        
            /************************************************************************************ 
                Person (e.g. a user, actor, role, or persona)
                Try to use the default catalog of user personas of the Organisation
                Define person specific to your application only if required 
            ************************************************************************************/
            //!include ${ORGANISATION_REP}/models/standard_persons.dsl
            
            productUser = person "Specific User"
            
            
            /************************************************************************************
                Software System - Container / Component hierarchy
                Try to use the standard catalog of the organisation systems
                In principle, you should be in a position to add only your system,
                if a dependendable system is missing add it temporarly and we will refactor later
            ************************************************************************************/
            //!include ${ORGANISATION_REP}/models/standard_systems.dsl
            
            // TODO: Add reference to entity defined in the platform through extend
            softwareSystem = softwareSystem "Software System XXX" {
                webapp = container "Web Application"
                database = container "Database"
             }
            
            // Relationnships
            productUser -> softwareSystem.webapp "Uses"
            softwareSystem.webapp -> softwareSystem.database "Reads from and writes to"
            
            
            /************************************************************************************ 
                Deployments
                Tag your resources in https://structurizr.com/help/theme?url=\
                https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json
            ************************************************************************************/
            
            // Production
            prod = deploymentEnvironment "Production" {
                // Groups used to constraint deployment relatioships
                primary = deploymentGroup "Primary Resource Group"
                secondary = deploymentGroup "Secondary Resource Group"
            
                aws = deploymentNode "Amazon Web Services" {
                    
                    // Primary Region
                    primaryRegion = deploymentNode "eu-west-1" {
                    
                        route53 = infrastructureNode "Route 53" {
                            tags "Amazon Web Services - Route 53"
                        }
                        
                        elb = infrastructureNode "Elastic Load Balancer" {
                            tags "Amazon Web Services - Elastic Load Balancing"
                        }
    
                        ec2 = deploymentNode "Amazon EC2" primary {
                            tags "Amazon Web Services - EC2"
                            instance = deploymentNode "Ubuntu Server Instance" {
                                tags "Amazon Web Services - EC2 Instance"
                                webApplicationInstance = containerInstance softwareSystem.webapp primary
                            }
                        }
    
                        rds = deploymentNode "Amazon RDS" {
                            tags "Amazon Web Services - RDS"
                            database = deploymentNode "PostgreSQL" {
                                tags "Amazon Web Services - Aurora PostgreSQL Instance"
                                databaseInstance = containerInstance softwareSystem.database primary
                            }
                        }
                        
                    }
                    
                    // Relationnships
                    primaryRegion.route53 -> primaryRegion.elb "Forwards requests to" "HTTPS"
                    primaryRegion.elb -> primaryRegion.ec2.instance.webApplicationInstance "Forwards requests to" "HTTPS"

                    // Secondary Region
                    secondaryRegion = deploymentNode "eu-central-1" {
                    
                        route53 = infrastructureNode "Route 53" {
                            tags "Amazon Web Services - Route 53"
                        }
                        
                        elb = infrastructureNode "Elastic Load Balancer" {
                            tags "Amazon Web Services - Elastic Load Balancing"
                        }
    
                        ec2 = deploymentNode "Amazon EC2" {
                            tags "Amazon Web Services - EC2"
                            instance = deploymentNode "Ubuntu Server Instance" {
                            tags "Amazon Web Services - EC2 Instance"
                                webApplicationInstance = containerInstance softwareSystem.webapp secondary
                            }
                        }
    
                        rds = deploymentNode "Amazon RDS" {
                            tags "Amazon Web Services - RDS"
                            database = deploymentNode "PostgreSQL" {
                                tags "Amazon Web Services - Aurora PostgreSQL Instance"
                                databaseInstance = containerInstance softwareSystem.database secondary
                            }
                        }
                        
                    }
                    
                    // Relationnships
                    secondaryRegion.route53 -> secondaryRegion.elb "Forwards requests to" "HTTPS"
                    secondaryRegion.elb -> secondaryRegion.ec2.instance.webApplicationInstance "Forwards requests to" "HTTPS"
                
                }
            
            }
            
            // Quality
            ltiq = deploymentEnvironment "Quality" {
                // Specific deployment for the Quality environment
            }
            
            // Development
            dev = deploymentEnvironment "Development" {
                // Specific deployment for the Development environment
            }
        }
    }

// Views to be included with your model
// Kepp the three below, but feel free to add the ones that makes you

    views {
    
        systemContext softwareSystem "SoftwareSystem-SystemContext" {
            include *
            autolayout lr
        }
        
        container softwareSystem "SoftwareSystem-Container" {
            include *
            autolayout lr
        }
        
        component softwareSystem.webapp "SoftwareSystem-Component-WebApp" {
            include *
            autolayout lr
        }
        
        deployment softwareSystem "Production" "SoftwareSystem-Deployment-Production" {
            include *
            autolayout lr
        }
        
    	themes https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json default 
    }

}