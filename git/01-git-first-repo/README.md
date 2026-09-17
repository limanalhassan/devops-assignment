# 01. Your first repository

**Level:** beginner
**Time:** about 90 minutes
**Prerequisites:** the whole Linux phase, `linux/01` to `linux/09`

## What you will learn

How Git actually stores your work, the difference between your working folder, the staging area and a commit, and how to stop files you never wanted from ending up in your history.

## Before you start

Everything in this phase happens inside the same Ubuntu terminal you used for the Linux phase. On a Mac that means inside your Multipass VM, on Windows inside the Ubuntu window, not PowerShell.

Check Git is there:

```
git --version
```

If that says command not found, go back to `linux/01` and finish Part 1.

## Background

Git is not a backup tool and it is not Dropbox. It records snapshots of your project, and each snapshot knows which snapshot came before it. That chain is the history.

There are three places a file can be:

**Working directory.** The files as they exist on disk right now. You edit here.

**Staging area.** A list of the changes you have decided belong in the next snapshot. `git add` puts things here. This step confuses everyone at first. It exists so you can commit two of the five files you changed instead of all five.

**Repository.** The committed snapshots. `git commit` takes whatever is staged and records it permanently.

The other thing worth knowing on day one: anything you commit is very hard to remove later. If you commit a password, treat that password as leaked, even after you delete it. This is why `.gitignore` exists and why you will set one up in this assignment.

## The task

Work in `~/devops-course/git/01-first-repo`. Create it yourself.

1. Set your name and email in Git's global config so your commits are attributed to you. Use the same email you use on GitHub.

   Then tell Git to use nano whenever it needs you to write something:

   ```
   git config --global core.editor nano
   ```

   Do not skip this. From the next assignment onwards Git will sometimes open an editor for you, and if you have not set one it opens vim, which is very hard to get out of the first time. You already know nano from the Linux phase.

2. Create the folder and turn it into a Git repository. Look at what `git init` created. Run `ls -a` and find the `.git` directory. Do not edit anything inside it.

3. Create a file called `notes.md` with nano and write three or four lines in it about what you expect to learn from this course.

4. Run `git status` before staging anything. Read the output properly instead of skipping it. Then stage `notes.md` and run `git status` again. Notice what changed in the wording.

5. Commit it. Your commit message subject line must be under 50 characters, written in the imperative mood, and must not end with a full stop. "Add initial notes" is right. "added some notes." is wrong.

6. Make two more commits. Each one should be a real change to `notes.md` or a new file. Do not make three commits that say "update". Each message should say what changed and be understandable by someone who was not there.

7. Now the important part. Create two files that should never be in a repository: a file called `secrets.txt` containing a fake API key, and a file called `app.log` containing any text.

8. Write a `.gitignore` that keeps both of those out. Ignore `secrets.txt` by name and ignore log files by pattern rather than by name, so a future `debug.log` is also caught.

9. Commit the `.gitignore`. Then run `git status` and confirm it reports a clean working tree even though `secrets.txt` and `app.log` are still sitting on disk. If it does not, your ignore rules are wrong.

10. Run `git log --oneline` and look at your history. Then run `git log -p` and read what a commit actually contains.

## How you know you are done

```
bash ~/devops-course/course/git/01-git-first-repo/check.sh
```

## Questions to answer

Create `ANSWERS.md` in your repository and answer these in your own words. Two or three sentences each is plenty.

1. What is the staging area for? Give a situation where committing everything at once would be the wrong thing to do.
2. You accidentally commit a database password and push it. Deleting the file in the next commit is not enough. Why not?

## Going further

Only if you finished the above.

- Run `git cat-file -p HEAD` and then follow the tree hash it prints. See if you can walk from a commit down to the actual contents of `notes.md`.
- Find out what `git add -p` does and use it to commit half of a change to a file.
