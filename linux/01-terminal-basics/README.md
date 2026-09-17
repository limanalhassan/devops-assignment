# 01. Your terminal

**Level:** absolute beginner, assumes nothing
**Time:** about 2 hours, most of it installing things once
**Prerequisites:** a computer you are allowed to install software on

Start here. This is the first assignment of the whole course.

Do not skip it because you have read about Linux or Git already. Reading about a terminal and being able to use one are different skills, and every assignment after this depends on the second.

## What you will learn

How to get a Linux machine to work on, whatever computer you have. How to find out where you are in it, move around, create and edit files, and run a script. And how to get the course files onto that machine.

## Before you start

You need about 10GB of free disk space and an internet connection. Nothing else.

## Background

The terminal is a window where you type commands instead of clicking. It feels unfriendly for about a week and then it feels faster than clicking, permanently. Almost every server you will ever work on runs Linux and has no mouse at all.

**Why everyone uses Ubuntu.** This course runs on Ubuntu, one of the most common Linux systems on servers. Your laptop might be Windows or a Mac, and that is fine, you will run Ubuntu inside it. Everyone doing the course then has the same commands, the same error messages and the same checkers. Macs have a terminal of their own and it looks similar, but it is not Linux, and several later assignments would quietly break on it.

Three ideas cover most of the confusion beginners have.

**You are always somewhere.** The terminal has a current folder, called the working directory. Commands act on that folder unless you tell them otherwise. Most "No such file or directory" errors are you being somewhere other than where you thought.

**A path is directions to a file.** An absolute path starts from the top of the disk and works from anywhere: `/home/ubuntu/notes.md`. A relative path starts from wherever you are now: `notes.md`. `~` is shorthand for your home folder. `..` means the folder above this one.

**A command is a program plus arguments.** `ls -la /tmp` is the program `ls`, an option `-la`, and an argument `/tmp`. Spaces separate them, which is why file names with spaces in them cause trouble.

## The task

### Part 1: Get Ubuntu

Follow the section for your computer and skip the others.

#### Windows

You will use WSL, which runs a real Ubuntu inside Windows.

1. Right click the Start button and choose **Terminal (Admin)** or **PowerShell (Admin)**.
2. Run:

   ```
   wsl --install -d Ubuntu-24.04
   ```

3. Restart your computer when it asks.
4. An Ubuntu window opens after the restart and asks you to create a username and password. **The password does not appear as you type it.** Nothing is broken. Type it and press Enter. Write it down, you will need it.
5. From now on, open Ubuntu from the Start menu by typing `Ubuntu`.

Every command in this course goes into the **Ubuntu** window. Not PowerShell, not Command Prompt. They look alike and they are different machines. If something behaves strangely later, check which window you are typing in first.

#### Mac

You will use Multipass, a free tool that runs Ubuntu in a small virtual machine on your Mac.

1. Download and install Multipass from `https://canonical.com/multipass/install`.
2. Open the Mac's own Terminal. Press Command and Space, type `Terminal`, press Enter.
3. Create your Ubuntu machine. This takes a few minutes the first time:

   ```
   multipass launch 24.04 --name devops --cpus 2 --memory 2G --disk 15G
   ```

4. Go into it:

   ```
   multipass shell devops
   ```

   The prompt changes to something like `ubuntu@devops:~$`. You are now inside Ubuntu.

You now have two kinds of terminal and it matters which one you are in. The course happens in the one whose prompt says `ubuntu@devops`. Whenever you come back to the course, open Terminal and run `multipass shell devops`. If it says the machine is stopped, run `multipass start devops` first.

#### Linux

If you are already running Ubuntu 22.04 or newer, or Debian 12, open a terminal and carry on. On anything else, install Multipass with `sudo snap install multipass` and follow the Mac steps from step 3.

#### Everyone, inside Ubuntu

Install the tools the course uses:

```
sudo apt update
sudo apt install -y git python3 nano curl
```

`sudo` runs a command as the administrator, and it may ask for your password. The password stays invisible as you type it.

Check it worked:

```
git --version
python3 --version
```

Both should print a version number.

### Part 2: Work out where you are

Type each of these one at a time and read the output before you type the next.

1. `pwd` prints your working directory. This is where you are.
2. `ls` lists what is in it.
3. `ls -la` lists everything, including hidden files, with details. Files whose names start with a dot are hidden.
4. `cd /` moves you to the very top of the filesystem. Run `pwd` and `ls` again and look at what lives up there.
5. `cd ~` takes you home from anywhere. Run `pwd` to confirm.
6. `cd ..` moves up one level. Try it, run `pwd`, then `cd ~` to come back.

Stop and think about this for a moment. `ls notes.md` and `ls ~/notes.md` are different commands. The first depends on where you are standing, the second does not. That difference causes more beginner confusion than anything else in this assignment.

### Part 3: Make some things

1. Create the folder for this assignment and go into it:

   ```
   mkdir -p ~/devops-course/linux/01-terminal
   cd ~/devops-course/linux/01-terminal
   ```

   `-p` creates any missing parent folders as well.

2. Check you are in the right place with `pwd`. It should end in `devops-course/linux/01-terminal`.

3. Create an empty file and list it:

   ```
   touch first.txt
   ls -l
   ```

4. Put text in a file and read it back:

   ```
   echo "hello from the terminal" > notes.md
   cat notes.md
   ```

   A single `>` replaces what is in the file. A double `>>` adds to the end. Try both and use `cat` to see the difference.

### Part 4: Edit a file properly

You need an editor for anything longer than a line. This course uses **nano**, because it is on every Linux machine and it is the simplest thing that works.

```
nano notes.md
```

You are now inside the editor and you can type normally. The shortcuts are listed at the bottom, where `^` means the Control key. To save, press **Ctrl and O**, then **Enter** to confirm the file name. To leave, press **Ctrl and X**.

Everyone gets stuck in nano once. Those three keys are the way out.

Now use nano to create `ANSWERS.md` in this folder, and answer these in your own words:

1. What does `pwd` tell you, and why does it matter before you run a command?
2. What is the difference between an absolute path and a relative path? Give an example of each from your own machine.
3. What does `~` mean?
4. You run a command and get `No such file or directory`, but you are sure the file exists. What is the most likely explanation?

### Part 5: Run a script

A script is a text file full of commands that run one after another. That is all it is.

1. Create `hello.sh` with nano and put this in it, using your own name:

   ```bash
   #!/usr/bin/env bash
   echo "Ama is ready to start the course"
   ```

   Keep the word **ready** in the line, because the checker looks for it.

2. Run it:

   ```
   bash hello.sh
   ```

3. Now try it the other way:

   ```
   ./hello.sh
   ```

   That fails with `Permission denied`. A file is not allowed to run as a program until it is marked executable. Mark it and try again:

   ```
   chmod +x hello.sh
   ./hello.sh
   ```

**The rule for this course:** always run scripts as `bash something.sh`. It works whether or not the file is executable, which is one less thing to go wrong while you are learning. You still need to recognise `Permission denied` when you meet it on a real server, which is why you just did it both ways.

### Part 6: Get the course files

Your instructor will give you the address of the course repository. Download it with:

```
git clone <the address your instructor gave you> ~/devops-course/course
```

Every assignment in the course is now on your machine, in `~/devops-course/course`. Look around:

```
ls ~/devops-course/course
ls ~/devops-course/course/linux
```

Two folders to keep straight from now on. `~/devops-course/course` holds the course files, and you never edit anything in there. Your own work goes in folders like `~/devops-course/linux/01-terminal`.

## How you know you are done

Every assignment has a checker that you run yourself. It tells you what passed and what failed. It never tells you how to fix anything, because working that out is the assignment.

Run this one:

```
bash ~/devops-course/course/linux/01-terminal-basics/check.sh
```

That is the pattern every single time: `bash`, then the full path to the assignment's `check.sh`. It works from any folder, so you never have to be standing in the right place.

If you built your work somewhere other than where the assignment said, put that path on the end:

```
bash ~/devops-course/course/linux/01-terminal-basics/check.sh /some/other/folder
```

## Going further

- Run `man ls` and read the manual page. Press `q` to quit. Almost every command has one.
- Find out what `history` does, and what the up arrow key does.
- Learn tab completion now rather than later. Type `cd ~/devops-c` and press Tab. It is the single biggest speed difference between a beginner and everyone else.
