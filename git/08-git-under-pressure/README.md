# 08. Git under pressure

**Level:** mid
**Time:** about 4 hours, but the individual scenarios are timed
**Prerequisites:** assignments 01 to 07

## Warm up drill

No notes. Fifteen minutes, timed properly, write down how long it took you.

Repository, three commits, `.gitignore`. Branch, commit, fast forward merge. Two parallel branches, merge both. Create a conflict and resolve it. Commit and revert. Amend a bad message. Delete an unmerged branch and recover it from reflog. Squash three commits with interactive rebase. Cherry-pick across branches. Annotated tag.

This is the last time the drill is written out for you. Keep doing it monthly.

## What you will learn

The three things that make people panic about Git in real jobs, done under time pressure with no walkthrough. This assignment is deliberately harder than the ones before it and you are expected to look things up. What you are not allowed to do is give up and delete the repository.

## Before you start

```
./setup.sh
```

That creates three separate repositories under `~/devops-course/08-pressure`. Do each scenario in one sitting and write down how long it took.

All your written answers go in one file: `~/devops-course/08-pressure/ANSWERS.md`, at the root, not inside the individual repositories.

## Scenario A: find the commit that broke it

**Target time: 20 minutes.**

`~/devops-course/08-pressure/bisect` has sixty one commits. At the first commit, `python3 test_rates.py` passes. At the last commit it fails. VAT on 100 should be 115 and it is coming out as 100.15.

Sixty commits, mostly changelog noise. Reading them all is not the answer.

1. Confirm the test fails at `HEAD` and passes at the first commit.
2. Use `git bisect` to find the exact commit that introduced the failure. Do it automatically with `git bisect run` rather than answering good or bad sixty times by hand. Getting the invocation right is the skill.
3. Save the output of `git bisect log` to a file called `bisect.log` in the repository before you reset, then end the bisect session properly.
4. Write the short hash and subject of the guilty commit into `ANSWERS.md` under a heading `## Scenario A`.
5. Fix the bug and commit the fix with a conventional commit message. The test must pass.
6. Note in your answers what the author of that commit was probably trying to do, and what they forgot.

## Scenario B: a credential is in your published history

**Target time: 45 minutes.**

`~/devops-course/08-pressure/secret` contains a `.env` file that was committed with real looking AWS credentials in it. Someone later noticed, deleted the file and added a `.gitignore`. They believed that fixed it.

It did not. The credentials are still in every clone of this repository.

1. Prove the problem before you fix it. Find a command that shows the secret is still retrievable from history, and record it in your answers.
2. Remove `.env` from every commit in the repository's history, across all branches, so the secret cannot be recovered by any Git command.
3. `filter-branch` leaves backup references behind and unreachable objects hang around until they are collected. If you skip that step the secret is still there and you will think you are finished when you are not. Deal with it and verify.
4. Everything else must survive. The `release/1.0` branch, all the documentation commits, all of `README.md`. If you flattened the history to solve this, you failed the scenario.
5. Verify properly: searching the entire history for the secret must return nothing.
6. Under `## Scenario B` in your answers file, answer the part that actually matters. You have rewritten history. What do you now have to tell the four other people who cloned this repository, what do you have to do about the credential itself, and in which order do those two things happen?

Note: `git filter-repo` is the modern tool and is worth installing. If you only have `filter-branch`, that is fine, it works, it is just slower and noisier.

## Scenario C: someone destroyed the branch

**Target time: 25 minutes.**

`~/devops-course/08-pressure/rescue` was working an hour ago. A colleague ran a hard reset on `main` and force deleted a release branch. They have gone home. Nothing was pushed anywhere.

What they believe is lost:

- three commits on `main`, ending with one called `feat: add billing export`
- a branch called `release/2.0` with two further commits on top of that

1. Establish what state the repository is in now before changing anything.
2. Find the lost commits. They are not gone.
3. Restore `main` so it ends at `feat: add billing export` with its full history intact.
4. Recreate `release/2.0` pointing at exactly the commit it was at, with both of its commits.
5. Verify `ledger.md` on each branch has the right contents. Restoring the branch label to the wrong commit is the easy mistake here.
6. Under `## Scenario C` in your answers file, explain what would have made this unrecoverable, and what the team should do so it never depends on one person's local reflog again.

## How you know you are done

```
./check.sh
```

It checks all three scenarios.

## Questions to answer

At the end of the same `ANSWERS.md`:

1. `git bisect run` needs a command that exits zero for good and non zero for bad. What do you do when the bug does not have a test, and what does "good" mean then?
2. Bisect assumes the bug was introduced once and stayed. Describe a situation where bisect gives you a confidently wrong answer.
3. After scenario B, a colleague who had already cloned the repository pushes. What happens, and how does the secret get reintroduced?
4. Roughly how long do unreachable objects survive before Git will actually delete them, and what does that mean for how urgently scenario B has to be handled?
5. Across all three scenarios, which one would you least want to face at 5pm on a Friday, and why?

## Going further

- Write a `git bisect run` script that handles the case where a commit will not even build, using the skip exit code.
- Install `git filter-repo` and redo scenario B with it. Compare how long it takes.
- Find out what `git fsck --lost-found` shows you and when you would use it instead of the reflog.
