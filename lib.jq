def nonfinal_state:
  .status.state != "FAILED" and .status.state != "INTERRUPTED" and .status.state != "DONE" and .status.state != "ERROR"
;

def final_state:
  nonfinal_state | not 
;

def has_token($team_name):
  .spec.labels.kili_challenge_team==$team_name
;

def list_jobs($jobs; $tokens):
   $tokens | .[].spec.name | . as $team_name | (
    {
        team: .,
        running: (if (($jobs | map(select(has_token($team_name)) | select(nonfinal_state))) | length)>0 then "WORKING" else "BROKEN" end),
    }
   )
;

def list_broken_jobs($jobs; $tokens):
  list_jobs($jobs; $tokens) | select(.running == "BROKEN")
;

def list_working_jobs($jobs; $tokens):
  list_jobs($jobs; $tokens) | select(.running == "WORKING")
;

