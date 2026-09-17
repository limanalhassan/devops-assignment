# 09. A machine that is misbehaving

**Level:** mid
**Time:** about 4 hours, timed
**Prerequisites:** all of `linux/01` to `linux/08`

## Warm up drill

No notes. Fifteen minutes, and write down how long it took.

Files: `drill/a/b`, copy, rename, wildcard delete, `find`. Permissions: fix a script with `chmod`, make a file `600`, change a file's group. Processes: background `sleep 300`, find it, kill it. Services: restart nginx and read its last log lines. Text: count lines containing `7` in `seq 1 1000`, top ten with `sort`. Scripting: a script that takes a file name, exits `2` with usage on standard error when there is none, and prints the line count. Users and network: create a user called `drilluser`, list every listening port with the program behind it, and get the status code of `https://github.com` with `curl`. Delete `drilluser` and `drill`.

This is the last drill written out for you. Keep doing it once a month.

## What you will learn

Nothing new. That is the point. You get a broken machine and a vague complaint, the way real incidents arrive, and you use everything from this phase to find out what is wrong, fix it properly, and write down what happened.

## Before you start

```
bash ~/devops-course/course/linux/09-broken-machine/setup.sh
```

**Do not read `setup.sh`.** It tells you exactly what is broken, and reading it wastes the whole assignment. On a real incident nobody hands you the script that broke things.

Make `~/devops-course/linux/09-incident/NOTES.md` and write in it as you go. Every time you find something or change something, run `date +%H:%M` and write the time next to it. You will need these notes for your report.

## Background

**How to approach an incident.** Resist the urge to start fixing. Most bad incidents are made worse by someone who changed three things before understanding one.

1. **Confirm the symptoms yourself.** A complaint is someone else's guess about what is wrong.
2. **Gather evidence before changing anything.** Logs, status, what is running, what is using resources.
3. **Find the root cause.** "The service is down" is a symptom. Why is it down?
4. **Fix the cause, not the symptom.** Restarting something that will just fail again is not a fix.
5. **Verify the fix.** The original symptom should be gone, and nothing else should be broken.
6. **Write it up,** so the next person, or you in six months, does not start from zero.

**Two kinds of fix to avoid.** Making a problem go away by removing the protection that caused it, like running a service as root or making a secret readable by everyone. And making a problem go away without knowing why it happened, like rebooting.

## The ticket

> **From:** support
> **Subject:** inventory down, box slow
>
> The inventory API at `http://localhost:8090` stopped answering this morning, and everything that depends on it is failing. Someone restarted it and it came up for a moment then died again.
>
> Also, the machine feels sluggish. Every time someone checks it, something is using a whole CPU, and when they killed it, it was back a minute later.
>
> And monitoring says disk usage jumped by about 400MB overnight, but nobody can find any new big files.
>
> Please fix it. Nothing on this machine has been deliberately changed recently, as far as anyone knows.

## Rules

- **Do not reboot.** Production machines cannot just be rebooted, and a reboot destroys evidence.
- **Do not delete or disable the inventory service**, and do not make it run as root.
- **Do not make secrets readable by everyone.** The inventory config contains a password.
- Every fix must still be in place after the affected service is restarted.
- You may use `sudo`. You may search the internet for what error messages mean. You may not read `setup.sh`.

## The task

1. Confirm every symptom in the ticket yourself before changing anything, and note the time.
2. Find the root cause of each problem. There are three, and they are not related to each other.
3. Fix each one properly.
4. Verify the ticket's three complaints are all gone.
5. Write `INCIDENT.md` in `~/devops-course/linux/09-incident` using the structure below.

### INCIDENT.md

Use exactly these headings:

```
## Summary
## Timeline
## Root cause
## Fix
## Prevention
```

**Summary:** two or three sentences a manager could read. **Timeline:** times from your notes, what you saw and what you did. **Root cause:** for each of the three problems, the actual cause, not the symptom. **Fix:** exactly what you changed, with commands. **Prevention:** what would stop each one happening again, or at least catch it sooner.

## How you know you are done

```
bash ~/devops-course/course/linux/09-broken-machine/check.sh
```

The checker verifies the three problems are really fixed, that none of the rules were broken to get there, and that your report covers all three.

## Where to look if you are completely stuck

Read these only after at least an hour of real effort, and only one at a time.

<details>
<summary>Nudge for the inventory API</summary>

When a service will not stay up, the reason is almost always in its logs. You learned the command in `linux/05`. Read the error carefully, then think about `linux/03`.

</details>

<details>
<summary>Nudge for the CPU</summary>

If something keeps coming back after it has been killed, something else is starting it. Look at what process started it, and think about which part of Linux runs things on a schedule.

</details>

<details>
<summary>Nudge for the disk</summary>

`df` and `du` disagree. `du` adds up files it can find by name. A file that has been deleted has no name any more, but its space is only freed when the last program holding it open lets go. Search for "find deleted files still open linux".

</details>

## Going further

- Write a script that would have caught the deleted-but-open file automatically, and exits non zero when it finds one.
- Find out what `systemctl reset-failed` does and why you might have needed it.
- Look up `StartLimitBurst` and explain why the inventory service stopped trying to restart.
