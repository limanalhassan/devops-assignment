# Git

Do the [Linux phase](../linux/) first, all nine assignments. Everything here assumes you can move around a filesystem, edit a file in nano, and run a script without having to think about it. `git/07` also asks you to write shell scripts, which is taught in `linux/07`.

Work through these in order. Each folder has a `README.md` with the task and a `check.sh` you run yourself to see whether you finished. Some also have a `setup.sh`, which you run first because it builds the repository you will be working in.

## Running things

Same as the Linux phase. The word `bash`, then the full path to the script, from any folder:

```
bash ~/devops-course/course/git/02-git-branching/setup.sh
bash ~/devops-course/course/git/02-git-branching/check.sh
```

Your own work goes in `~/devops-course/git/`. The course files you cloned stay untouched in `~/devops-course/course/`.

## The assignments

| # | Assignment | Level | Time |
| --- | --- | --- | --- |
| 01 | [Your first repository](01-git-first-repo/) | beginner | 90 min |
| 02 | [Branching and merging](02-git-branching/) | beginner | 2 hrs |
| 03 | [Conflicts, merge and rebase](03-git-merge-conflicts/) | beginner to intermediate | 2 hrs |
| 04 | [Reading history and undoing things](04-git-history-and-undo/) | intermediate | 3 hrs |
| 05 | [The pull request workflow](05-git-github-workflow/) | intermediate | 2 hrs |
| 06 | [Rewriting history](06-git-rewriting-history/) | intermediate | 3 hrs |
| 07 | [Working in a team](07-git-team-practice/) | intermediate | 3 hrs |
| 08 | [Git under pressure](08-git-under-pressure/) | mid | 4 hrs |

About five weeks at six to eight hours a week.

## When Git opens an editor

Sometimes Git needs you to write or confirm a message and opens an editor to ask. `git/01` sets that editor to nano. Save with Ctrl and O then Enter, leave with Ctrl and X, and Git carries on.

If you ever land in a screen full of `~` characters where typing does strange things, that is vim. Press Esc, type `:wq`, press Enter, and then set your editor as `git/01` describes.

## How to submit

From `git/05` onwards, everything is submitted as a pull request. Fork the course repository, create a branch named `<your-name>/<phase>-<number>`, for example `ama/git-05`, do the work, and open a pull request. `git/05` walks you through it and has you submit your Linux answers at the same time.

## The drill

Every assignment from 02 onwards opens with a warm up drill that repeats the core actions of every assignment before it, from memory, with no notes, against a clock. Do not skip it. It is the part that turns commands you have read into commands you can use.
