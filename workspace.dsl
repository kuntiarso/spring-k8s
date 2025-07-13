workspace {
    !identifiers hierarchical
    model {
        client = softwareSystem "Client" "A Front-End or Mobile App or API Client with ability to trigger a request" "Client"
        randommer = softwareSystem "Randommer API" "Zero-cost public API(s) for creating random numbers, validating phone numbers, etc" "Randommer"
        backend = softwareSystem "Springk8s System" "Allows a client to generate or validate phone numbers" "Kubernetes - ns, Big" {
            pv = container "PV" "Actual storage like disk or cloud volume to store database data" "PV" "Kubernetes - pv"
            pvc = container "PVC" "Allows databases to claim storage resources" "PVC" "Kubernetes - pvc"
            database = container "Database" "Reads and writes generated phone numbers data into mounted path" "MySQL" "Kubernetes - pod, Database"
            pvc -> pv "Stores data to physical storage disks"
            pvc -> database "Mounted to database"
            commonservice = container "Common Service" "Provides business logic to generates and validates phone numbers via RESTful API" "Spring Boot" "Kubernetes - pod, Big" {
                group "Resource" {
                    phoneController = component "PhoneController" "Allows clients to generate or validate phone numbers" "Java" "Code"
                    phoneHandler = component "PhoneHandler" "Provides orchestration to fetch and save phone numbers" "Java" "Code"
                }
                group "Core" {
                    clientAdapter = component "PhoneClientAdapter" "Bridges orchestrators to send request to external API" "Java" "Code"
                    persistenceAdapter = component "PhonePersistenceAdapter" "Bridges orchestrators to send request to DB" "Java" "Code"
                }
        
                group "Adapter" {
                    feignClient = component "PhoneFeignClient" "Provides functionality to communicates with external API" "OpenFeign" "Code"
                    phoneRepository = component "PhoneRepository" "Provides functionality to communicates with database" "JPA" "Code"
                }
                client -> phoneController "Makes API calls to"
                phoneController -> phoneHandler "Uses main orchestrator"
                phoneHandler -> clientAdapter "Uses API adapter"
                clientAdapter -> feignClient "Uses API client"
                feignClient -> randommer "Triggers API calls"
                phoneHandler -> persistenceAdapter "Uses DB adapter"
                persistenceAdapter -> phoneRepository "Uses DB client"
                phoneRepository -> database "Retrieves and stores data"
            }
        }
    }
    views {
        systemContext backend {
            include *
            autolayout lr
        }
        container backend {
            include *
            autolayout lr
        }
        component backend.commonservice {
            include *
            autolayout lr
        }
        themes https://static.structurizr.com/themes/kubernetes-v0.3/theme.json
        styles {
            element "Element" {
            #   shape <Box|RoundedBox|Circle|Ellipse|Hexagon|Cylinder|Pipe|Person|Robot|Folder|WebBrowser|MobileDevicePortrait|MobileDeviceLandscape|Component>
                shape RoundedBox
            }
            element "Big" {
                width 640
                height 360
            }
            element "Client" {
                shape Person
                color #ffffff
                background #59b4d9
            }
            
            element "Randommer" {
                color #ffffff
                background #b1b0b1
            }
            element "Database" {
                shape Cylinder
            }
            element "Code" {
                color #ffffff
                background #3d6fdd
            }
        }
    }
}