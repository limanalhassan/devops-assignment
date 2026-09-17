# 05. Packages and services

**Level:** intermediate
**Time:** about 3 hours
**Prerequisites:** `linux/01` to `linux/04`

## Warm up drill

No notes. Twelve minutes.

Make `drill/a/b` in one command, create files, copy, rename, delete by wildcard, and find them all. Write a script, fail to run it with `./`, fix it with `chmod`, and make another file `600`. Start `sleep 300` in the background, list it with `jobs`, find its PID with `pgrep`, and stop it with `kill`. Start `sleep 300` with `nohup` in the background and stop that one too. Delete `drill`.

## What you will learn

How software gets installed on a server, and how to run a program as a proper service that starts on boot, restarts when it crashes, and keeps its logs somewhere you can find them. This is the point where a Linux machine stops being a toy.

## Before you start

Check your Ubuntu is running systemd, which is the part of Linux that manages services:

```
systemctl is-system-running
```

`running` or `degraded` are both fine. `degraded` just means some unrelated service somewhere is unhappy.

**Windows only:** if it says `offline` or `System has not been booted with systemd`, run `sudo nano /etc/wsl.conf` and make the file contain exactly this:

```
[boot]
systemd=true
```

Save, close every Ubuntu window, open PowerShell and run `wsl --shutdown`, then open Ubuntu again and repeat the check.

Then:

```
bash ~/devops-course/course/linux/05-packages-and-services/setup.sh
```

That puts `pinger.py`, a small web service, in `~/devops-course/linux/05-services`.

## Background

**Packages.** On Ubuntu, software is installed as packages with `apt`. `sudo apt update` refreshes the list of what is available, and it does not install anything. `sudo apt install nginx` installs nginx and everything it depends on. `sudo apt remove nginx` removes it. `apt search word` and `apt show package` help you find things. Never download random installers from websites onto a server when a package exists.

**Services.** A service is a program that runs in the background all the time, usually with no terminal, like a web server or a database. On Ubuntu they are managed by **systemd**, and you talk to systemd with `systemctl`:

| Command | What it does |
| --- | --- |
| `systemctl status nginx` | is it running, since when, and its last few log lines |
| `sudo systemctl start nginx` | start it now |
| `sudo systemctl stop nginx` | stop it now |
| `sudo systemctl restart nginx` | stop then start |
| `sudo systemctl enable nginx` | start it automatically on boot |
| `sudo systemctl disable nginx` | do not start it on boot |

Start and enable are separate things and people mix them up constantly. `start` is about now. `enable` is about the next boot. A service can be running but not enabled, which means it disappears the next time the machine restarts, usually at the worst possible moment. `sudo systemctl enable --now` does both at once.

**Unit files.** systemd learns about a service from a unit file, a short text file in `/etc/systemd/system/` ending in `.service`. A minimal one looks like this:

```
[Unit]
Description=What this is

[Service]
ExecStart=/full/path/to/program
User=who-it-runs-as
Restart=always

[Install]
WantedBy=multi-user.target
```

`ExecStart` must use full paths. `Restart=always` is what brings the service back after a crash. `WantedBy=multi-user.target` is what `enable` hooks into to start it on boot. Every time you create or edit a unit file, run `sudo systemctl daemon-reload` so systemd reads it again.

**Logs.** Anything a service prints ends up in the journal. `journalctl -u nginx` shows that service's logs, `-n 50` shows the last 50 lines, and `-f` follows new lines as they arrive. When a service will not start, the reason is almost always in there.

## The task

### Part 1: Install a package

1. Refresh the package list, then install `nginx`, a web server.
2. Run `systemctl status nginx`. Read all of it: is it active, is it enabled, what is its PID, what are the last log lines.
3. Run `curl -s localhost | head -n 5`. That is nginx answering on port 80.
4. Stop nginx and run the `curl` again. Read the error. Start it again.
5. Disable nginx and run `systemctl is-enabled nginx`. Enable it again. Finish with nginx both running and enabled.
6. Run `dpkg -L nginx | head -n 20` to see where the package put its files.
7. Install `tree` and run `tree ~/devops-course/linux` to see the work you have done so far.

### Part 2: Run a service by hand, and feel why that is not enough

8. Go to `~/devops-course/linux/05-services` and run `python3 pinger.py`. It prints a line and keeps the terminal.
9. In a second terminal, run `curl localhost:8085`. You get a reply, and the first terminal logs the request.
10. Now run `curl localhost:8085/crash`. The service dies. Run `curl localhost:8085` again.

    It is gone, and it stays gone until a person notices and starts it again. It would also be gone after a reboot, and its logs vanish the moment that terminal closes. That is the problem services solve.

### Part 3: Make it a real service

11. Create `/etc/systemd/system/pinger.service` with `sudo nano`. It must:
    - run `pinger.py` with `/usr/bin/python3`, using the full path to `pinger.py`
    - run as your own user, not root
    - restart automatically whenever it stops
    - be startable on boot

    Your username is what `whoami` prints. Your full home path is what `echo $HOME` prints.

12. Tell systemd to reread its unit files, then enable and start `pinger` in one command.
13. Run `systemctl status pinger` and `curl localhost:8085`.
14. Crash it with `curl localhost:8085/crash`. Wait three seconds and `curl localhost:8085` again. It is back.
15. Run `journalctl -u pinger -n 20` and find the crash, the exit, and systemd starting it again.
16. Run `systemctl show pinger -p NRestarts` to see how many times systemd has had to bring it back.

### Part 4: Prove it survives a reboot

17. Restart your Ubuntu machine:
    - Mac: `sudo reboot`, wait thirty seconds, then `multipass shell devops`
    - Windows: close Ubuntu, run `wsl --shutdown` in PowerShell, open Ubuntu again
    - Linux: `sudo reboot`
18. Without starting anything yourself, run `curl localhost:8085` and `curl -s localhost | head -n 3`. Both should answer. Crash `pinger` once more so the checker can see it restarted, then run the checker.

### Questions

Put `ANSWERS.md` in `~/devops-course/linux/05-services`:

1. What is the difference between `systemctl start` and `systemctl enable`? Describe a real failure caused by doing one without the other.
2. Why should `pinger` run as your user instead of root?
3. You edited a unit file, restarted the service, and nothing changed. What did you forget?
4. A service will not start and `systemctl status` only says `failed`. What do you run next, and what are you looking for?
5. `Restart=always` brings a crashed service back. When could that make a problem worse instead of better?

## How you know you are done

```
bash ~/devops-course/course/linux/05-packages-and-services/check.sh
```

## Going further

- Add `RestartSec=5` to the unit, crash it, and time how long it takes to come back.
- Look at the unit file for a real service with `systemctl cat ssh`.
- Find out what `systemctl list-units --failed` shows you, and run it.
- Make `pinger` crash five times in a row quickly and find out what `StartLimitBurst` does.
