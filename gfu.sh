# sync a fork using the upstream branch
# usage: gfu [branch-name (default: master)]
gfu(){

  BRANCH="$1"
  if [ -z "$1" ]; then
    BRANCH="master"
  fi

  echo -n "Fetch and merge upstream for branch $BWhite$BRANCH$NC? [y/N]? "
  read answer
  if echo "$answer" | grep -iq "^y" ;then
      echo ""
  else
      return
  fi

  git remote -v | grep -qi "upstream" &> /dev/null
  if [ $? != 0 ]; then
    echo $BRed"upstream remote not set up"$NC
    echo "adding upstream..."

    UPSTREAM_URL=""
    # Get the upstream repo URL
    if [[ -a "package.json" ]]; then
      UPSTREAM_URL=$(cat package.json | jq .repository.url | grep -Eo "(https?\:\/\/.+\.git)")
    fi

    echo "UPSTREAM_URL: $UPSTREAM_URL"

    # If there's still no upstream, ask for it
    if [ -z "$UPSTREAM_URL" ]; then
      echo "Couldn't find the upstream URL :(\nPlease paste it here (e.g. https://github.com/org/repo.git): "
      read upstream
      if [ -z "$upstream" ]; then
        echo "quitting..."
        return
      fi
      UPSTREAM_URL="$upstream"
    fi

    echo $BPurple"git remote add upstream $UPSTREAM_URL"$NC
    git remote add upstream "$UPSTREAM_URL"
    git remote -v | grep "upstream" --color=none
  fi

  echo "Fetching upstream..."
  echo $BCyan"git fetch upstream"$NC
  git fetch upstream

  echo "Branch: $BRANCH"

  echo "\nChecking out local branch $BRANCH"
  echo $BYellow"git checkout $BRANCH"$NC
  git checkout "$BRANCH"

  echo "\nMerging upstream into local"
  echo $BGreen"git merge upstream/$BRANCH"$NC
  git merge upstream/"$BRANCH"
}