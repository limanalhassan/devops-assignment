# 03. Permissions and ownership

**Level:** beginner
**Time:** about 2 hours
**Prerequisites:** `linux/01` and `linux/02`

## Warm up drill

No notes. Eight minutes.

In your home folder, make a folder `drill` with `a/b/c` inside it in one command. Create three files in `drill` with `touch`, one ending `.txt` and two ending `.tmp`. Copy the `.txt` file into `a/b/c`, rename the original, and delete both `.tmp` files with a single wildcard. Use `find` to list every file under `drill`. Create a symbolic link to the copied file. Put a hundred numbered lines into a file with `seq 1 100 > numbers.txt` and show only the last three. Delete `drill`.

## What you will learn

Who is allowed to read, change and run each file on a Linux machine, how to change that, and why so many deploys fail with `Permission denied`.

## Before you start

```
bash ~/devops-course/course/linux/03-permissions/setup.sh
```

That builds `~/devops-course/linux/03-permissions/notes-deploy`, a small project where almost every permission is wrong. The setup creates one file as the administrator, so it may ask for your password.

## Background

Run `ls -l` and each line starts with something like `-rwxr-x---`. Ignore the first character for now, it is `-` for a file and `d` for a directory. The other nine are three groups of three:

```
rwx   r-x   ---
user  group others
```

**user** is the file's owner, **group** is everyone in the file's group, and **others** is everyone else. `r` is read, `w` is write and `x` is execute. A dash means that permission is missing.

**On a directory the letters mean something different.** `r` lets you list the names inside, `w` lets you create and delete files inside, and `x` lets you go into it at all. A directory without `x` cannot be entered, even by someone allowed to read the files in it.

**The numbers.** Each permission has a value: read is 4, write is 2, execute is 1. Add them up for each group of three. `rwx` is 7, `r-x` is 5, `r--` is 4, and `---` is 0. So `rwxr-x---` is `750`. Three numbers are worth knowing by heart:

- `644` for normal files: the owner can edit, everyone else can read
- `755` for scripts and directories: the owner can edit, everyone else can read and run or enter
- `600` for secrets: the owner only, nobody else at all

**Changing permissions.** `chmod 640 file` sets the numbers directly. `chmod u+x file` adds execute for the user, `chmod go-w file` removes write from group and others. Both styles are common, so you need to read both.

**Changing ownership.** `chown` changes the owner, `chgrp` changes the group. Giving a file away to another user needs administrator rights, so those normally run with `sudo`.

**sudo.** `sudo` runs one command as root, the administrator, who can read and change anything. When you get `Permission denied`, reaching for `sudo` straight away is the most common bad habit in this whole field. First work out why you were denied. Usually the permissions are wrong and should be fixed, not bypassed.

**Groups.** A group lets several users share access to something. `sudo usermod -aG deployers ama` adds ama to the `deployers` group. The `-a` matters enormously. Without it, `-G` replaces your whole list of groups instead of adding to it, and you can remove yourself from the `sudo` group and lose administrator access to your own machine. Group changes only apply to new logins, which catches everyone the first time.

## The task

Work in `~/devops-course/linux/03-permissions/notes-deploy`.

### Part 1: Read what is there

1. Run `ls -l` and `ls -ld *` and read every line. Work out what each set of permissions means before you change anything.
2. Run `stat -c '%a %U %G %n' deploy.sh secrets secrets/db.env public public/index.html` to see the same thing as numbers.
3. In `ANSWERS.md`, write down each of those five, its number, and in one plain sentence what is wrong with it. `ANSWERS.md` goes in `~/devops-course/linux/03-permissions`, one level above the project.

### Part 2: Fix the files

4. Try to run `./deploy.sh`. Read the error. Make it executable for the owner and group and nothing at all for others. Its number should end up as `750`. Run it again.
5. `secrets/db.env` holds a database password and currently anyone on the machine can change it. Make it readable and writable by you only.
6. The `secrets` directory itself lets anyone in and anyone create files. Make it so only you can enter it, list it and change it.
7. A web server running as a different user needs to read `public/index.html`. Give the file normal read permissions, and give the `public` directory normal directory permissions so it can be entered.

### Part 3: A file you do not own

8. Run `cat config/legacy.conf`. Read the error, then run `ls -l config` and explain in `ANSWERS.md` exactly why you were refused.
9. Read it with `sudo cat`. Then decide this file should belong to you, and change its owner and group to your own user so you can read it without `sudo`. Your username is what `whoami` prints.

### Part 4: Groups and a shared folder

10. Run `groups` to see which groups you are in. Write them down, you will want to compare later.
11. Create a group called `deployers` and add yourself to it. Use `-a`.
12. Run `groups` again. `deployers` is missing. It is not broken. Log out and back in, then run it again:
    - Mac: type `exit`, then `multipass shell devops`
    - Windows: close every Ubuntu window, wait ten seconds, open Ubuntu again
    - Linux: log out of your desktop and back in, or run `newgrp deployers` for the current terminal
13. Confirm you are in `deployers` **and still in every group you were in before**, `sudo` included.
14. The `shared` folder is where the whole deploy team puts release files. Change its group to `deployers` and set its permissions to `2775`. The leading `2` is the setgid bit, so every file created inside the folder belongs to the `deployers` group automatically instead of to whoever created it.
15. Create `shared/release-notes.txt` and check with `ls -l` that its group is `deployers`.

### Part 5: Where the defaults come from

16. Run `umask`. Create a new file and a new folder and look at their permissions. In `ANSWERS.md`, explain how the umask value relates to the permissions they got.

### Questions

Add these to `ANSWERS.md`:

1. Why does a directory need `x` before anyone can use the files inside it, even when the files themselves are readable?
2. A colleague fixes a `Permission denied` on a web server by running `chmod -R 777` on the whole site. The site works again. What have they actually done, and what would you do instead?
3. Why does `usermod -aG` need the `-a`? What exactly happens without it?
4. Why did `groups` not show `deployers` straight after you were added?

## How you know you are done

```
bash ~/devops-course/course/linux/03-permissions/check.sh
```

## Going further

- Find out what the sticky bit is and why `/tmp` has it. Run `ls -ld /tmp`.
- Look at `ls -l /etc/shadow` and `ls -l /etc/passwd`. Why are they so different?
- Find every file in your home folder that anyone can write to, using `find` with `-perm`.
