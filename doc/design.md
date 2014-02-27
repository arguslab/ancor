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
    ancor plan <path to arml file> - imports an ARML specification and deploys it
    ancor commit
    ancor instance list
    ancor instance replace <old instance id>
    ancor instance add <role slug>
    ancor instance remove <role slug>
    ancor goal list
    ancor role list
    ancor task list

## HTTP REST interface

### System info

`GET /api/version`

    "1.2.3"

### Engine control

`POST /api/plan`

    Content-Type: application/yaml

    CONTENT OF ARML FILE

`POST /api/commit`

### Instances

List instances

`GET /api/instances`

    [
      { "id": 123 },
      { "id": 456 }
    ]

List interfaces and filter by query

`GET /api/instances?role=web`

`GET /api/instances?role=dbmaster&state=deployed`

Retrieve summary of an instance

`GET /api/instances/123`

    {
      "id": "123",
      "name": "web0",
      "channel_selections": [
      ]
    }

Create a new instance for a given role

`POST /api/instances`

    {
      "role": "web"
    }
    
Mark an instance for replacement

`POST /api/instances/123`

    { "replace": true }

Remove an instance

`DELETE /api/instances/123`

### Goals

List goals

`GET /api/goals`

### Roles

List roles

`GET /api/roles`

### Tasks

List tasks

`GET /api/tasks`
