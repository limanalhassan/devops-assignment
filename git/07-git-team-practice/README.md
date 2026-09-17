# 07. Working in a team

**Level:** intermediate
**Time:** about 3 hours
**Prerequisites:** `git/01` to `git/06`, and `linux/07` shell scripting, which this assignment leans on heavily

## Warm up drill

No notes. Fifteen minutes.

Repository, three commits, `.gitignore`. Branch, commit, fast forward merge. Two parallel branches, merge both. Create a conflict and resolve it. Commit and revert. Amend a bad message. Delete an unmerged branch and recover it from the reflog. Then squash three messy commits into one with an interactive rebase, cherry-pick a commit from one branch to another, and create an annotated tag.

That is assignments 01 to 06. This is the drill you should be able to do without pausing by the end of this phase.

## What you will learn

The parts of Git that are actually about other people. Reviewing someone else's work, agreeing a commit convention and enforcing it automatically, and setting up the guard rails that stop bad things reaching main.

## Before you start

```
bash ~/devops-course/course/git/07-git-team-practice/setup.sh
```

That creates `~/devops-course/git/07-team` with a branch called `feature/user-auth` that a colleague has submitted for review.

## Background

Most of what makes Git painful in a team is not Git. It is people committing whatever they like into a shared branch, nobody agreeing what a commit message means, and reviews that consist of the word "LGTM".

Three things fix most of it.

**A commit convention.** Conventional Commits is the common one. The subject looks like `feat(auth): add token validation` or `fix: correct discount rounding`. It reads well, but the real reason to adopt it is that a machine can read it. Release tooling reads your commit types and works out the next version number on its own. `feat` means a minor bump, `fix` means a patch, and a breaking change footer means a major.

**Hooks.** Git runs scripts at certain moments. `commit-msg` runs before a commit is recorded and can reject a badly formatted message. `pre-commit` runs before that and can reject the change itself, which is how you stop a secret being committed rather than finding it in the history six months later. A hook is just a shell script, exactly like the ones you wrote in `linux/07`. It gets arguments, it runs, and its exit code decides what happens: zero lets the commit through, anything else stops it. Hooks in `.git/hooks` are not shared with anyone, so teams put them in a tracked folder and point `core.hooksPath` at it.

**Reviewing properly.** A review is not a syntax check. You are looking for whether this change does what it claims, whether it will behave badly in production, and whether anyone else can maintain it. Say what you found, where, and why it matters. "Change this" is not a review comment. "This swallows every exception, so an expired token and a malformed token both look like a successful login" is.

## The task

Work in `~/devops-course/git/07-team`.

### Part one, review a colleague's branch

1. Read the change properly: `git diff main..feature/user-auth`. Do not skim it. Read the file as it will exist after the merge, not just the diff.

2. There are at least four separate problems in this branch. Some are security problems, some are correctness problems, one is a documentation problem, and the commit messages are their own problem.

3. Write your review in `REVIEW.md` on `main`. For each issue give the file, what is wrong, and what goes wrong in production because of it. Write it as though the author will read it, because in real life they will. Be direct and do not be unkind.

   One of these bugs is subtle and will not show up in any test. The function is supposed to return true or false and there is a path through it where it returns neither.

### Part two, agree a convention and enforce it

4. Create a folder `.githooks` in the repository and tell Git to use it with `core.hooksPath`.

5. Write `.githooks/commit-msg`. It must reject any commit whose subject does not match Conventional Commits, that is a type, an optional scope in brackets, a colon, a space, then a description. Allow the types `feat`, `fix`, `docs`, `chore`, `refactor`, `test` and `ci`. Reject subjects longer than 72 characters. Make it executable and make it print a useful message when it rejects something.

   Test it both ways. A bad message must be refused and a good one must go through. If you have never written a hook before, remember it receives the path to the message file as its first argument.

6. Write `.githooks/pre-commit`. It must scan what is about to be committed and refuse anything that looks like an AWS access key, that is the letters `AKIA` followed by sixteen uppercase letters or digits. It must also refuse a commit that adds a `.env` file. Make it executable.

   Test it by trying to commit a file containing `AKIAIOSFODNN7EXAMPLE` and confirming you cannot.

7. Add `.github/CODEOWNERS` making yourself the owner of `auth.py` and anyone else the owner of the README. Find out what CODEOWNERS actually does on GitHub, because it does nothing on your machine.

8. Commit all of this using messages that satisfy your own hook. Your hook should be enforcing itself from this point on.

### Part three, branching strategy

9. In `ANSWERS.md`, describe how your team should branch. Pick one, trunk based development with short lived branches, or long lived develop and release branches. Say which you would pick for a team of four shipping several times a day, and what would make you pick the other.

## How you know you are done

```
bash ~/devops-course/course/git/07-git-team-practice/check.sh
```

The checker actually runs your hooks with good and bad input. It is not looking at whether the files exist, it is looking at whether they work.

## Questions to answer

In `ANSWERS.md`:

1. List the problems you found in `feature/user-auth` and rank them by how much damage they would do in production. Justify your ordering.
2. Hooks in `.git/hooks` are not committed and not shared. Why did Git make that choice, and what is the security argument for it?
3. Your `pre-commit` hook blocks AWS keys. Name two ways a determined or careless person still gets a secret into the repository despite it.
4. What does a protected branch on GitHub give you that a local hook cannot?
5. Conventional Commits lets tooling calculate version numbers. What has to be true about your team's discipline for that to be trustworthy?

## Going further

- Look at `pre-commit` the framework, as opposed to the hook of the same name, and work out what it adds over a hand written script.
- Set up commit signing with an SSH key and get the Verified badge on a commit.
- Find out what `git config --global core.hooksPath` would do and why it is usually a bad idea.
