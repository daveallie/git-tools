#!/bin/sh

set -e

function pluralize {
  echo "$1 $([ "$1" -eq 1 ] && echo "$2" || echo "$3")"
}

function old_branches {
  DAYS_AGO=7
  FETCH=true

  while [ $# -gt 0 ]; do
    KEY="$1"
    case $KEY in
        -d|--days)
          shift
          if [ $# -gt 0 ]; then
            DAYS_AGO=$1
          else
            echo "days flag needs an argument!"
            exit 1
          fi
          ;;
        -n|--no-fetch) FETCH=false;;
        -*) echo "Unknown flag ${KEY:1}"; exit 1;;
        *) echo "Ignored argument $KEY";;
    esac
    shift
  done

  if [ "$FETCH" = true ]; then
    echo "Fetching\n"
    git fetch -q -p
  else
    echo "Not Fetching\n"
  fi

  COMPARE_TIME=$(($(date +%s)-($DAYS_AGO * 24 * 60 * 60)))
  OUT_ARRAY=()

  for BRANCH in $(git branch -r | grep -v "HEAD" | sed "s/  //"); do
    LAST_COMMIT_INFO=$(git show --format="%ci;%cn" $BRANCH | head -n 1)
    LAST_COMMIT_TIME=$(echo "${LAST_COMMIT_INFO//;/\n}" | head -n 1)
    LAST_COMMIT_EPOCH=$(date -j -f "%Y-%m-%d %T %z" "$LAST_COMMIT_TIME" +%s)
    LAST_COMMIT_AUTHOR=$(echo "${LAST_COMMIT_INFO//;/\n}" | tail -n 1)
    if [ "$LAST_COMMIT_EPOCH" -lt "$COMPARE_TIME" ]; then
      OUT_ARRAY+=("$(printf "%s\t%-25s\t%s" "$(date -j -f "%Y-%m-%d %T %z" "$LAST_COMMIT_TIME" "+%Y-%m-%d %H:%M")" "$LAST_COMMIT_AUTHOR" "$(echo $BRANCH | sed "s/origin\///")")")
    fi
  done

  OUT_ARRAY_LEN=${#OUT_ARRAY[@]}

  if [ "$OUT_ARRAY_LEN" -eq 0 ]; then
    echo "No branches with last commit more than $DAYS_AGO day/s ago."
  else

    echo "$(pluralize $OUT_ARRAY_LEN "branch" "branches") with last commit more than $(pluralize $DAYS_AGO "day" "days") ago:"
    printf "%-16s\t%-25s\t%s\n" "  Last Commit" "  Author" "  Branch"
    for ELEM in "${OUT_ARRAY[@]}"; do
      echo "$ELEM"
    done | sort
  fi
}

function clean_remotes {
  MERGE_BRANCH=master
  FETCH=true

  while [ $# -gt 0 ]; do
    KEY="$1"
    case $KEY in
        -m|--merge-branch)
          shift
          if [ $# -gt 0 ]; then
            MERGE_BRANCH=$1
          else
            echo "merge branch flag needs an argument!"
            exit 1
          fi
          ;;
        -n|--no-fetch) FETCH=false;;
        -*) echo "Unknown flag ${KEY:1}"; exit 1;;
        *) break;;
    esac
    shift
  done

  if [ "$FETCH" = true ]; then
    echo "Fetching\n"
    git fetch -q -p
  else
    echo "Not Fetching\n"
  fi

  BRANCHES=$(git branch -r --merged "origin/$MERGE_BRANCH" | sed "s/  origin\///" | grep -v $MERGE_BRANCH)
  while [ $# -gt 0 ]; do
    BRANCHES=$(echo "$BRANCHES" | grep -v "$1" || echo "")
    shift
  done

  if [ -n "$BRANCHES" ]; then
    echo "Branches that have been merged into $MERGE_BRANCH but have not been deleted:"
    printf "%-16s\t%-25s\t%s\n" "  Last Commit" "  Author" "  Branch"
    for BRANCH in $BRANCHES; do
      LAST_COMMIT_INFO=$(git show --format="%ci;%cn" "origin/$BRANCH" | head -n 1)
      LAST_COMMIT_TIME=$(echo "${LAST_COMMIT_INFO//;/\n}" | head -n 1)
      LAST_COMMIT_AUTHOR=$(echo "${LAST_COMMIT_INFO//;/\n}" | tail -n 1)
      printf "%s\t%-25s\t%s\n" "$(date -j -f "%Y-%m-%d %T %z" "$LAST_COMMIT_TIME" "+%Y-%m-%d %H:%M")" "$LAST_COMMIT_AUTHOR" "$BRANCH"
    done
    echo ""

    while true; do
      read -p "Do you wish to delete all of these branches? (y/n) " yn
      case $yn in
        [Yy]* ) echo $BRANCHES | xargs git push --delete origin; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
      esac
    done
  else
    echo "No branches to remove.\n"
  fi
}

case $1 in
  clean_branches|clean_remotes|clean) shift; clean_remotes "$@";;
  old_branches|old_remotes|old) shift; old_branches "$@";;
  *) echo 'Please use clean_branches, clean_remotes, clean, or old_branches, old_remotes, old as first argument!'; exit 1;;
esac
