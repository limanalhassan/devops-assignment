# 04. Processes and signals

**Level:** beginner
**Time:** about 2 hours
**Prerequisites:** `linux/01` to `linux/03`

## Warm up drill

No notes. Ten minutes.

Make a folder `drill` with `a/b` inside it in one command. Create two files, copy one into `a/b`, rename the other, delete a `.tmp` file with a wildcard, and find every file under `drill` with `find`. Make a script that prints a line, try to run it with `./`, read the error, and fix it with `chmod`. Make a second file readable and writable by you only and check its number with `stat -c '%a'`. Delete `drill`.

## What you will learn

What a running program looks like to Linux, how to find one, watch it, pause it and stop it, and why some programs die when you close the terminal and others do not.

## Before you start

```
bash ~/devops-course/course/linux/04-processes/setup.sh
```

That puts three badly behaved scripts in `~/devops-course/linux/04-processes`.

**You need two terminals open at once for this assignment.** How to open a second one:

- Mac: in the Terminal app press Command and T for a new tab, then run `multipass shell devops` in it
- Windows: open Ubuntu again from the Start menu
- Linux: open a new terminal tab or window

## Background

**A process is a running program.** Every process has a number, its PID, and a parent, the process that started it. When you type a command, your shell is the parent.

**Seeing processes.** `ps aux` lists every process on the machine. `ps aux | grep something` filters that list. The `|` is a pipe, which sends the output of one command into the next. `pgrep -f name` prints just the PIDs of anything whose command line contains `name`. `top` shows a live view sorted by CPU use. Press `q` to leave it.

**Signals.** You stop a process by sending it a signal. The ones you need:

| Signal | Number | Meaning |
| --- | --- | --- |
| SIGHUP | 1 | your terminal went away |
| SIGINT | 2 | what Ctrl and C sends |
| SIGKILL | 9 | die now, cannot be caught or ignored |
| SIGTERM | 15 | please shut down, the default for `kill` |

`kill 1234` sends SIGTERM to process 1234. `kill -9 1234` sends SIGKILL. A well written program catches SIGTERM, finishes what it was doing and exits cleanly. SIGKILL gives it no chance, so half written files stay half written. Always try SIGTERM first.

**Foreground and background.** A normal command runs in the foreground and you get your prompt back when it finishes. Put `&` on the end and it runs in the background, so you get your prompt back immediately. `jobs` lists what this terminal has in the background. Ctrl and Z pauses the foreground job, `bg` resumes it in the background, and `fg` brings a job back to the foreground.

**Closing the terminal.** When a terminal closes, Linux sends SIGHUP to what was running in it, and most programs die. `nohup` starts a program with SIGHUP ignored, so it keeps going. Real services are not run this way, `linux/05` shows the proper way, but you will meet `nohup` on real servers constantly.

## The task

Work in `~/devops-course/linux/04-processes`.

### Part 1: Foreground and Ctrl and C

1. In terminal A, run `bash heartbeat.sh`. Nothing appears, and you do not get your prompt back.
2. In terminal B, go to the same folder and run `tail -f heartbeat.log`. Watch the lines arrive.
3. Back in terminal A, press Ctrl and C. Watch terminal B stop getting new lines. Press Ctrl and C in terminal B as well.

### Part 2: A process eating the CPU

4. In terminal A, run `bash cpu-burner.sh &`. Note the job number in square brackets and the PID it prints.
5. Run `jobs`. Then find the same process with `ps aux | grep cpu-burner` and again with `pgrep -f cpu-burner`.
6. Run `top`. Find `cpu-burner` near the top and look at its `%CPU`. Press `q` to leave.
7. Stop it with plain `kill` and its PID. Confirm with `pgrep -f cpu-burner` that it is gone, which means no output at all.

### Part 3: A process that will not stop

8. Run `bash stubborn.sh &` and note its PID.
9. Stop it with plain `kill`. Check whether it is still running. Look at `stubborn.out`.
10. Try `kill -INT` on it. Check again.
11. Use the signal that cannot be ignored. Confirm it is gone.

### Part 4: Pausing and resuming

12. Run `sleep 600` in the foreground. Press Ctrl and Z. Run `jobs` and read the state it shows.
13. Resume it in the background with `bg`, check `jobs` again, bring it back with `fg`, and stop it with Ctrl and C.

### Part 5: Surviving a closed terminal

14. In terminal A, start the heartbeat so that it survives the terminal closing:

    ```
    nohup bash heartbeat.sh > /dev/null 2>&1 &
    ```

    `> /dev/null 2>&1` throws its output away, otherwise `nohup` writes it to a file called `nohup.out`.

15. In terminal B, run `tail -f heartbeat.log` and check lines are arriving.
16. Close terminal A completely: close the window or tab, do not type `exit`.
17. In terminal B, lines are still arriving. Press Ctrl and C to stop `tail`. Find the heartbeat's PID, then run `ps -o pid,ppid,cmd -p <PID>` and look at its parent. Compare that with the parent it had when you started it, which was your shell in terminal A.
18. **Leave the heartbeat running** and run the checker. Stop it afterwards, because it will keep writing forever.

### Questions

Put `ANSWERS.md` in `~/devops-course/linux/04-processes`:

1. Why should you try SIGTERM before SIGKILL? What can go wrong with a database that gets SIGKILL in the middle of a write?
2. In step 11, what did you send, and why did it work when steps 9 and 10 did not?
3. In step 17, what happened to the heartbeat's parent after you closed terminal A, and why does Linux do that?
4. What is the difference between Ctrl and C and Ctrl and Z?
5. `cpu-burner` showed around 100% in `top`. On a machine with two CPUs, what does 100% mean, and how busy was the machine overall?

## How you know you are done

With the heartbeat still running:

```
bash ~/devops-course/course/linux/04-processes/check.sh
```

## Going further

- Run `ps -ef --forest` and find the path from process 1 down to your shell.
- `kill -STOP` and `kill -CONT` a running heartbeat and watch the log in the other terminal.
- Find out what a zombie process is and why `kill -9` cannot remove one.
