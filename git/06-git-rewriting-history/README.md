# 06. Rewriting history

**Level:** intermediate
**Time:** about 3 hours
**Prerequisites:** assignments 01 to 05

## Warm up drill

No notes. Twelve minutes.

Repository, three commits, `.gitignore`. Branch, commit, fast forward merge. Two parallel branches, merge both, produce a merge commit. Create a conflict and resolve it. Make a commit, revert it. Bad commit message, fix it with amend. Delete an unmerged branch and recover it from the reflog.

Same drill as last time. It should be noticeably faster now. If it is not, that is the signal to do it daily this week.

## What you will learn

How to turn six messy commits into three good ones before anyone else sees them, how to take one commit from a branch without taking the rest, and how to tag a release.

## Before you start

```
./setup.sh
```

That creates `~/devops-course/06-rewriting` and leaves you on `feature/search` with six commits, most of which are the kind of thing everyone actually produces while working.

Do not delete the tag `pre-cleanup`. The checker uses it to prove you did not lose any work.

## Background

The history you work in and the history you publish do not have to be the same. While you are building something you commit constantly, with messages like "wip" and "actually fix it this time", because committing often is the right habit. Before anyone reviews it, you clean it up so the history tells the story of the change rather than the story of your afternoon.

Interactive rebase is the tool. `git rebase -i <commit>` opens an editor listing every commit after that point, and you edit the list to say what should happen to each one:

- **pick** keep it as is
- **reword** keep the change, rewrite the message
- **squash** fold it into the commit above and combine the messages
- **fixup** fold it into the commit above and throw its message away
- **drop** remove it entirely
- reorder the lines to reorder the commits

Two things to be clear about. The commits are listed oldest first, which is the opposite of `git log`. And every commit after the point you rebase from gets a new hash, even ones you did not touch, because a commit's identity includes its parent.

Which brings back the rule from assignment 03. Rewriting history that only exists on your machine is routine and good practice. Rewriting history other people have pulled forces work onto them and is how you make enemies.

**Cherry-pick** is the other tool here. It takes the change from one commit and applies it somewhere else as a new commit. You use it when a fix is sitting on a branch that is not ready, and you need just that fix on main today.

## The task

Work in `~/devops-course/06-rewriting`.

### Part one, clean up the branch

1. On `feature/search`, run `git log --oneline main..HEAD` and look at what you are about to publish. Six commits. Read the messages and decide honestly whether a reviewer could follow them.

2. Start an interactive rebase against `main`. Read the instruction list carefully before you change anything, including the comments at the bottom.

3. Turn those six commits into exactly three, which must be:

   - one commit adding the search function
   - one commit adding the search count helper
   - one commit adding the README documentation

   The `wip`, `wip 2` and `oops remove placeholder` commits are all the same piece of work and belong together. The `add debug file` commit should not exist at all, and `debug.txt` must not be in the final tree. Write real messages.

4. When the rebase finishes, run `git log --oneline main..HEAD` again. Three commits with three sensible messages.

5. Check nothing was lost. `git diff pre-cleanup HEAD` should show exactly one difference: `debug.txt` is gone. If it shows anything else, you dropped work you meant to keep.

### Part two, cherry-pick

`hotfix/log-level` has two commits. The first sets a default log level and is needed on main today. The second adds a line to the README that must never ship.

6. Look at both commits and identify which one you want.

7. Get that one commit onto `main` without bringing the other, and without merging the branch.

8. Confirm `logging.conf` is on `main` and that the internal note is not in `main`'s README.

9. Look at the commit hash of the cherry-picked commit on `main` and compare it to the one on `hotfix/log-level`. They differ. Work out why, and what that will mean when `hotfix/log-level` eventually gets merged.

### Part three, tagging a release

10. `main` already has `v1.0.0`. Merge `feature/search` into `main`.

11. Tag the result. You added new functionality and broke nothing, so under semantic versioning decide whether that is a major, minor or patch bump, and tag accordingly. Use an annotated tag, not a lightweight one, with a message describing the release.

12. Run `git tag -n` and `git show <your tag>` and notice how much more an annotated tag carries.

## How you know you are done

```
./check.sh
```

## Questions to answer

In `ANSWERS.md`:

1. Every commit on your branch got a new hash during the rebase, including the ones you left as `pick`. Why?
2. What is the difference between `squash` and `fixup`, and when would you reach for each?
3. In step 9 the cherry-picked commit had a different hash from the original. What happens when `hotfix/log-level` is later merged into main? Will the change be applied twice?
4. Explain the difference between an annotated tag and a lightweight tag, and why release automation usually insists on annotated ones.
5. Under semantic versioning, what would have to change for you to bump the major version?

## Going further

- Redo part one using `git commit --fixup` and `git rebase -i --autosquash` and work out why people set that up once and never go back.
- Look up `git rebase --onto` and work out what problem it solves that plain rebase cannot.
- Find out what happens to a tag when you `git push` normally, and what you have to do differently to publish it.
