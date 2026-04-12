---
layout: post
title:  "Git Patch: Transferring commits or changes easily"
date:   2025-04-30 20:00:00 +0300
categories: general
excerpt: ""
---
git patch is a super easy way to move either commits or local changes between repositories or branches. It can be used in two primary ways:
* Transferring commits
* Transferring changes as uncommitted modifications

## Transferring commits
#### Creating patch of a specific commit

```bash
git format-patch -1 <commit-hash>
```

#### Applying a patch file
Place the patch file in the root directory of the target repo, then apply it

```bash
git am yourFileName.patch
```

Whitespace warnings are [not important](https://www.kernel.org/pub/software/scm/git/docs/git-apply.html#:~:text=When%20applying%20a%20patch%2C%20detect,messages%20but%20applies%20the%20patch.).

#### Creating patch for last n commit
```bash
git format-patch -n --stdout > yourFileName.patch
```
[stdout option](https://git-scm.com/docs/git-format-patch#Documentation/git-format-patch.txt---stdout) writes all commits into a single patch file.

If stdout is not used, each commit will be saved in a separate patch file.
```bash
git format-patch -n
```

We can apply all patch files in the root folder
```bash
git am *.patch
```
This will take all the commits into the current branch.


#### Creating patch for a range of commits
```bash
git format-patch excludedPreviousCommitHash..includedLaterCommitHash --stdout > yourFileName.patch
```
The left commit is not included in the patch. The right (included) commit is the latest in the range.

#### Creating patch for commits between branches
```bash
git format-patch develop..feature/test --stdout > yourFileName.patch
```

## Transferring changes
We can move local changes instead of commits.

#### Creating patch for current local changes (staged ones)
```bash
git diff --cached > yourFileName.patch
```

#### Creating patch for current all local changes
```bash
git diff > yourFileName.patch
```
#### To apply changes
```bash
git apply yourFileName.patch
```

When using git diff, no dots (..) are used between branches or commits. and we don’t need stdout.

```bash
git diff excludedPreviousCommitHash includedLaterCommitHash > yourFileName.patch
```
