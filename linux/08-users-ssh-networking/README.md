# 08. Users, SSH and networking

**Level:** intermediate
**Time:** about 3 hours
**Prerequisites:** `linux/01` to `linux/07`

## Warm up drill

No notes. Fifteen minutes.

Files: `drill/a/b`, copy, rename, wildcard delete, `find`. Permissions: fix a script with `chmod`, make a file `600`. Processes: background `sleep 300`, find it, kill it. Services: restart nginx and read its last log lines. Text: `seq 1 1000 > n.txt`, count lines containing `7`, top ten with `sort`. Scripting: write `count.sh` that takes a file name, prints usage to standard error and exits `2` without one, and otherwise prints how many lines the file has. Test both cases and check `$?`. Delete `drill`.

## What you will learn

How Linux keeps track of users, how to log into a machine with a key instead of a password, why SSH refuses keys when permissions are wrong, and how to find out what is listening on a machine and whether you can reach it.

## Before you start

You need nginx and the pinger service from `linux/05` still installed and running.

```
bash ~/devops-course/course/linux/08-users-ssh-networking/setup.sh
```

That starts a service somewhere on this machine. Finding it is part of the task.

## Background

**Users.** Every user has a line in `/etc/passwd`, which holds their name, their number (the UID), their home folder and their shell. Passwords are not in there. They live, scrambled, in `/etc/shadow`, which only root can read. Services usually run as their own user, so that a compromised web server cannot read everyone else's files.

`adduser` is the friendly Ubuntu command for creating a user. `useradd` is the lower level one found on every Linux system. `sudo -u deploy command` runs one command as `deploy`.

**SSH keys.** SSH lets you log into another machine. A key pair is two files. The **private key**, `~/.ssh/id_ed25519`, never leaves your machine and nobody ever sees it. The **public key**, `~/.ssh/id_ed25519.pub`, is safe to give to anyone. To let yourself log in as someone, you put your public key in that account's `~/.ssh/authorized_keys` file. When you connect, SSH proves you hold the matching private key without ever sending it.

Almost every server you will work on turns password logins off entirely. Keys are how you get in.

**SSH is fussy about permissions, on purpose.** If other people could write to someone's `~/.ssh` folder or `authorized_keys` file, they could add their own key and log in as that person. So the SSH server simply refuses keys when those permissions are too open, and it gives the person connecting no explanation at all. The reason only appears in the server's logs. `~/.ssh` must be `700` and `authorized_keys` must be `600`, and both must belong to that user.

**Ports.** One machine runs many network services, and each one listens on a numbered port. Some you will see everywhere: 22 is SSH, 80 is HTTP, 443 is HTTPS, 5432 is Postgres. `127.0.0.1`, also called `localhost`, means "this machine only", so a service listening there cannot be reached from anywhere else. `0.0.0.0` means every network the machine is on.

**Seeing the network:**

| Command | What it shows |
| --- | --- |
| `ip -brief address` | this machine's IP addresses |
| `ss -tlnp` | every TCP port something is listening on. Run it with `sudo` to see which program |
| `curl -v http://host:port/` | makes a request and shows the whole conversation |
| `curl -s -o /dev/null -w '%{http_code}\n' URL` | just the HTTP status code |
| `getent hosts github.com` | which IP address a name resolves to |

## The task

Work in `~/devops-course/linux/08-network` for anything you write.

### Part 1: Users

1. Create a user called `deploy` with a home folder, a bash shell, and no password, so it can only ever log in with a key. Look up the `adduser` options you need.
2. Find `deploy`'s line in `/etc/passwd` and work out what every field means.
3. Run `id deploy`, then `sudo -u deploy whoami`.
4. Run `ls -ld /home/deploy` and explain in your answers why you cannot see inside it.

### Part 2: Your SSH key

5. Install the SSH server package, `openssh-server`, and check its status with `systemctl`.
6. If `~/.ssh/id_ed25519` does not exist yet, create a key pair with `ssh-keygen -t ed25519 -C "your email address"`. Accept the default location. For this course, press Enter for no passphrase. In real life you would set one, and your answers should say why.
7. Look at both files with `ls -l ~/.ssh`. Compare their permissions and understand why they differ. Print the public key with `cat`. Never `cat` the private key anywhere someone could see it.

### Part 3: Let yourself in as deploy

8. Put your public key into `/home/deploy/.ssh/authorized_keys`. The `.ssh` folder and the file must belong to `deploy`, the folder must be `700`, and the file `600`. You will need `sudo`, and you will need to think about who ends up owning what you create.
9. Run `ssh deploy@localhost whoami`. The first time, it asks whether you trust the machine. Type `yes`. It should print `deploy` without asking for a password.

### Part 4: Break it and find out why

10. Run `sudo chmod 777 /home/deploy/.ssh`, then `ssh deploy@localhost whoami` again. It fails, and the error tells you almost nothing.
11. Find the real reason in the SSH server's logs with `sudo journalctl -u ssh -n 30`. Copy the relevant line into your answers.
12. Put the permissions back and confirm `ssh deploy@localhost whoami` works again.

### Part 5: What is listening here?

13. Find this machine's IP address.
14. List every listening TCP port and the program behind each one. You should recognise SSH on 22, nginx on 80 and pinger on 8085. You will probably also see port 53 on `127.0.0.53` and `127.0.0.54`, run by `systemd-resolve`. That is Ubuntu's own DNS helper, which looks up names like `github.com`, and it is always there.
15. One more port is listening that nobody told you about. Find out which port it is, which address it is bound to, and which systemd service runs it. The PID in `ss` output plus `systemctl status <PID>` will tell you the service.
16. You cannot read that service's files directly, try it and see. But it will answer network requests. Use `curl` to find what it serves and get the token out of it.
17. Explain in your answers why nobody could reach that service from another machine, even if they knew the port.

### Part 6: The outside world

18. Find which IP address `github.com` resolves to.
19. Get just the HTTP status code for `https://github.com` and for `https://github.com/this-page-does-not-exist-at-all`.

### Questions

Put `ANSWERS.md` in `~/devops-course/linux/08-network`. It must include the mystery service's port, its systemd service name and the token from step 16, plus:

1. What is the difference between the private and the public key, and what happens if someone gets hold of each one?
2. Why does SSH refuse your key when `~/.ssh` is `777`? What attack does that prevent?
3. Why would you normally protect a private key with a passphrase?
4. What is the difference between a service listening on `127.0.0.1` and one listening on `0.0.0.0`?
5. `curl` to a server hangs for thirty seconds, and on another occasion fails instantly with `Connection refused`. What does each tell you about where the problem is?

## How you know you are done

```
bash ~/devops-course/course/linux/08-users-ssh-networking/check.sh
```

The checker logs in as `deploy` over SSH itself, with passwords switched off, so a key that only works because you typed a password will not pass.

## Going further

- Create `~/.ssh/config` with a `Host` entry so that `ssh deploy-local` does the same as `ssh deploy@localhost`.
- Give `deploy` permission to restart pinger with `sudo` and nothing else, using a file in `/etc/sudoers.d`. Use `visudo -f` so a typo cannot lock you out.
- On a Mac, run `multipass info devops` from the Mac's own terminal and SSH into the VM from your Mac using its IP address.
