def nonfinal_state:
  .status.state  | . != "FAILED" and . != "INTERRUPTED" and . != "DONE" and . != "ERROR" and . != "FINALIZING"
;

def is_launching:
  .status.state  | . == "INITIALIZING" or . == "PENDING"
;

def is_stopping:
  .status.state  | . == "TIMEOUT" or . == "INTERRUPTING" or . == "FINALIZING"
;

def select_only_team_tokens:
   select(.spec.labelSelector | contains("kili_challenge_team"))
;

def list_jobs($jobs; $tokens):
   $jobs | .[] | .spec.labels.kili_challenge_team as $team_name | {
        id: .id,
        name: $team_name,
        state: .status.state,
        status: (if nonfinal_state then "WORKING" else "SHUT_DOWN" end),
        orphan: ($tokens | map( select_only_team_tokens | .spec.name) | contains([$team_name]) | not),
        url: .status.url
   }
;


def notebooks($jobs; $tokens):
    [list_jobs($jobs; $tokens)] | group_by(.name) | map({
        name: .[0].name,
        status: (if map(.status) | unique | length == 1 then .[0].status else "WORKING" end),
        orphan: .[0].orphan,
        n_total: length,
        n_working: map(select(.status == "WORKING") | .id) | length,
        n_shut_down: map(select(.status == "SHUT_DOWN") | .id) | length,
        working_jobs: map(select(.status == "WORKING")) | map({id:.id, state:.state, url:.url}) ,
    })
;

def missingjobs($jobs; $tokens):
    $tokens | map(select_only_team_tokens) | [$jobs | .[].spec.name] as $j | map(.spec.name | select(. as $n | ($j | contains([$n]) | not )) ) 
;

def pool_status($jobs; $tokens):
    {
        running: notebooks($jobs; $tokens) | map(select(.status == "WORKING" and .n_working==1 and .working_jobs[0].state == "RUNNING") | .name),
        working_duplicates: notebooks($jobs; $tokens) | map(select(.status == "WORKING" and .n_working!=1) | .name),
        shut_down_to_relaunch: notebooks($jobs; $tokens) | map(select(.status == "SHUT_DOWN" and .orphan == false) | .name),
        orphans: notebooks($jobs; $tokens) | map(select(.status == "WORKING" and .orphan == true) | .name),
        missingjobs: missingjobs($jobs; $tokens),
        launching: [$jobs | map(select(is_launching)) |.[].spec.name],
        stopping: [$jobs | map(select(is_stopping)) |.[].spec.name],

    }
;

def pool_status_with_counts( $jobs; $tokens):
    pool_status($jobs; $tokens) | to_entries | map({key:.key, value:(.value|length)}) | from_entries
;


def teams_to_start_or_restart($jobs; $tokens):
    pool_status($jobs; $tokens) | 
    (.missingjobs + .shut_down_to_relaunch) | .[]
;

def export_list($jobs; $tokens; $teams):
    notebooks($jobs; $tokens) | map(select(.status == "WORKING" and .n_working==1 and .working_jobs[0].state == "RUNNING") |
    .name as $name |
    {
        name: .name,
        url: .working_jobs[0].url,
        token: $teams | map(select(.team == $name)) | .[0].token
    })
;

def list_running_ids($jobs; $tokens):
    notebooks($jobs; $tokens) | .[] | select(.status == "WORKING" and .n_working==1 and .working_jobs[0].state == "RUNNING") | .working_jobs[0].id 
;

