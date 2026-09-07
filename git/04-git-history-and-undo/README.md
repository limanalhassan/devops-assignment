# 04. Reading history and undoing things

**Level:** intermediate
**Time:** about 3 hours
**Prerequisites:** assignments 01 to 03

## Warm up drill

No notes, no searching. Ten minutes.

Throwaway folder. Initialise a repository, three proper commits, a working `.gitignore`. Branch, commit, fast forward merge. Two parallel branches, commit on each, merge both, produce a merge commit. Then create a conflict on purpose and resolve it. Graph log at the end. Delete the folder.

Every assignment from here adds to this drill. If it took you more than ten minutes, run it again tomorrow before you start.

## What you will learn

How to work out what happened in a repository you did not write, and how to undo almost anything. This is the assignment that stops you being afraid of Git.

## Before you start

```
./setup.sh
```

That creates `~/devops-course/04-history` with eight commits by three different people. One of those commits introduced a bug.

## Background

Almost everything in Git is recoverable. People are scared of it because the recovery commands have unhelpful names and because `reset --hard` genuinely does destroy uncommitted work. Once you understand the three resets and the reflog, that fear goes away.

**revert** creates a new commit that undoes an old one. History keeps both. This is the only safe way to undo something other people have already pulled.

**reset** moves your branch label to a different commit. What happens to your files depends on the flag:

- `--soft` moves the label, leaves your changes staged
- `--mixed`, the default, moves the label and unstages your changes, files untouched
- `--hard` moves the label and throws away your changes, files included

`--hard` is the only one that loses work, and only uncommitted work.

**reflog** is a log of everywhere HEAD has been on your machine, including commits no branch points at any more. Deleted a branch by accident? It is in the reflog. This is why "I lost my work" is almost never true.

**stash** puts your uncommitted changes on a shelf so you can switch branches, then puts them back.

## The task

Work in `~/devops-course/04-history`.

### Part one, find the bug

1. Run the tests: `python3 test_pricing.py`. They fail. A 10 percent discount on 100 is coming out as 110.

2. Look at the history. `git log --oneline` first, then `git log --oneline --stat` to see which commits touched which files.

3. Use `git blame pricing.py` to find which commit last changed the line that is wrong, and who wrote it.

4. Use `git show <hash>` on that commit to confirm it is the one that broke the behaviour. Read the diff and understand exactly what changed.

5. Write the short hash and the author's name into `ANSWERS.md` under a heading `## Bug commit`.

### Part two, undo it properly

6. Other people already have this history, so do not rewrite it. Revert the bad commit and let Git write the revert message itself.

7. The revert will not apply cleanly. It conflicts, because work was added to that file after the bad commit landed. Resolve it.

   Read the conflict carefully before you touch it. One side has the broken discount plus two functions that were written later. The other side has the correct discount and nothing else. Taking either side wholesale is wrong. The lazy resolution here silently deletes two working functions and the tests will not catch it, which is exactly how this mistake reaches production.

8. Finish the revert. The command is not `git commit`. Then run the tests and confirm both that they pass and that `format_currency` and `apply_tax` are still there.

### Part three, the three resets

9. Change `README.md` and stage it. Now unstage it without losing the edit. Then discard the edit entirely.

10. Make a deliberately bad commit with the message `wip`. Undo it with `git reset --soft HEAD~1` and check `git status`. Your changes should still be staged.

11. Commit it again, properly this time, with a message that describes the change. There should be no commit called `wip` anywhere in the final history.

12. Amend that commit to add a body line explaining why the change was made. Confirm with `git log -1 --format=%B` that the body is there.

### Part four, stash and reflog

13. Start editing `pricing.py` but do not commit. Now you need to look at something on another branch. Create a branch called `feature/scratch`, and get there without losing or committing your edit. Come back and restore it.

14. On `feature/scratch`, make one commit with the message `Add experimental rounding helper`. Switch back to `main` and delete that branch with `git branch -D`. Git will warn you that the work is unmerged. Do it anyway.

15. The commit still exists. Find it in `git reflog` and recreate the branch `feature/scratch` pointing at exactly the same commit. Verify the commit is intact.

16. Make sure your stash list is empty and your working tree is clean.

## How you know you are done

```
./check.sh
```

## Questions to answer

Add these to `ANSWERS.md`:

1. Why is revert the correct tool in step 6 rather than reset, given that reset would also have removed the bad change?
2. Explain what each of `--soft`, `--mixed` and `--hard` does to the branch label, the staging area and your files. Three short lines.
3. In step 7 the conflict offered you two sides and neither was correct on its own. Why does that situation come up so often with revert specifically?
4. You run `git reset --hard` and lose an hour of work. Under what circumstances is it recoverable and under what circumstances is it genuinely gone?
5. How long does something stay in the reflog, and what does that mean for relying on it?

## Going further

- `git log -S "apply_discount"` finds every commit that changed the number of occurrences of that string. Work out when that is more useful than blame.
- Find the commit that introduced the bug again, this time using `git bisect` with the test script as the test. You will do this properly in assignment 08.
