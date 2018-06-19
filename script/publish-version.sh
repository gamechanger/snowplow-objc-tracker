#!/bin/bash

guard_master_branch() {
    local -r CURRENT_BRANCH=$(git branch | sed -n '/\* /s///p')
    if [ "$CURRENT_BRANCH" != 'master' ]; then
        echo You are not on master.  You need to be on master to run this script.
        exit 1
    fi
}

guard_work_in_progress() {
    local -r UNTRACKED_FILES=$(git status --porcelain | wc -l)
    if [ "$UNTRACKED_FILES" -ne 0 ]; then
        echo Uncommitted or untracked files are detected.  Please commit them or stash them before you run this script
        exit 1
    fi
}

update_podspec() {
    local -r VERSION=$1
    pushd "${0%/*}"
    ruby generate-podspec.rb "$VERSION" > ../GCSnowplowTracker.podspec
    git add ../GCSnowplowTracker.podspec
    git commit -m "feat(podspec): update to $VERSION" || true
    popd
}

push_git() {
    local -r VERSION="$1"
    git tag "$VERSION"
    git push --tags origin master
}

tear_down() {
    local -r TAG="$1"
    local -r HEAD="$2"
    git tag -d "$TAG"
    git push origin :refs/tags/"$TAG"
    git reset --hard "$HEAD"
    git push --force origin master
}

main() {
    if [ $# -ne 1 ]; then
        echo 'Please supply a semantic version number, e.g. 3.1.4'
        exit 1
    fi
    guard_master_branch
    guard_work_in_progress
    set -e
    local -r VERSION="$1"
    local -r HEAD=$(git rev-parse HEAD)
    update_podspec "$VERSION"
    push_git "$VERSION"
    pod repo push --allow-warnings gamechanger "${0%/*}"/../GCSnowplowTracker.podspec || tear_down "$VERSION" "$HEAD"
}

main "$1"