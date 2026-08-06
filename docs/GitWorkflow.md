## Git Workflow Stages

### 1. Working Files

**Meaning:** Files you are currently creating or editing on your computer. Git can see the changes, but they have not been prepared for a commit.

**Check them with:**

```bash
git status
```

**What it does:** Shows your current branch and identifies changed, new, staged, and untracked files.

For a shorter view:

```bash
git status --short
```

Common status codes:

- `??` — new file that Git is not tracking yet
- `M` — modified file
- `A` — file added to the staging area
- `D` — deleted file

---

### 2. Staging Area

**Meaning:** A preparation area where you select exactly which changes should be included in the next commit.

**Move a file into staging with:**

```bash
git add path/to/file
```

**What it does:** Adds the file’s current changes to the staging area. It does not create a commit or upload anything to GitHub.

Example:

```bash
git add database/migrations/003_jobs.sql
```

To stage several specific files:

```bash
git add file1 file2 file3
```

**Review staged changes with:**

```bash
git diff --cached
```

**What it does:** Displays the exact changes currently prepared for the next commit.

**Check staged files for formatting problems with:**

```bash
git diff --cached --check
```

**What it does:** Looks for whitespace and formatting errors. No output usually means no problems were found.

---

### 3. Local Commit

**Meaning:** A permanent, named snapshot of the staged changes in your local Git history.

**Create it with:**

```bash
git commit -m "description of the change"
```

**What it does:** Saves the staged changes as a commit on your current branch. It does not upload the commit to GitHub.

Example:

```bash
git commit -m "feat: add jobs database schema"
```

Useful commit prefixes:

- `feat:` — adds a feature
- `fix:` — fixes a problem
- `docs:` — changes documentation
- `test:` — adds or changes tests
- `chore:` — changes setup, configuration, or maintenance files
- `refactor:` — reorganizes code without changing its intended behavior

---

### 4. Remote Branch

**Meaning:** The copy of your branch stored on GitHub. A branch exists locally first; pushing publishes it to the remote repository.

**Upload a new branch with:**

```bash
git push -u origin branch-name
```

**What it does:**

- `git push` — uploads commits
- `-u` — connects the local branch to its GitHub counterpart
- `origin` — the conventional name for your GitHub repository
- `branch-name` — the branch being uploaded

Example:

```bash
git push -u origin feature/initial-database-schema
```

After the first push, future updates usually require only:

```bash
git push
```

---

### 5. Pull Request

**Meaning:** A request to review and merge the changes from your feature branch into `main`.

**Open the Pull Request page with:**

```bash
gh pr create --web
```

**What it does:** Opens GitHub in your browser with a Pull Request form for the current branch. It does not merge anything automatically.

The Pull Request lets you:

- Review changed files
- Explain what was added
- Confirm acceptance criteria
- Detect merge conflicts
- Connect the work to a GitHub Issue
- Merge the approved changes into `main`

---

### 6. Merge

**Meaning:** GitHub combines the approved feature-branch changes into the `main` branch.

This is normally completed using the **Merge pull request** button on GitHub.

After merging:

- The changes become part of the official `main` branch on GitHub.
- The local copy of `main` is not updated automatically.
- The feature branch may be deleted after it is no longer needed.

---

### 7. Synchronize Local `main`

**Meaning:** Update the `main` branch on your Mac so it matches the newly merged version on GitHub.

First, switch to `main`:

```bash
git switch main
```

**What it does:** Changes your active local branch to `main`.

Then download the merged changes:

```bash
git pull --ff-only
```

**What it does:**

- `git pull` — downloads changes from GitHub and updates your local branch
- `--ff-only` — allows only a clean forward update and stops if Git would need to create an unexpected merge commit

Finally, verify the result:

```bash
git status
```

The expected result is:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

## Complete Flow

```text
Working Files
    ↓ git add
Staging Area
    ↓ git commit
Local Commit
    ↓ git push
Remote Branch on GitHub
    ↓ Pull Request
Review
    ↓ Merge
GitHub main
    ↓ git switch main + git pull --ff-only
Local main
```

In plain language:

1. Edit and save files.
2. Inspect what changed.
3. Stage the files you want to include.
4. Review the staged changes.
5. Create a local commit.
6. Push the branch to GitHub.
7. Open and review a Pull Request.
8. Merge it into `main`.
9. update your local `main`.
10. Confirm everything is clean.