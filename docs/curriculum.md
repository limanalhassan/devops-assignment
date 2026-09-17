# Curriculum scope

## The idea holding it together

One application runs through the entire course. Mentees meet it in Phase 3, once they can use Linux and Git, and they are still deploying it in the final module. Nothing is a throwaway exercise.

The app is a small notes API. Python and Flask for the service, Postgres for storage. It is deliberately boring and deliberately stateful, because the database is what makes backups, volumes, migrations and Kubernetes storage into real problems instead of hypothetical ones.

The journey the app takes:

1. They run it by hand on a Linux machine and it breaks
2. They put it in a container and it stops breaking
3. A pipeline builds the container for them
4. Terraform creates the infrastructure it runs on
5. Ansible configures that infrastructure
6. Kubernetes runs many copies of it
7. Python scripts and dashboards keep it alive

By the end they have deployed the same piece of software seven different ways and they understand why each way exists.

## The teaching pattern

Every module follows the same shape, taken from the tools board:

**Do it manually first.** Before Terraform, they click through the AWS console for an hour and write down every step. Before Docker, they install Python and Postgres on a bare VM and hit a dependency conflict. Before Jenkins, they build and push an image by hand eleven times.

**Then feel the pain.** Ask them to do the manual thing again, but for three environments. Or on a fresh machine. Or after someone else changed a version.

**Then introduce the tool** as the answer to a problem they already have.

**And repeat the basics constantly.** Every assignment after the first in a phase opens with a warm up drill: redo the core actions of every previous assignment in that phase, from memory, no notes, against a clock. It takes them ten minutes and it is the difference between someone who has read about branching and someone who branches without thinking about it.

A mentee who has never suffered without a tool will never understand the tool. Skipping the manual step is the fastest way to produce someone who can copy a Dockerfile but cannot debug one.

## Phases

Rough sizing assumes a mentee putting in six to eight hours a week. Adjust freely.

Linux comes first, then Git. The original plan put Git first because it needs little Linux and unlocks the pull request workflow. That was reversed once it was clear the mentees had never opened a terminal, and that the Git team practice assignment asks them to write shell hooks. Teaching Git to someone who cannot confidently edit a file or run a script means teaching two things at once and neither well.

The cost of the reversal is that nothing gets submitted until `git/05`. They hand in the whole Linux phase in that same pull request.

**Everyone works in Ubuntu 24.04.** Windows through WSL, macOS through a Multipass VM, Linux natively. macOS has no `apt`, `systemd`, `useradd` or `/proc`, so without this the Linux phase breaks silently for Mac users, and every checker would need two code paths.

Assignment numbers restart at 01 in each phase folder, so `linux/03` and `git/03` are different assignments.

### Phase 1. Linux (4 weeks, `linux/01` to `linux/09`)

Assumes nothing at all, and runs to mid level.

**The terminal (01).** Getting Ubuntu on any machine, paths, moving around, nano, running a script, cloning the course.

**The basics.** Files, wildcards, `find`, reading big files, links. Permissions in both notations, ownership, groups and setgid, and the `usermod -G` trap that removes you from `sudo`. Processes, signals, job control, and `nohup`.

**Running software properly (05).** `apt`, then a service run by hand and crashed on purpose, then the same service under a systemd unit that brings it back. Verified across a real reboot.

**Working with text and code (06 and 07).** Pipelines over a 48,000 line log, answered with commands, not by eye. Then shell scripting to a precise spec, with checkers that run the scripts against edge cases: comments hiding bad values, commands that only succeed on the third try, and paths with spaces that catch unquoted `$@`. `git/07` depends on this.

**Users and the network (08).** Key based SSH into another account, breaking it with bad permissions and finding the reason in the server log, and tracking down an undocumented service on a random port through `ss` and `systemctl`.

**A broken machine (09).** No new commands. A support ticket with symptoms only, and three unrelated faults: a service that cannot read its config, a cron job that resurrects a CPU hog, and disk space held by a deleted file that `du` cannot see. The checker rejects lazy fixes, like running the service as root or making the secret world readable, and they write an incident report.

Ends with: they can log into a machine, work out why something is not working, fix the cause rather than the symptom, and explain what happened.

### Phase 2. Git and GitHub (5 weeks, `git/01` to `git/08`)

This phase runs from "what is a commit" to things a working engineer does under pressure.

**Basics.** Repositories, the staging area, commit hygiene, gitignore, and setting nano as Git's editor so nobody gets trapped in vim. Branching, fast forward versus real merges. Conflicts, resolved twice, once with merge and once with rebase.

**Recovery (04).** Reading history with log, diff and blame. Undoing safely: revert, the three resets, amend, stash, and rescuing deleted work with reflog. This is the assignment that stops them being afraid of Git.

**The workflow (05).** SSH key on GitHub, fork, remotes, push, pull request, responding to review, keeping a fork in sync. They submit the whole Linux phase in this pull request, and everything after is submitted the same way.

**Rewriting history (06).** Interactive rebase, squash and fixup, reordering and dropping commits, cherry picking a single fix onto a release branch, tagging and semantic versioning.

**Team practice (07).** Reviewing someone else's pull request properly, trunk based development versus long lived branches, protected branches, CODEOWNERS, conventional commits, and hooks they write themselves that the checker actually executes.

**Under pressure (08).** The mid level assignment. Bisect sixty commits to find which one introduced a bug. Purge a leaked credential from published history and understand what that costs everyone else. Recover a repository someone has badly damaged, working only from reflog. Timed.

Ends with: they can work in a shared repository without being nervous, and they can fix one when it goes wrong.

### Phase 3. Run something for real (2 weeks)

They get the notes API source and deploy it on a Linux VM with nothing but the shell. Install Python and Postgres, create a database user, wire up config, write a systemd unit so it survives a reboot, put Nginx in front as a reverse proxy, open the right port, add TLS with a self signed cert.

Then the important bit. Tell them to do the whole thing again on a second machine, timed. Then tell them the Python version differs on that machine.

Ends with: a service they built by hand, and a written list of every step it took.

### Phase 4. Containers (3 weeks)

**Docker.** Images versus containers, writing a Dockerfile for the notes API, layer caching, why their image is 1.2GB and how to get it to 200MB, multi stage builds, running as a non root user, environment variables and secrets, volumes and why their data disappeared.

**Compose.** App and Postgres together, networks, depends_on and why it does not do what they think, local development that matches production.

Ends with: `docker compose up` gives them in nine seconds what took them two hours in Phase 3.

### Phase 5. Cloud (4 weeks)

**AWS by hand.** IAM users, roles and policies. A VPC with public and private subnets, route tables, an internet gateway, security groups. EC2. S3. RDS. They click every bit of it in the console and write down the steps.

**Terraform.** Rebuild exactly what they clicked, in code. Providers, resources, variables, outputs, state and why state is dangerous, remote state in S3, modules, plan versus apply, destroy. One assignment where I hand them broken state and they recover it.

**Ansible.** Terraform made ten empty machines. Now configure them. Inventories, playbooks, roles, idempotency, handlers, variables and vaults, dynamic inventory from AWS tags.

Ends with: one command creates infrastructure, another configures it, and they can tear it all down.

### Phase 6. Pipelines (3 weeks)

**Jenkins.** Run Jenkins itself in Docker. A freestyle job first so they feel how tedious it is, then Jenkinsfiles. Build, run tests, build the image, push to a registry, deploy. Credentials handling, agents, parallel stages, failing a build properly, notifications.

Include one assignment where the pipeline is green but the deploy is broken, and they have to work out why.

Ends with: a push to main puts new code on a server without anyone touching a terminal.

### Phase 7. Orchestration (4 weeks)

**Kubernetes.** Start on kind locally so nobody pays for a control plane while they are still confused. Pods, deployments, replicasets, services, ingress, configmaps and secrets, resource requests and limits, liveness and readiness probes, persistent volumes for Postgres, namespaces, RBAC.

Then rolling updates and rollbacks. Then Helm, by converting their own manifests into a chart.

Optionally finish on EKS if there is budget. It is not needed to understand the concepts.

Ends with: the notes API running with three replicas, surviving a pod being killed, and updating with no downtime.

### Phase 8. Keeping it alive (3 weeks)

**Python automation.** The jobs from the board. A script that backs up Postgres to S3 and can restore it. A script that scans TLS certificates and reports which expire within thirty days. A script that finds untagged or idle AWS resources. Argument parsing, error handling, logging, boto3, scheduling with cron and with a Kubernetes CronJob.

**Observability and incidents.** Prometheus scraping the app, Grafana dashboards, alert rules, centralised logs, structured logging.

Then the final assignments, which are the best ones. I break something and hand it over. Certificate expired. Disk full. Memory leak. Database connection pool exhausted. A bad deploy that needs rolling back at 2am. No hints, just symptoms, and they write an incident report at the end.

Ends with: they can be handed a system they did not build and work out what is wrong with it.

## What that adds up to

Around 65 assignments across roughly seven months of part time study. That is the full path. It is fine to run a subset, and a mentee who stops after Phase 6 is already employable at junior level.

## Submission flow

From `git/05` onwards, each mentee forks the repo, creates a branch named `<their-name>/<phase>-<number>`, for example `ama/git-05` or `ama/docker-03`, does the work, and opens a pull request against my repo. I review in the PR. The Linux phase comes before they know how, so it is submitted all at once in the `git/05` pull request.

This gives me three things. They practice the Git workflow every single week, I can see their history rather than just their answer, and code review becomes normal to them early.

## Checking their own work

Every assignment folder gets a `check.sh` they run themselves, always as `bash <full path>`. It should be blunt about what passed and what failed, and it should never explain how to fix anything. It may explain how to operate the checker itself, for example what to do when it cannot find their folder.

Every checker is verified against a correct solution in a real Ubuntu 24.04 VM before the assignment is considered done, and where possible also against the common wrong answer, to prove it actually catches it.

The rule is that a mentee should never have to ask me whether they finished. They should only have to ask me why something behaves the way it does.

## Open decisions

**AWS spend.** Phases 5 and 7 need real accounts. Free tier covers most of it if they are disciplined about teardown, but NAT gateways, RDS and EKS are not free. Options are to keep everything inside free tier with hard teardown steps, use LocalStack for the Terraform work and only touch real AWS a few times, or fund a shared sandbox account with a budget alarm. Worth deciding before Phase 5 is written.

**Jenkins versus GitHub Actions.** The board says Jenkins and plenty of jobs still ask for it, so Phase 6 teaches Jenkins. Adding one GitHub Actions assignment alongside it is cheap and covers what most of them will actually meet first.
