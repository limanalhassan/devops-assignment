# 07. Shell scripting

**Level:** intermediate
**Time:** about 4 hours
**Prerequisites:** `linux/01` to `linux/06`

## Warm up drill

No notes. Fifteen minutes.

Files: make `drill/a/b`, copy, rename, wildcard delete, `find`. Permissions: fix a script with `chmod`, make a file `600`. Processes: background `sleep 300`, find it, kill it. Services: stop and start nginx and read its last log lines. Text: `seq 1 1000 > n.txt`, then count the lines containing a `7`, show the ten biggest numbers with `sort`, and replace every `5` with `X` into a new file with `sed`. Delete `drill`.

## What you will learn

How to write shell scripts that take arguments, make decisions, loop, and report success or failure in a way other programs can rely on. Every automation job you ever do starts here, and the Git phase will ask you to write scripts that Git itself runs.

## Before you start

```
bash ~/devops-course/course/linux/07-shell-scripting/setup.sh
```

That creates `~/devops-course/linux/07-scripting` with some sample config files, a test program called `flaky.sh`, and a small folder to back up. You write all four scripts in that folder.

## Background

**The first line.** `#!/usr/bin/env bash` says which program runs the script. Put it on line one of every script.

**Variables.** `name="Ama"`, with **no spaces around the `=`**. `name = "Ama"` tries to run a command called `name`. Use a variable as `"$name"`, **always in double quotes**, or a value with a space in it gets split into two words.

**Arguments.** `$1` is the first argument, `$2` the second, and so on. `$#` is how many arguments there are. `"$@"` is all of them, each kept as its own word even when it contains spaces. `shift` throws away `$1` and moves the rest down one place.

**Exit codes.** Every command finishes with a number. `0` means success, anything else means failure. `$?` holds the exit code of the last command. `exit 1` ends your script with that code. Other programs decide what to do based on your exit code and nothing else, so it matters more than anything you print.

**Two outputs.** Normal results go to standard output with `echo`. Errors and usage messages go to standard error with `echo "message" >&2`. That way someone can capture your results without your error messages mixed in.

**Decisions.**

```bash
if [ -z "$1" ]; then
  echo "usage: greet.sh <name>" >&2
  exit 1
fi
```

The spaces inside `[ ]` are required. Useful tests:

| Test | True when |
| --- | --- |
| `-z "$x"` | `x` is empty |
| `-f "$x"` | `x` is an existing file |
| `-d "$x"` | `x` is an existing directory |
| `"$a" = "$b"` | the strings are equal |
| `"$a" -eq "$b"` | the numbers are equal. Also `-ne`, `-lt`, `-le`, `-gt`, `-ge` |

You can also use a command as the test, because `if` only looks at the exit code. `if grep -q word file; then` is extremely common, and so is `if printf '%s' "$x" | grep -qE '^[0-9]+$'; then` to check that something is a whole number.

**Choosing between several values.**

```bash
case "$environment" in
  dev|staging|prod) ;;
  *) echo "environment must be dev, staging or prod" >&2 ;;
esac
```

**Loops.**

```bash
for file in *.log; do
  echo "found $file"
done

while IFS='=' read -r key value; do
  echo "key is $key and value is $value"
done < config.conf
```

The second loop reads a file one line at a time and splits each line at the `=`. Remember it, you need it below.

**Doing sums and capturing output.** `$((count + 1))` does arithmetic. `$(date +%Y%m%d)` runs a command and puts its output in place, so `today=$(date +%Y%m%d)` stores today's date.

## The task

Work in `~/devops-course/linux/07-scripting`. Test each script by hand, with good input and bad input, before moving on. Check your exit codes with `echo $?` straight after running something.

### Script 1: greet.sh

A warm up.

- `bash greet.sh Ama` prints exactly `Hello, Ama` and exits `0`.
- `bash greet.sh` with no argument prints `usage: greet.sh <name>` to **standard error**, prints nothing to standard output, and exits `1`.

### Script 2: check_config.sh

Validates a config file before a service is allowed to start with it. Config files look like `configs/good.conf`: one `key=value` per line, with blank lines and lines starting with `#` ignored.

- `bash check_config.sh <file>`
- With no argument, print a usage message to standard error and exit `2`.
- If the file does not exist, print `error: <file> not found` to standard error and exit `2`.
- The keys `port`, `workers` and `environment` are required.
- `port` must be a whole number from 1 to 65535.
- `workers` must be a whole number of at least 1.
- `environment` must be exactly `dev`, `staging` or `prod`.
- Report **every** problem, not just the first one, each on its own line on standard error, naming the key that is wrong or missing.
- If there are no problems, print `OK` and exit `0`. If there are any problems, print nothing to standard output and exit `1`.

Try it against all four files in `configs`. Work out beforehand what each one should produce. `tricky.conf` exists to catch something.

### Script 3: retry.sh

Runs a command that sometimes fails and tries it again. Deploy scripts are full of these.

- `bash retry.sh <attempts> <command> [arguments...]`, for example `bash retry.sh 5 curl -sf localhost:8085`.
- If `attempts` is not a whole number of at least 1, or there is no command, print usage to standard error and exit `2`.
- Run the command with all of its arguments exactly as given.
- As soon as it succeeds, exit `0` straight away without running it again.
- Each time it fails, print `attempt N of M failed` to standard error. Wait one second before the next try, but do not wait after the last one.
- If every attempt fails, exit with **the exit code the command itself returned** on its final attempt, not just `1`.

Test it with `bash retry.sh 5 bash flaky.sh /tmp/flaky-state`, deleting `/tmp/flaky-state` between runs. Also test it with a folder whose name has a space in it: `mkdir "/tmp/my folder"` then `bash retry.sh 2 ls "/tmp/my folder"`. If that one fails, look very hard at how you passed the arguments along.

### Script 4: backup.sh

- `bash backup.sh <source_dir> <dest_dir>`
- Without both arguments, print usage to standard error and exit `2`.
- If `source_dir` is not a directory, print `error: <source_dir> is not a directory` to standard error and exit `2`.
- Create `dest_dir` if it does not exist, including any missing parent folders.
- Create a compressed archive of `source_dir` in `dest_dir`, named after the source folder and the current date and time, for example `sample-data-20260915-143022.tar.gz`. The pattern is `<folder name>-YYYYMMDD-HHMMSS.tar.gz`.
- Print the full path of the archive, and nothing else, to standard output.
- Keep only the **three newest** archives for that source folder in `dest_dir` and delete older ones. Never touch archives belonging to other folders.
- Exit `0`.

Create an archive with `tar -czf archive.tar.gz -C <parent folder> <folder name>`, and list what is inside one with `tar -tzf archive.tar.gz`. The date in the file name sorts in time order, which is the hint for finding the oldest.

### Questions

Put `ANSWERS.md` in `~/devops-course/linux/07-scripting`:

1. What is the difference between `"$@"` and `$@` without quotes? Describe exactly what went wrong, or would have gone wrong, with the folder that has a space in its name.
2. Why does `retry.sh` exit with the command's own exit code instead of always `1`? Who benefits from that?
3. Why do error messages go to standard error? Give an example where mixing them into standard output would break something.
4. Look up what `set -euo pipefail` does at the top of a script. Explain each of the three parts, and one situation where `-e` would surprise you.
5. Later in the course, Git will run a script of yours before every commit and refuse the commit if your script exits with anything other than `0`. Using what you learned here, how would your script tell Git to refuse?

## How you know you are done

```
bash ~/devops-course/course/linux/07-shell-scripting/check.sh
```

The checker runs your scripts against a set of inputs, including ones not in `configs`. It takes about twenty seconds because `retry.sh` waits between attempts.

## Going further

- Install `shellcheck` with `apt` and run it on all four scripts. Fix everything it reports.
- Add a `--dry-run` option to `backup.sh` that prints what it would delete without deleting it.
- Make `retry.sh` double the wait between attempts: 1 second, then 2, then 4.
