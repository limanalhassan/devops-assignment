# Linux

Start here. This is the first phase of the course and everything else depends on it.

Each folder has a `README.md` with the task and a `check.sh` you run yourself to see whether you finished. Most also have a `setup.sh`, which you run first because it builds what you will be working on.

## Running things

Every script in this course is run the same way, the word `bash` and then the full path to the script, from any folder:

```
bash ~/devops-course/course/linux/02-files-and-directories/setup.sh
bash ~/devops-course/course/linux/02-files-and-directories/check.sh
```

Your own work goes in `~/devops-course/linux/`. The course files stay untouched in `~/devops-course/course/`. `linux/01` sets all of this up and explains why.

## The assignments

| # | Assignment | Level | Time |
| --- | --- | --- | --- |
| 01 | [Your terminal](01-terminal-basics/) | absolute beginner | 2 hrs |
| 02 | [Files and directories](02-files-and-directories/) | beginner | 2 hrs |
| 03 | [Permissions and ownership](03-permissions/) | beginner | 2 hrs |
| 04 | [Processes and signals](04-processes/) | beginner | 2 hrs |
| 05 | [Packages and services](05-packages-and-services/) | intermediate | 3 hrs |
| 06 | [Text processing and pipes](06-text-processing/) | intermediate | 3 hrs |
| 07 | [Shell scripting](07-shell-scripting/) | intermediate | 4 hrs |
| 08 | [Users, SSH and networking](08-users-ssh-networking/) | intermediate | 3 hrs |
| 09 | [A machine that is misbehaving](09-broken-machine/) | mid | 4 hrs |

About four weeks at six to eight hours a week.

## The drill

Every assignment from 02 onwards opens with a warm up drill that repeats the core actions of every assignment before it, from memory, with no notes, against a clock. It grows each time. Do not skip it. It is the part that turns commands you have read into commands you can type without thinking.

## Keep your answers

Most assignments ask you to write an `ANSWERS.md`, and `09` asks for an `INCIDENT.md`. Keep all of them where they are. Nobody sees this phase's work until `git/05`, where you learn to submit through a pull request and hand in everything from this phase at the same time.

## After this

The [Git phase](../git/) is next.
