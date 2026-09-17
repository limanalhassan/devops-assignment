# 02. Files and directories

**Level:** beginner
**Time:** about 2 hours
**Prerequisites:** `linux/01`

## Warm up drill

Do this before reading anything else. No notes, no searching, and no looking back at `linux/01`. Give yourself five minutes.

Go to your home folder and print where you are. Make a folder called `drill` with a folder called `inner` inside it, in one command. Go into `inner`. Create a file containing one line of text using `echo`, then open it in nano, add a second line, save and exit. Write a two line script that prints a message and run it with `bash`. Go home and delete the `drill` folder.

If you had to stop and look anything up, do the whole drill again. Every assignment in this phase opens with a drill, and each one repeats everything that came before. The point is that these commands end up costing you no thought at all.

## What you will learn

The commands you will type every single day: copying, moving, renaming and deleting, finding a file when you do not know where it is, and reading a huge file without opening it.

## Before you start

Build your messy folder:

```
bash ~/devops-course/course/linux/02-files-and-directories/setup.sh
```

That creates `~/devops-course/linux/02-files/downloads`, which looks like everyone's downloads folder.

## Background

**Moving and copying.** `cp source destination` copies, `mv source destination` moves. `mv` is also how you rename, because renaming is just moving a file to a new name in the same folder. To copy a folder and everything in it you need `cp -r`, where `r` stands for recursive.

**Deleting.** `rm file` deletes a file, `rmdir folder` deletes an empty folder, and `rm -r folder` deletes a folder with everything inside it. There is no recycle bin. Nothing asks "are you sure". Deleted means gone. Read an `rm` command twice before you press Enter, especially one with a wildcard in it.

**Wildcards.** `*` matches any number of characters, so `*.jpg` means every name ending in `.jpg`. The shell expands the wildcard into a list of names before the command even runs. Two things catch people out. `*` does not match hidden files, the ones whose names start with a dot. And `*` only looks in the current folder, never in the folders inside it.

**Names with spaces.** The shell splits commands on spaces, so `cat my file.txt` tries to read two files, `my` and `file.txt`. Put the name in quotes, `cat "my file.txt"`, or press Tab and let the shell complete it for you.

**Finding things.** `find` searches a folder and every folder inside it. `find . -name "*.log"` lists every log file from here down. Add `-type f` for files only or `-type d` for folders only. Put quotes around the pattern, otherwise the shell expands the `*` before `find` ever sees it.

**Reading big files.** Never open a 200MB log in nano. `wc -l file` counts the lines, `head -n 5 file` shows the first five, `tail -n 5 file` the last five, and `less file` lets you scroll through it (press `q` to quit). `tail -f file` keeps showing new lines as they are written, which is how you watch a live log.

**Links.** `ln -s target linkname` creates a symbolic link, a small file that points at another file. Opening the link opens the target. Servers use links all the time, for example a `current` link pointing at whichever release is live.

## The task

Work in `~/devops-course/linux/02-files`.

### Part 1: Look before you touch

1. Go into `downloads` and list everything, hidden files included.
2. Find out how much space the folder uses with `du -sh`.
3. Use `find` to list every folder inside `downloads`, then every file.

### Part 2: Organise it

4. From inside `~/devops-course/linux/02-files`, create `organised` with four folders inside it, `images`, `logs`, `configs` and `documents`. Do it in one `mkdir` command.
5. Move all twelve photos into `organised/images` with a single command.
6. Move every log file in the top of `downloads` into `organised/logs`, including `access.log`.
7. Move `nginx.conf`, `app.yaml` and `.env.example` into `organised/configs`. Try it with a wildcard first and notice which file gets left behind. Then move that one too.
8. Move `Quarterly Report FINAL (2).pdf` into `organised/documents`.
9. `downloads/unused` is an empty folder. Remove it with the command that refuses to delete a folder that still has something in it.

### Part 3: Clean up

10. There are `.tmp` files scattered all over `downloads`, some of them several folders deep. Find all of them first and look at the list. Then delete every one of them. Leave everything else in `old_projects` exactly where it is.

### Part 4: Find and read

11. Somewhere in `downloads` is a hidden file called `.api_key`. Find its full path using `find`, not by looking through folders by hand, and write that path in `ANSWERS.md`.
12. Without opening `access.log` in an editor, find out how many lines it has and look at its first and last five lines. Write the number of lines in `ANSWERS.md`.

### Part 5: Copy and link

13. Make a backup: copy the whole `organised` folder, with everything inside it, to `backup/organised`.
14. Prove the backup is identical with `diff -r organised backup/organised`. No output means no differences.
15. In `~/devops-course/linux/02-files`, create a symbolic link called `latest.log` that points to `organised/logs/app-2026-09-06.log`, the newest log. Run `cat latest.log` and `ls -l` to see what a link looks like.

### Questions

Add these to `ANSWERS.md`:

1. In step 7, why did the wildcard leave one file behind?
2. What is the difference between `rm -r` and `rmdir`, and why would you ever want the one that refuses?
3. What is the difference between copying a file and making a symbolic link to it? What happens to the link if you delete the target?
4. You need to delete every `.log` file older than a week on a server. Why is it a good idea to run the `find` command without `-delete` first?

## How you know you are done

```
bash ~/devops-course/course/linux/02-files-and-directories/check.sh
```

## Going further

- Find every file in `downloads` bigger than 100 kilobytes using `find` with `-size`.
- Use `find` with `-mtime` to find files changed in the last day.
- Find out what `mv -i` and `cp -i` do, and why some people set them up to always behave that way.
