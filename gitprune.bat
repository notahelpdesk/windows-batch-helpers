:: gitprune.bat
::
:: NOTE you should really run this from the develop branch
:: this pulls the most recent changes, checks for any remote branches that have been removed,
:: then displays the relationship between the local one and the remote one (look for 'gone' in the final output)

@echo off

git pull && git fetch --prune && git branch -vv
