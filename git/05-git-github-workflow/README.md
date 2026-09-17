# 05. The pull request workflow

**Level:** intermediate
**Time:** about 2 hours
**Prerequisites:** `git/01` to `git/04`, `linux/08` for your SSH key, and a free GitHub account

## Warm up drill

No notes. Twelve minutes.

Throwaway folder. Repository, three commits, `.gitignore`. Branch, commit, fast forward merge. Two parallel branches, merge both, produce a merge commit. Create a conflict and resolve it. Then make a commit, revert it, make another commit with a bad message and fix the message with amend. Finally delete a branch that has an unmerged commit and recover it from the reflog.

That is every core action from assignments 01 to 04. You will do it again next assignment.

## What you will learn

How work actually reaches a shared codebase in a real team. From here on, every assignment in this course is submitted this way, so you will repeat this workflow around fifty more times.

## Background

You do not push to other people's repositories. You fork, which gives you your own copy on GitHub, you push to your fork, and you ask the original repository to pull your changes in. That request is the pull request.

Three remotes matter and people mix them up constantly:

**origin** is your fork. You push here.
**upstream** is the original course repository. You pull from here. You never push here.

Your fork does not update itself. While you work, the course repository moves on, and your fork silently falls behind. Keeping it in sync is a thing you do deliberately, and forgetting is the single most common cause of "my pull request has conflicts and I do not know why".

The other thing to understand early: a pull request is a conversation, not a delivery. Review comments are normal and getting them is not a sign you did badly. You respond by pushing more commits to the same branch, and the pull request updates itself.

## The task

The course repository is the one you cloned in `linux/01`, and its address is in the `course.env` file at the top of it. Ask your instructor if that file still says CHANGE-ME.

1. Fork the course repository on GitHub using the Fork button. Read what GitHub tells you it did.

2. Give GitHub your SSH public key, so it knows it is you without asking for a password. You made this key in `linux/08`.

   Print it:

   ```
   cat ~/.ssh/id_ed25519.pub
   ```

   Copy the whole single line it prints, starting `ssh-ed25519`. On GitHub go to your profile picture, **Settings**, **SSH and GPG keys**, **New SSH key**. Give it a title like "course VM", paste the line into the Key box, and save.

   Never paste the file without `.pub` anywhere. That one is your private key and it never leaves your machine.

   Test it:

   ```
   ssh -T git@github.com
   ```

   The first time it asks whether to trust GitHub's fingerprint. Type `yes`. You are done when it says `Hi <your-username>! You've successfully authenticated`. It then says GitHub does not provide shell access, which is expected and not an error.

3. Clone **your fork**, not the original, into `~/devops-course/git/05-workflow`. On your fork's GitHub page press the green Code button, choose **SSH**, and copy that address. It starts `git@github.com:`, not `https://`.

4. Run `git remote -v`. You have one remote called `origin` and it points at your fork.

5. Add a second remote called `upstream` pointing at the original course repository. Confirm with `git remote -v` that you now have four lines.

6. Create a branch named `<your-name>/git-05`, all lowercase, for example `ama/git-05`. This naming pattern, your name then the phase and number, is used for every submission from now on.

7. Create a folder `submissions/<your-name>/` and add a file `about.md` in it. Write who you are, what you want out of this course, and what you found hardest so far. Be honest about the last one, it tells your instructor what to spend time on.

8. Nobody has seen your Linux work yet. Copy every `ANSWERS.md` from `~/devops-course/linux/` into `submissions/<your-name>/linux/`, keeping each one inside a folder named after its assignment, so you end up with `submissions/<your-name>/linux/02-files/ANSWERS.md` and so on. Do it with the commands from `linux/02`, not by hand one at a time. Copy `INCIDENT.md` from `linux/09` as well.

9. Commit it with a proper message and push the branch to `origin`. Read the output. Git prints a URL you can click to open the pull request.

10. Open a pull request from your branch into the course repository's `main`. Write a description that says what you did. "Assignment 05" is not a description.

11. Your instructor will leave review comments. When they do, fix what was raised and push more commits to the same branch. Do not open a second pull request and do not force push. Watch the pull request update on its own.

12. While you wait, the course repository has moved on. Sync your fork: fetch from `upstream`, and bring `upstream/main` into your local `main`. Then push your updated `main` to `origin` so your fork on GitHub is current too.

13. Confirm with `git log --oneline main..upstream/main` that there is nothing left to pull. Empty output means you are in sync.

## How you know you are done

This is the one assignment where you work inside your own clone rather than a folder the checker already knows about, so stand inside your clone and put a dot on the end, which means "this folder":

```
cd ~/devops-course/git/05-workflow
bash ~/devops-course/course/git/05-git-github-workflow/check.sh .
```

The check covers everything on your machine. It cannot see your pull request, so the last two items are confirmed by your instructor in the review.

## Questions to answer

Add `ANSWERS.md` to your submissions folder:

1. What is the practical difference between `git fetch` and `git pull`? Describe a situation where using pull surprised you.
2. Why does this course use forks and pull requests instead of just adding everyone as a collaborator with push access to main?
3. Your pull request has been open for three days and now shows conflicts you did not create. What happened, and what do you do about it?
4. You pushed a commit containing a real AWS key to your fork and then deleted it in the next commit. Is the key safe? Explain what you would actually do.

## Going further

- Install the `gh` CLI and do steps 7 to 10 without opening a browser.
- Find out what a draft pull request is for.
- Look at a pull request in a large open source project and read the review thread rather than the code. Notice how much of it is about intent rather than syntax.
