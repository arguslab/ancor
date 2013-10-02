## Definitions

*Task* - Single operation that is queued for completion (e.g., provision an instance)
*Wait condition* - Condition that is fulfilled by an external system. Used to step in and
  out of task trees

## Improvements & Refactoring

+ Change from routing slip pattern to persisted tasks

    + Tasks have wait conditions
    + Conditions are mapped to hooks (webhooks)

+ Remove role assignment, instance now maps to one role
+ Rename resource to channel
+ Rename role implementation to scenario

  + Extract fragment from scenario into its own class
  + Fragments can be used in multiple scenarios, in different stages

+ Host framework on Rails instead of standalone
+ Move role dependencies from Channel to Role

## New features

+ Constraint model
+ Dependency cycle detection
+ Validation using Sensu, possibly ERB + JSON
