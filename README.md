# Git Tools
A small OS X utility tool for managing branches in Git repositories.

## Installation

Install using [homebrew](http://brew.sh):
```
brew install daveallie/tap/git-tools
```

Or you can just download the git-tools file, make it executable, and add it to your path or put it in the top of your repository (please note that this won't allow you to get updates and the homebrew method is recommended).

## Usage
```
> git-tools help
Git-Tools: A small utility tool for managing branches in Git repositories.
v1.2.0

Usage:
git-tools <tool> [options]

   Tool: Clean Branches
  Usage: git-tools clean [-n/--no-fetch] [-u/--user <user> | --me] [-m/--merge-branch <merge_branch>] [*ignore_branches]
Example: git-tools clean -u "John Smith" -m develop master staging
   Desc: Example above will identify branches merged into develop that aren't master or staging authored by 'John Smith'
         Default merge branch is master

   Tool: Old Branches
  Usage: git-tools old [-n/--no-fetch] [-u/--user <user> | --me] [-d/--days <num_days>]
Example: git-tools old -u "John Smith" -d 14
   Desc: Example above finds remote branches that haven't had a commit in 14 days authored by 'John Smith'
         Default is 7 days
```
