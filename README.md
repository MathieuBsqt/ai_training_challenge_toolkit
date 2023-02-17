# Requirements

- ovhai
- jq
- xargs

# Connect to a region

```
ovhai config set GRA
```

or 

```
ovhai config set BHS
````

for both you should do (once) : 

```
ovhai login
````

# Create teams

````
# Creating 100 teams
./create_teams.sh prefix $(seq 1 100)
````

This creates the **teams_GRA.json** or **teams_BHS.json** that contrains the tokens. Keep it private.

# Getting the pool status 

````
% ./pool_status_counts.sh 
{
  "running": 0,
  "working_duplicates": 0,
  "shut_down_to_relaunch": 0,
  "orphans": 0,
  "missingjobs": 100,
  "launching": 0,
  "stopping": 0
}
````

Here is the meaning for the different categories : 
- running : jobs that are assigned to a team, running
- working_duplicates : running jobs but that are duplicated (more than 1 job for 1 team)
- shut_down_to_relaunch : jobs stopped, that could be relaunched
- orphans : jobs running, but with no corresponding team (to handle manually)
- missingjobs : teams that have no jobs yet (not even stopped)
- launching : jobs that are in launching status, will eventually become "running"
- stopping : jobs that are in stopping status, will become "shut_down_to_relaunch" 

here we have 100 jobs that need to be launched (the 100 teams that we created earlier)

You can get the detail instead of the counts : 

```
% ./pool_status.sh
{
  "running": [],
  "working_duplicates": [],
  "shut_down_to_relaunch": [],
  "orphans": [],
  "missingjobs": [
    "teams_prefix_10",
    "teams_prefix_9",
    "teams_prefix_8",
    "teams_prefix_7",
    "teams_prefix_6",
    "teams_prefix_5",
    "teams_prefix_4",
    "teams_prefix_3",
    "teams_prefix_2",
    "teams_prefix_1",
    ...
  ],
  "launching": [],
  "stopping": []
}
```


# Running the missing jobs 

This allow to run the missing jobs and the jobs that are stopped/failed etc.

```
% ./up.sh ovhaimax/kili
run teams_prefix_10
run teams_prefix_9
run teams_prefix_8
run teams_prefix_7
run teams_prefix_6
run teams_prefix_5
run teams_prefix_4
run teams_prefix_3
run teams_prefix_2
run teams_prefix_1
...
```

Depending on the moment you check the pool status, you may see launching or running jobs now. Here after some time : 

```
% ./pool_status_counts.sh               
{
  "running": 10,
  "working_duplicates": 0,
  "shut_down_to_relaunch": 0,
  "orphans": 0,
  "missingjobs": 0,
  "launching": 0,
  "stopping": 0
}
````

# Stopping all jobs

```
./stop-all-running-jobs.sh 
```


# Gettting the list of URLs with tokens

To give them to the challengers : 

```
% ./export_list.sh > export_GRA.json 
```

# Know when the workspace initialization are over 


```
./list_workspace_init.sh
[
  {
    "workspace_init_status": "ongoing",
    "nb": 10
  }
]
```

We have 2 possible statuses :
- ongoing : the job is running, but still initializing its workspace on the CephFs
- success : the job is running and ready to be used by the user(s)

In the exemple above for instance, we have 10 initialization ongoing, and 0 success

