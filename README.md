Lang-Stats is a script for collecting statistics about languages in use in a git
repository over time.

### Usage

#### `run.sh`

Run `run.sh [repo url]` from the repo root. This clones `[repo url]` to `./repo`
and executes `lang-stats.sh` in that directory.

#### `lang-stats.sh`

Language statistics are collected by running tokei against the repo on one
commit per week between the initial commit and today. Tokei's JSON output is
summarized using jq with `summarize-tokei.jq` query and the csv output is
appended to `weekly-stats.csv`. If a week has been calculated in previous runs
it is skipped, which makes it quick to maintain manually and hopefully easy to
integrate into CI.

#### `index.html`

The data can be viewed in the browser by serving the local directory using a
utility like `miniserve .` or republishing the master branch to github pages and
viewing it there. `index.html` is a static page that uses d3 to load
`weekly-stats.csv` from the server and display it in a stacked area chart using
plain javascript.
