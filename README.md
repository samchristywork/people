![Banner](https://s-christy.com/sbs/status-banner.svg?icon=social/people&hue=200&title=People&description=Track%20when%20you%20last%20contacted%20the%20people%20in%20your%20life)

## Overview

People is a lightweight Bash script for tracking your social contacts. It
stores a list of names alongside the date you last reached out to each person,
then surfaces who you haven't spoken to recently. The data lives in a plain
tab-separated file (`~/.people` by default), so it's easy to inspect, edit, and
back up.

## Features

- Track people and last contact dates in a plain-text file
- List contacts sorted by number of days since last contact
- Record a new contact event with a single command
- Add, update, and remove entries from the command line
- Fall back to `$EDITOR` for direct file editing
- Configurable data file path via `$PEOPLE_FILE` environment variable
- Strict date validation (YYYY-MM-DD)

## Usage

```
Usage: people.sh <subcommand> [args]

Subcommands:
  add <name> [date]  Add a person (date defaults to today, format: YYYY-MM-DD)
  remove <name>      Remove a person
  list               List all people and last contact dates
  contact <name>     Update last contact date to today
  edit               Open the people file in $EDITOR
```

## Dependencies

```
bash
coreutils (date, sort, awk)
```

## License

This work is licensed under the GNU General Public License version 3 (GPLv3).

[<img src="https://s-christy.com/status-banner-service/GPLv3_Logo.svg" width="150" />](https://www.gnu.org/licenses/gpl-3.0.en.html)
