# Curriculum scope

## The idea holding it together

One application runs through the entire course. Mentees meet it in week two and they are still deploying it in the final module. Nothing is a throwaway exercise.

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

Order follows the tools board. Git comes first, which is the right call: it needs almost no Linux knowledge, and they cannot hand in a single later assignment until they know how to open a pull request.

### Phase 0. Git and GitHub (5 weeks, assignments 01 to 08)

This phase runs the whole way from "what is a commit" to things a working engineer does under pressure.

**Basics (01 to 03).** Repositories, the staging area, commit hygiene, gitignore. Branching, fast forward versus real merges. Conflicts, resolved twice, once with merge and once with rebase.

**Recovery (04).** Reading history with log, diff and blame. Undoing safely: revert, the three resets, amend, stash, and rescuing deleted work with reflog. This is the assignment that stops them being afraid of Git.

**The workflow (05).** Fork, remotes, push, pull request, responding to review, keeping a fork in sync. Everything after Phase 0 is submitted this way, so they practise it another fifty times without noticing.

**Rewriting history (06).** Interactive rebase, squash and fixup, reordering and dropping commits, cherry picking a single fix onto a release branch, tagging and semantic versioning.

**Team practice (07).** Reviewing someone else's pull request properly, trunk based development versus long lived branches, protected branches, CODEOWNERS, conventional commits, hooks that run checks before a commit is allowed.

**Under pressure (08).** The mid level assignment. Bisect a repository to find which of two hundred commits introduced a bug. Purge a leaked credential from published history and understand what that costs everyone else. Recover a repository someone has badly damaged, working only from reflog. Timed, with no notes.

Ends with: they can work in a shared repository without being nervous, and they can fix one when it goes wrong.

### Phase 1. Linux (3 weeks, 09 to 17)

Filesystem layout, permissions and ownership, users and groups, processes and signals, package managers, systemd units, journalctl, disks and mounts, ports and sockets, SSH keys.

Shell scripting lives here too: variables, conditionals, loops, exit codes, pipes and redirection, cron. Enough that they can write the small glue scripts every DevOps job actually consists of.

Ends with: they can log into a machine, work out why something is not running, and fix it.

### Phase 2. Run something for real (2 weeks, 18 to 22)

They get the notes API source and deploy it on a Linux VM with nothing but the shell. Install Python and Postgres, create a database user, wire up config, write a systemd unit so it survives a reboot, put Nginx in front as a reverse proxy, open the right port, add TLS with a self signed cert.

Then the important bit. Tell them to do the whole thing again on a second machine, timed. Then tell them the Python version differs on that machine.

Ends with: a service they built by hand, and a written list of every step it took.

### Phase 3. Containers (3 weeks, 23 to 29)

**Docker.** Images versus containers, writing a Dockerfile for the notes API, layer caching, why their image is 1.2GB and how to get it to 200MB, multi stage builds, running as a non root user, environment variables and secrets, volumes and why their data disappeared.

**Compose.** App and Postgres together, networks, depends_on and why it does not do what they think, local development that matches production.

Ends with: `docker compose up` gives them in nine seconds what took them two hours in Phase 2.

### Phase 4. Cloud (4 weeks, 30 to 44)

**AWS by hand (30 to 34).** IAM users, roles and policies. A VPC with public and private subnets, route tables, an internet gateway, security groups. EC2. S3. RDS. They click every bit of it in the console and write down the steps.

**Terraform (35 to 39).** Rebuild exactly what they clicked, in code. Providers, resources, variables, outputs, state and why state is dangerous, remote state in S3, modules, plan versus apply, destroy. One assignment where I hand them broken state and they recover it.

**Ansible (40 to 44).** Terraform made ten empty machines. Now configure them. Inventories, playbooks, roles, idempotency, handlers, variables and vaults, dynamic inventory from AWS tags.

Ends with: one command creates infrastructure, another configures it, and they can tear it all down.

### Phase 5. Pipelines (3 weeks, 45 to 49)

**Jenkins.** Run Jenkins itself in Docker. A freestyle job first so they feel how tedious it is, then Jenkinsfiles. Build, run tests, build the image, push to a registry, deploy. Credentials handling, agents, parallel stages, failing a build properly, notifications.

Include one assignment where the pipeline is green but the deploy is broken, and they have to work out why.

Ends with: a push to main puts new code on a server without anyone touching a terminal.

### Phase 6. Orchestration (4 weeks, 50 to 56)

**Kubernetes.** Start on kind locally so nobody pays for a control plane while they are still confused. Pods, deployments, replicasets, services, ingress, configmaps and secrets, resource requests and limits, liveness and readiness probes, persistent volumes for Postgres, namespaces, RBAC.

Then rolling updates and rollbacks. Then Helm, by converting their own manifests into a chart.

Optionally finish on EKS if there is budget. It is not needed to understand the concepts.

Ends with: the notes API running with three replicas, surviving a pod being killed, and updating with no downtime.

### Phase 7. Keeping it alive (3 weeks, 57 to 65)

**Python automation (57 to 60).** The jobs from the board. A script that backs up Postgres to S3 and can restore it. A script that scans TLS certificates and reports which expire within thirty days. A script that finds untagged or idle AWS resources. Argument parsing, error handling, logging, boto3, scheduling with cron and with a Kubernetes CronJob.

**Observability and incidents (61 to 65).** Prometheus scraping the app, Grafana dashboards, alert rules, centralised logs, structured logging.

Then the final assignments, which are the best ones. I break something and hand it over. Certificate expired. Disk full. Memory leak. Database connection pool exhausted. A bad deploy that needs rolling back at 2am. No hints, just symptoms, and they write an incident report at the end.

Ends with: they can be handed a system they did not build and work out what is wrong with it.

## What that adds up to

Around 65 assignments across roughly six months of part time study. That is the full path. It is fine to run a subset, and it is fine for a mentee to stop after Phase 5 and already be employable at junior level.

## Submission flow

Each mentee forks the repo, creates a branch named `<their-name>/<assignment-number>`, does the work, and opens a pull request against my repo. I review in the PR.

This gives me three things. They practice the Git workflow every single week, I can see their history rather than just their answer, and code review becomes normal to them early.

## Checking their own work

Every assignment folder gets a `check.sh` they run themselves. It should be blunt about what passed and what failed, and it should never explain how to fix anything.

The rule is that a mentee should never have to ask me whether they finished. They should only have to ask me why something behaves the way it does.

## Open decisions

**AWS spend.** Phases 4 and 6 need real accounts. Free tier covers most of it if they are disciplined about teardown, but NAT gateways, RDS and EKS are not free. Options are to keep everything inside free tier with hard teardown steps, use LocalStack for the Terraform work and only touch real AWS a few times, or fund a shared sandbox account with a budget alarm. Worth deciding before Phase 4 is written.

**Jenkins versus GitHub Actions.** The board says Jenkins and plenty of jobs still ask for it, so Phase 5 teaches Jenkins. Adding one GitHub Actions assignment alongside it is cheap and covers what most of them will actually meet first.
