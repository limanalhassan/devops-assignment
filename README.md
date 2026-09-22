# DevOps course

Hands on assignments that take you from never having opened a terminal to doing the day to day work of a DevOps engineer.

You do the work, not read about it. Every assignment gives you a goal and a way to check your own answer, and you will get stuck on purpose sometimes. Getting unstuck is most of the job.

## Where to start

Open **[linux/01-terminal-basics](linux/01-terminal-basics/)** and follow it, right here on GitHub. It walks you through getting a Linux machine on whatever computer you have, and then through downloading this course onto it.

Do not skip ahead, even if you have read about some of this before. Every assignment assumes everything that came before it and nothing more.

## The order

| Order | Phase | What it covers | Status |
| --- | --- | --- | --- |
| 1 | [Linux](linux/) | the terminal, files, permissions, processes, services, text processing, scripting, SSH, networking, and fixing a broken machine | ready |
| 2 | [Git](git/) | version control from your first commit to recovering a damaged repository, and working in a team through pull requests | ready |
| 3 | Deploying by hand | running a real application on a server with nothing but the shell | coming |
| 4 | Docker | containers and Compose | coming |
| 5 | Cloud | AWS, Terraform and Ansible | coming |
| 6 | Pipelines | Jenkins | coming |
| 7 | Kubernetes | Kubernetes and Helm | coming |
| 8 | Operating it | automation, monitoring and incidents | coming |

## How every assignment works

Each one is a folder with a `README.md` telling you what to do. Most have a `setup.sh` you run first, and all of them have a `check.sh` you run when you think you are finished. You run both the same way, with the word `bash` and the full path:

```
bash ~/devops-course/course/linux/02-files-and-directories/check.sh
```

The checker tells you what passed and what failed. It never tells you how to fix anything, because working that out is the assignment.

## Where your work goes

Your work never goes inside the course files. `setup.sh` builds each exercise in its own folder under `~/devops-course/`, next to the course rather than inside it, so the course stays exactly as you downloaded it.

If you would rather work somewhere else, give `setup.sh` a folder and give `check.sh` the same one:

```
bash ~/devops-course/course/linux/02-files-and-directories/setup.sh ~/practice/files
bash ~/devops-course/course/linux/02-files-and-directories/check.sh ~/practice/files
```

`setup.sh` refuses to build anything inside the course folder, so you cannot mix your answers into it by accident.

Everything happens inside Ubuntu, even if your computer runs Windows or macOS. The first assignment sets that up.
