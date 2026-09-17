# 06. Text processing and pipes

**Level:** intermediate
**Time:** about 3 hours
**Prerequisites:** `linux/01` to `linux/05`

## Warm up drill

No notes. Twelve minutes.

Files: make `drill/a/b`, copy, rename, wildcard delete, `find`. Permissions: make a script, fix `./` with `chmod`, make a file `600`. Processes: background `sleep 300`, find it, kill it. Services: check `systemctl status nginx`, stop it, confirm with `curl localhost`, start it, and show its last five log lines with `journalctl`. Delete `drill`.

## What you will learn

How to answer questions about huge text files without opening them, by chaining small commands together. A large part of real operations work is exactly this: a log with a quarter of a million lines and someone asking what went wrong at two o'clock.

## Before you start

```
bash ~/devops-course/course/linux/06-text-processing/setup.sh
```

That creates `~/devops-course/linux/06-text` with a day of web server logs, a day of application logs, and a config file.

## Background

**Every command has an input and two outputs.** Standard input is where it reads from. Standard output is where normal results go. Standard error is where error messages go. Usually all three are your terminal.

**Redirection.** `>` sends standard output to a file and replaces it, `>>` appends, and `2>` sends standard error somewhere. `2>&1` means "send errors wherever output is going".

**Pipes.** `|` connects one command's output to the next command's input. That is the whole trick. Each command does one small job and you chain them:

```
cat access.log | awk '{print $9}' | sort | uniq -c | sort -rn | head -n 5
```

Read that left to right. Take the log, keep only the ninth column, sort it, count how many times each value appears, sort by that count with the biggest first, and show the top five.

**The toolkit:**

| Command | What it does |
| --- | --- |
| `grep word file` | lines containing `word`. `-i` ignores case, `-v` inverts, `-c` counts, `-E` allows patterns like `a|b` |
| `wc -l` | counts lines |
| `awk '{print $1}'` | prints the first column, where columns are separated by spaces |
| `awk '$9 == 500'` | prints lines whose ninth column is 500 |
| `awk '{s += $10} END {print s}'` | adds up the tenth column |
| `cut -d: -f2` | splits on `:` and keeps the second field |
| `sort` | sorts lines. `-n` sorts as numbers, `-r` reverses |
| `uniq -c` | collapses repeated lines and counts them. **Only works on sorted input** |
| `head`, `tail` | first or last lines |
| `sed 's/old/new/g' file` | replaces text. `-i` changes the file itself |

**Know your columns.** A web log line looks like this:

```
203.0.113.77 - - [15/Sep/2026:14:02:11 +0000] "GET /api/notes HTTP/1.1" 200 5123 "-" "Mozilla/5.0"
```

Split on spaces, `$1` is the IP address, `$7` is the path, `$9` is the status code and `$10` is the bytes sent. Always look at a few real lines with `head` before you start counting columns.

The mistake everyone makes is `uniq -c` without `sort` first. It only merges lines that are next to each other, so on unsorted input it gives you a count that is plausible and wrong.

## The task

Work in `~/devops-course/linux/06-text`. Do not open `access.log` or `app.log` in nano.

### Part 1: Answer questions with pipelines

Create `answers.txt` containing exactly these eight lines, with your answers after the `=` signs and no spaces:

```
q1=
q2=
q3=
q4=
q5=
q6=
q7=
q8=
```

1. **q1.** How many requests are in `access.log`?
2. **q2.** How many of those requests returned status 500?
3. **q3.** Which IP address made the most requests?
4. **q4.** How many different IP addresses made requests?
5. **q5.** Which path was requested most often? Count exact paths, so `/api/notes/12` and `/api/notes` are different.
6. **q6.** How many bytes were sent in total?
7. **q7.** In `app.log`, which hour of the day had the most `ERROR` lines? Answer with two digits, for example `09`.
8. **q8.** How many lines in `app.log` mention a database timeout? Watch the capital letters.

Every answer must come from a command, not from counting by eye. Put the command you used for each question, in order, into a file called `pipelines.sh`, one per line, so that `bash pipelines.sh` prints all eight answers.

### Part 2: Change files with commands

9. Put every `ERROR` line from `app.log`, and nothing else, into a new file `errors.log`.
10. The database has moved. In `servers.conf`, replace every `db-old.internal` with `db-new.internal`, changing the file in place with `sed`. Check the result with `grep` before and after. Every line that is not a hostname must stay exactly as it was.

### Questions

Put `ANSWERS.md` in `~/devops-course/linux/06-text`:

1. Explain in your own words why `uniq -c` gives the wrong answer without `sort` in front of it.
2. For q7, describe how you got the hour out of each line.
3. What is the difference between `>` and `>>`, and what happens if you run `sort file > file`?
4. `sed -i` changes a file with no undo. What would you do before running it on a real server's config?

## How you know you are done

```
bash ~/devops-course/course/linux/06-text-processing/check.sh
```

## Going further

- Find the top five paths that returned 404.
- Count requests per hour from `access.log` and see whether the traffic is even across the day.
- Find out what `awk -F` does, and use it to count `ERROR` lines per message in `app.log`.
- Use `tail -f` on a log while appending lines to it from another terminal with `echo >>`.
