## Tools

Web frontend

  - Grunt - build tool
  - Bower - dependency management
  - Yeoman - generator
  - Angular

CLI

  - Thor - command line library
  - Faraday - HTTP client library
  - Formatador - CLI formatting library

API

  - Rails - MVC framework
  - ActiveModel::Serializer

## Use cases

  - Seeing the state of instances
  - Seeing the current tasks
  - Viewing goals, roles

  - Importing ARML specification
  - Deploying role(s)
  - Expanding/contracting instances in roles
  - Replacing an instance

## Command-line interface

ancor <subject> <verb> <targets> <--options>
ancor version
ancor import <path to arml file> - import an ARML specification
ancor deploy - deploy instances for roles that have not been deployed
ancor instance list
ancor instance replace <old instance id>
ancor instance add <role slug>
ancor instance remove <role slug>
ancor goal list
ancor role list
ancor task list

## HTTP REST interface

GET /api/version

   "1.2.3"

POST /api/import

    Content-Type: application/yaml

    CONTENT OF ARML FILE

POST /api/deploy

GET /api/instances

    [
      { "id": 123 },
      { "id": 456 }
    ]

GET /api/instances?role=web
GET /api/instances?role=dbmaster&state=deployed

GET /api/instances/123

    {
      "id": "123",
      "name": "web0",
      "channel_selections": [
      ]
    }

POST /api/instances

    ## Replacing an old instance
    {
      "old_instance": "xxx"
    }

    ## Deploying a new instance
    {
      "role": "web",
      "n": 123
    }

DELETE /api/instances/123
GET /api/goals
GET /api/roles
GET /api/tasks
