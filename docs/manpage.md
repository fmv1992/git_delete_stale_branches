<!--

https://jeromebelleman.gitlab.io/posts/publishing/manpages/

*   How to see this in `docker`:

    ```
    bash -xv /usr/local/bin/docker_test
    man git_delete_stale_branches
    ```

-->

% git_delete_stale_branches(1)
% Felipe M. Vieira
% August 2023

# NAME

git_delete_stale_branches – Safely delete your version controlled branches.

# SYNOPSIS

**git_delete_stale_branches** **\--delete** **\--git-directory** git_directory **\--config-directory** config_directory

# DESCRIPTION

**git_delete_stale_branches** safely deletes your version controlled branches. It allows one to version control branches that are not necessary anymore and delete these checked out branches safely in another machine. Imagine that you are developing a branch on a machine A and on a machine B. What happens when you merge that branch or simply want to delete it? Will you remember which branches are ok to delete when you use machine B? Or what happens if you try to sync deleted branches from git when checked out on a branch that needs deletion? This is where **git_delete_stale_branches** steps in.

## Relevant files

*   `official` file: a single line file containing the name of the main branch. This branch shall never be deleted.

    Example:

    ```
    main
    ```

*   `deleted` file: a headerless CSV with 2 fields: `unix_epoch,branch_name` where `unix_epoch` is the unix epoch of the time when the branch is marked for deletion and `branch_name` is the branch name.

    Example:

    ```
    1677801916,t_204_a_yaml_in_vim_local
    1675099986,t_149_replace_old_scala_metals
    1675099986,t_192_a_local
    1651164877,dev_grammar_vim_grammarous
    1648935017,dev_find_out_why_makeprg_is_stalling_improved_01
    ```

## Recommended usage

One can create the necessary files like so:

```
[[ -d ./.git ]] \
    && mkdir -p other/git/branches/ \
    && touch other/git/branches/{deleted,official}
```

# GENERAL OPTIONS

**-c**, **\--config-directory**
:   Specify the config directory. This directory must hold the `official` and `deletes` files.

**-g**, **\--git-directory**
:   Specify the git root directory that will have its branches deleted.

**-d**, **\--delete**
:   This flag is spurious but ensures that the user is aware that deletions will occur.
