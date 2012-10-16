# Team 3: Process and Roles #

## Tools ##

* We make heavy use of the tools github provides 
 * Wiki: for documenting and making meeting notes available to everybody 
 * Issue-Tracker: We create issues for every workunit
 * User stories are split into issues
 * Issues are labeled and filed under milestones, each sprint is a milestone
 * If an issue requires discussion within the team we use issue comments
 * Team members assign issues to themselves to keep transparent who is doing what and to avoid having to two members on the same issue
 * Issue number in commit message to link commits and issues
* ESE-Mailing-List for discussions about more general topics

## Roles ##

* no strict division of roles, except for deployment
* workload is shared by pull principle: every team member pulls his issues. Everyone tries to pull according to his skills and preferences

## Development and deployment ##

* Development on localhost
* Development on master or local topic branch
* Branch 'stable': Regular merge from master (only when tested well)
* 'stable' regularly deployed to http://ese.michaelkohler.info (manual 'git pull' on the server and restart within a 'screen')
* tests are run automatically every 15 minutes at http://jenkins.michaelkohler.info/job/ESE2012-team3/
