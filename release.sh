# Scrpt for automatically exporting diff in the correct format for all patches
set -e

patch() {
  patchName=$1
  branchChanges=$2
  branchBase=$3
  useCommit=$4

  commitBase=$(git rev-parse --short $branchBase)
  base=""
  if [[ $useCommit -eq 1 ]]; then 
    base=$commitBase
  else
    base=$branchBase
  fi
  cdate=$(date "+%Y%m%d")
  patchFile="patches/st-$patchName-$cdate-$base.diff"

  git checkout $branchBase
  git checkout -b tmpSquash
  git merge --squash $branchChanges
  git commit -am "patch: $patchName"
  git format-patch --stdout $branchBase > $patchFile
  git checkout master
  git branch -D tmpSquash

  echo "output: $patchFile"
}

patch history      historyVanilla      master           1
patch columns      patch_column        historyVanilla   0 
patch scrollback   patch_scrollback    historyVanilla   0
patch selection    patch_sel           historyVanilla   0
patch repaint      patch_repaint       patch_scrollback 0


