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
    ancor environment list
    ancor instance list
    ancor instance replace <old instance id>
    ancor instance add <role slug>
    ancor instance remove <role slug>
    ancor goal list
    ancor role list
    ancor task list

## HTTP REST interface

### System info

`GET /v1/version`

    "1.2.3"

### Engine control


### Instances

List instances

`GET /v1/instances`

    [
      { "id": 123 },
      { "id": 456 }
    ]

List interfaces and filter by query

`GET /v1/instances?role=web`

`GET /v1/instances?role=dbmaster&state=deployed`

Retrieve summary of an instance

`GET /v1/instances/123`

    {
      "id": "123",
      "name": "web0",
      "channel_selections": [
      ]
    }

Create a new instance for a given role

`POST /v1/instances`

    {
      "role": "web"
    }

Mark an instance for replacement

`POST /v1/instances/123`

    { "replace": true }

Remove an instance

`DELETE /v1/instances/123`

### Environments

Import an ARML file into an environment for planning

`POST /v1/environments/123/plan`

    Content-Type: application/yaml

    CONTENT OF ARML FILE

Commit pending changes

`POST /v1/environments/123`

    { "commit": true }

List environments

`GET /v1/environments`

Get detailed view of an environment

`GET /v1/environments/123`

    {
      "id": "123",
      "slug": "production",
      "name": "Production",
      "description": "Where the magic happens",
      "roles": [
        { "id": "123", "slug": "weblb" },
        { "id": "456", "slug": "webapp" }
      ]
    }

### Goals

List goals

`GET /v1/goals`

### Roles

List roles

`GET /v1/roles`

### Tasks

List tasks

`GET /v1/tasks`
