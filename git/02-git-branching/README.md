# 02. Branching and merging

**Level:** beginner
**Time:** about 2 hours
**Prerequisites:** assignment 01

## Warm up drill

Do this before you read anything else. No notes, no searching, no looking at assignment 01. Give yourself five minutes.

In a throwaway folder: initialise a repository, create a file, stage it, commit it with a properly written message, change the file, commit again, add a `.gitignore` that hides a `.log` file, confirm `git status` is clean, then show the history in one line per commit. Delete the folder afterwards.

If you had to look anything up, do it again. You will do a version of this drill at the start of every remaining assignment in this phase, and it gets longer each time. The point is that these commands should eventually cost you no thought at all.

## What you will learn

Why branches exist, what a merge actually does to your history, and the difference between a fast forward and a real merge. Most people use branches for months without understanding this and it is why their history is a mess.

## Before you start

Build the starting repository:

```
./setup.sh
```

That creates `~/devops-course/02-branching` with two commits on `main`.

## Background

A branch is not a copy of your project. It is a movable label pointing at one commit. Creating a branch costs nothing because Git just writes a file containing a commit hash. This is why branching in Git is cheap and branching in older tools was not.

When you merge, one of two things happens.

**Fast forward.** If the branch you are merging into has not moved since you branched off it, Git has no work to do. It slides the label forward to your latest commit. No merge commit is created and the history stays in a straight line.

**Real merge.** If both branches have new commits, Git has to combine them. It creates a new commit with two parents. That is a merge commit, and it is the only kind of commit with more than one parent.

You will produce both in this assignment, on purpose, so you can see the difference in the log rather than being told about it.

## The task

Work in `~/devops-course/02-branching`.

1. Run `git log --oneline --graph --all` before you do anything. Keep running it after every step in this assignment. Watching the shape of the history change is the whole point.

2. Create a branch called `feature/install-steps` and switch to it. Do it in one command, then look up what the flag you used actually means.

3. On that branch, fill in the "Running it" section of `README.md` with real install and run steps. Make two separate commits, not one.

4. Switch back to `main` and merge `feature/install-steps`. Read what Git prints. It will say `Fast-forward`. Look at the graph and work out why no merge commit appeared.

5. From `main`, create two branches: `feature/logging` and `feature/health-check`. Create both from `main` before committing anything on either.

6. On `feature/logging`, add a file `logging.md` describing how the app should log. Commit it.

7. On `feature/health-check`, add a file `health.md` describing a health endpoint. Commit it.

8. Switch to `main` and merge `feature/logging`. Fast forward again.

9. Now merge `feature/health-check` into `main`. This time Git creates a merge commit and opens an editor for the message. Notice that this happened without you doing anything differently. Work out what changed.

10. Confirm `main` now contains all three files and the README changes.

11. Delete all three feature branches. Git will only let you delete branches that are fully merged unless you force it. Do not force it.

12. Run `git log --oneline --graph` one last time and look at the shape you built.

## How you know you are done

```
./check.sh
```

## Questions to answer

In `ANSWERS.md` inside the repository:

1. Steps 4 and 8 fast forwarded, step 9 created a merge commit. What was different about step 9?
2. Some teams ban fast forward merges and always pass `--no-ff`. What do they gain and what do they give up?
3. You are on `feature/logging` with uncommitted changes and you try to switch to `main`. Sometimes Git allows it and sometimes it refuses. What decides which?

## Going further

- Redo step 4 in a scratch copy using `git merge --no-ff` and compare the two graphs side by side.
- Find out what `git switch` and `git restore` do, and why they were added when `git checkout` already existed.
