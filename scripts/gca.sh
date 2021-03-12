#!/bin/bash

set -u

readonly BRANCH_NAME_SUFFIX=$1
readonly LOWEST_VERSION_ARG=$2

readonly BRANCH_80="PS-8.0-$BRANCH_NAME_SUFFIX"
readonly BRANCH_57="PS-5.7-$BRANCH_NAME_SUFFIX"
readonly BRANCH_56="PS-5.6-$BRANCH_NAME_SUFFIX"

readonly DEFAULT_LOWEST_VERSION="5.6"

readonly WORK_SRC_ROOT="/Users/rahulmalik/MySQL"
readonly WORK_MAIN_REPO="percona-server"
readonly REMOTE="origin"

if [ "$LOWEST_VERSION_ARG" = "" ]; then
    echo "Creating branches starting at $DEFAULT_LOWEST_VERSION"
    LOWEST_VERSION="$DEFAULT_LOWEST_VERSION"
else
    LOWEST_VERSION="$LOWEST_VERSION_ARG"
fi

if [ "$LOWEST_VERSION" != "5.6" ] && [ "$LOWEST_VERSION" != "5.7" ]; then
    echo "Only 5.6 and 5.7 are valid lowest versions"
    exit 1
fi

function create_git_gca_worktree ()
{
    local lower_base_branch=$1
    local lower_branch=$2
    local higher_branch=$3

    local gca_rev
    gca_rev="$(git rev-list "$lower_base_branch" ^"$higher_branch" --first-parent --topo-order \
        | tail -1)^"

    echo "Creating $lower_branch from $lower_base_branch for merge to $higher_branch at $gca_rev"

    git worktree add -b "$lower_branch" "../$lower_branch" "$gca_rev"
}

pushd "$WORK_SRC_ROOT/$WORK_MAIN_REPO" || exit 1

git fetch $REMOTE 
git worktree add -b "$BRANCH_80" "../$BRANCH_80" $REMOTE/8.0
create_git_gca_worktree "$REMOTE/5.7" "$BRANCH_57" "$BRANCH_80"
if [ "$LOWEST_VERSION" = "5.6" ]; then
   create_git_gca_worktree "$REMOTE/5.6" "$BRANCH_56" "$BRANCH_57"
fi

popd || exit 0
