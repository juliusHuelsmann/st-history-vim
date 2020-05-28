# Script for automatically exporting diff in the correct format for all patches
# Usage: 
#    $1: if 1: export patch files.
#    $2: if 1: export meta patches.
# Should both be true.
# Prior to executing, make sure that 
#    (1) mkdir patches
#    (2) you checked out all the available branches.

set -e

# Return the name of the generated patch file.
getPatchFileName() {
  patchName=$1
  branchBase=$2
  useCommit=$3

  commitBase=$(git rev-parse --short $branchBase)
  base=""
  if [[ $useCommit -eq 1 ]]; then 
    base=$commitBase
  else
    base=$branchBase
  fi
  cdate=$(date "+%Y%m%d")
  patchFile="patches/st-$patchName-$cdate-$base.diff"
  echo $patchFile
}

# Generate a patch from the git repo.
patch() {
  patchName=$1
  branchChanges=$2
  branchBase=$3
  useCommit=$4
  
  patchOutputFile=$(getPatchFileName $patchName $branchBase $useCommit)

  git checkout $branchBase
  git checkout -b tmpSquash
  git merge --squash $branchChanges
  git commit -am "patch: $patchName"
  git format-patch --stdout $branchBase > $patchOutputFile
  git checkout master
  git branch -D tmpSquash

  echo "output: $patchOutputFile"
}

namePatchHistory="history"
namePatchCols="columns"
namePatchScrollback="scrollback"
namePatchSel="selection"
namePatchRepaint="repaint"
namePatchVim="vim-browse"


# Generate meta patches from the patches generated above.
metaPatch() {
  metaPatchName="meta-$1"
  branchBase=$2
  useCommit=$3
  
  tmpBranch=tmp-$metaPatchName
  patchOutputFile=$(getPatchFileName $metaPatchName $branchBase $useCommit)

  # Go to the base branch and branch off the tmpBranch
  git checkout $branchBase
  if git show-ref --quiet refs/heads/$tmpBranch; then
    git branch -D $tmpBranch
  fi
  git checkout -b $tmpBranch

  for name in "${@:4}"; do 
    patchFile=$(ls -Ar patches/st-$name* 2> /dev/null | head -n 1) 
    if [[ -z "$patchFile" ]]; then 
      echo "Error: patch file for $name not found. Abort."
      exit
    else
      echo -e "patch file: $name:\t $patchFile"
    fi

    git apply $patchFile
  done

  git commit -am "meta-patch: $patchName"
  git format-patch --stdout $branchBase > $patchFile
  git checkout master
  
  echo "meta-output: $patchOutputFile from $tmpBranch"
}

exportRaw=$1
exportMeta=$2

# 'raw' single patches
if [[ $exportRaw -eq 1 ]]; then
  patch $namePatchHistory    historyVanilla      st-0.8.3         1
  patch $namePatchCols       patch_column        historyVanilla   0 
  patch $namePatchScrollback patch_scrollback    historyVanilla   0
  patch $namePatchSel        patch_sel           historyVanilla   0
  patch $namePatchRepaint    patch_repaint       patch_scrollback 0
  patch $namePatchVim        patch_vim           patch_sel        0
fi

if [[ $exportMeta -eq 1 ]]; then
  metaPatch "scrollback-full"  st-0.8.3 1 $namePatchHistory $namePatchCols $namePatchSel $namePatchScrollback 
  metaPatch "scrollback"       st-0.8.3 1 $namePatchHistory $namePatchScrollback 
  metaPatch "vim-full"         st-0.8.3 1 $namePatchHistory $namePatchCols $namePatchSel $namePatchVim 
  metaPatch "vim-full-dev"     st-0.8.3 1 $namePatchHistory $namePatchCols $namePatchSel $namePatchVim  $namePatchRepaint
fi

