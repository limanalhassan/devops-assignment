# 03. Conflicts, merge and rebase

**Level:** beginner going into intermediate
**Time:** about 2 hours
**Prerequisites:** `git/01` and `git/02`

## Warm up drill

No notes, no searching. Ten minutes.

In a throwaway folder: initialise a repository, make three commits with proper messages, add a working `.gitignore`, create a branch, commit on it, merge it back as a fast forward, then create two branches from the same commit, commit on each, merge both, and confirm the second merge produced a merge commit. Show the result with a graph log. Delete the folder afterwards.

If any step made you stop and think, do the whole drill again from the start.

## What you will learn

How to read a conflict instead of panicking at it, how to resolve one properly, and what rebase does differently from merge. You will hit the same conflict twice, once each way.

## Before you start

```
bash ~/devops-course/course/git/03-git-merge-conflicts/setup.sh
```

That creates `~/devops-course/git/03-conflicts` with three branches that have all edited the same file.

## Background

A conflict happens when two branches change the same lines of the same file and Git cannot decide which one wins. Git does not guess. It stops, writes both versions into the file, and hands the problem to you.

The markers look like this:

```
<<<<<<< HEAD
timeout: 45
=======
timeout: 60
>>>>>>> feature/timeouts
```

Everything between `<<<<<<<` and `=======` is what the branch you are on already had. Everything between `=======` and `>>>>>>>` is what the incoming branch wants. Your job is to delete the markers and leave the correct final content, which is sometimes one side, sometimes the other, and sometimes neither.

The single most common mistake is deleting the markers but leaving both values in the file, or leaving a stray `=======` behind. That commits happily and breaks in production later. Always look at the file after resolving.

Merge and rebase both combine branches, but they do different things to history. Merge keeps both lines of development and joins them with a merge commit, so the history shows what really happened. Rebase rewrites your commits so they appear to have been made after the latest commit on the target branch, giving you a straight line that never actually happened. Teams argue about this endlessly. You need to be able to do both.

The rule that matters: never rebase commits that other people have already pulled.

## The task

Work in `~/devops-course/git/03-conflicts`.

The team has decided the correct final configuration is port 9090, timeout 60, workers 4, retries 3. You are going to arrive at that by combining the branches.

### Part one, merge

1. On `main`, run `git merge feature/timeouts`. It will fail. Read the error properly.

2. Run `git status`. It tells you exactly which files are conflicted and what your options are. Read all of it.

3. Open `config.yml` and look at what Git did to it. Work out which side is which before you change anything.

4. Resolve it. The timeout should end up as 60. The worker count from `main` and the retries setting from the branch should both survive. Nothing should be lost.

5. Confirm no conflict markers are left anywhere in the file.

6. Stage the resolved file and complete the merge. Notice that you commit without passing a message, so nano opens with one already written. Save and exit.

7. Run `git log --oneline --graph` and find the merge commit.

### Part two, rebase

`feature/port-change` also edits `config.yml` and was branched from the same starting point. This time do not merge it.

8. Switch to `feature/port-change` and rebase it onto `main`. It will conflict too.

9. Notice that `git status` says something different this time. During a rebase you are not on a branch, you are partway through replaying commits. Read what it says carefully.

10. Resolve the conflict. Port should end up as 9090 and everything main gained must survive.

11. Continue the rebase. The command is not `git commit`. Find the right one. Nano will open showing the commit message, save and exit to carry on.

12. Switch to `main` and merge `feature/port-change`. Because you rebased, this is a fast forward and no merge commit appears.

13. Run `git log --oneline --graph`. You should see one merge commit from part one and a straight line after it. Look at the commit hash of "Move service to port 9090" and compare it to what `setup.sh` originally created. It changed. Understand why.

14. Delete both feature branches.

## How you know you are done

```
bash ~/devops-course/course/git/03-git-merge-conflicts/check.sh
```

## Questions to answer

In `ANSWERS.md` inside the repository:

1. In part two the commit hash of the branch commit changed even though its content did not. Why?
2. Why is rebasing a branch that a colleague has already pulled a problem for them? Describe what actually goes wrong on their machine.
3. Your team wants a clean linear history but also wants an accurate record of when work happened. Those pull in opposite directions. Which would you choose for a shared main branch, and why?

## Going further

- Break the merge on purpose. Start it, then run `git merge --abort` and confirm you are back where you started.
- Look up `git rerere` and work out what problem it solves for people who resolve the same conflict repeatedly.
- Find out what the three sides in `git checkout --conflict=diff3` are and why they make some conflicts much easier to resolve.
