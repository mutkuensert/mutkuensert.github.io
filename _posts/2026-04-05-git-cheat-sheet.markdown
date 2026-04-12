---
layout: post
title:  "Git cheat sheet"
date:   2026-04-05 16:00:00 +0300
categories: general
excerpt: ""
---

## Add
Add single file

`git add <filename.type>`

</br>

Add all

`git add .`

`git add --all`

`git add -A`

</br>

Add only tracked ones

`git add -u`

`git add --update`

</br>

Unstage a file

`git restore --staged <file_path>`

</br>

Unstage all files

`git restore --staged .`

## Amend
Overwrite last commit with new commit message

`git commit --amend -m "new commit message"`

</br>

Overwrite last commit without changing commit message

`git commit --amend --no-edit`

</br>

Overwrite last commit opening the commit message editor

`git commit --amend`

## Branch
Create new branch

`git branch <new_branch>`

</br>

Show branches (* indicates active branch)

`git branch`

</br>

Show remote branches

`git branch -r`

</br>

Switch to branch

`git checkout <branch_name>`

or

`git switch <branch_name>`

</br>

Create and checkout to new branch

`git checkout -b <branch_name>`

</br>

Delete a branch

`git branch -d <branch_name>`

## Checkout
Checkout to a commit

`git checkout <commit_hash>`

## Commit
`git commit -m "commit message"`

</br>

To commit with auto stage

`git commit -a -m "commit message"`

## Config
Set user name and email

`git config --global user.name "name surname"`

`git config --global user.email "mail@mail.com"`

</br>

See user name and email

`git config user.name`

`git config user.email`

## Fetch
`git fetch`

</br>

Remove remote branches in local that don’t exist in remote any more

`git fetch --prune`

## Diff
Difference between changes and last commit

`git diff`

</br>

Diff between changes in working tree and HEAD

`git diff HEAD`

</br>

Diff between branches

`git diff <branch_1> <branch_2>`

</br>

Diff between two commits

`git diff <hashcode> <hashcode>`

</br>

Diff one file since a commit

`git diff <commit> <file>`

</br>

Diff of a file with current changes

`git diff <file>`

</br>

Show a summary of a diff

`git diff <commit> --stat`

`git show <commit> --stat`

## Help
`git any_command -help`

`git help --all`

## Log
`git log`

`git log --oneline`

## Merge
`git merge <other_branch_name>`

## MV
Rename

`git mv <old_file_name> <new_file_name>`

</br>

Move to folder

`git mv file.txt src/`

</br>

Move and rename

`git mv assets/image.png images/logo.png`

</br>

Move directory

`git mv old-dir/ new-location/`

## Push
`git push`

</br>

Create branch on remote and push

`git push -u origin <branch_name>`

</br>

Force push

`git push -f`

## Rebase
`git rebase <branch_name>`

## Remote (connect local repository to remote)
`git remote add origin <repository_url>`

## Reset
Remove the commits above this commit in current branch and keep changes staged

`git reset --soft <commit>`

or last commit

`git reset --soft HEAD~1`

</br>

Remove the commits above this commit in current branch and keep changes unstaged

`git reset --mixed <commit>`

`git reset <commit>`

</br>

Remove the commits above this commit in current branch and changes

`git reset --hard <commit>`

## Restore
Remove changes on the file

`git restore filename`

## Status
`git status`

`git status --short`

</br>

Show with untracked (-u=--untracked-files)

`git status -u`