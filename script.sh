#!/usr/bin/env bash -x

# GHA runs the script with `bash -e`. We don't need that.
set +e
PR_DETAILS=$(gh api /repos/${REPO}/pulls/${PR_NUMBER})
PR_DESC=$(echo ${PR_DETAILS} | jq -r .body)

URL="https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword"
ALL_CLEAR_MSG=${ALL_CLEAR_MSG:-"PR links to an issue 🎉"}
MISSING_LINK_MSG=${MISSING_LINK_MSG:-"Please update the pull request description to include an [issue link](${URL})."}

ISSUE_PATTERN="([\w\/-])?#\d+"
CLOSE_PATTERN="close(s|d)?\s+${ISSUE_PATTERN}"
FIX_PATTERN="fix(es|ed)?\s+${ISSUE_PATTERN}"
RESOLVE_PATTERN="resolve(s|d)?\s+${ISSUE_PATTERN}"

function match() {
  node -e "process.exitCode = /${2}/gim.test('${1}') === true ? 0 : 1"
  return ${?}
}

function allClear() {
  gh issue comment -R ${REPO} ${PR_NUMBER} --edit-last --body "${ALL_CLEAR_MSG}" 2>&1 > /dev/null
  if [ $? -eq 0 ]; then
    return 0
  fi
  gh issue comment -R ${REPO} ${PR_NUMBER} --body "${ALL_CLEAR_MSG}"
}

function notLinked() {
  gh issue comment -R ${REPO} ${PR_NUMBER} --edit-last --body "${MISSING_LINK_MSG}" 2>&1 > /dev/null
  if [ $? -eq 0 ]; then
    return 0
  fi
  gh issue comment -R ${REPO} ${PR_NUMBER} --body "${MISSING_LINK_MSG}"
}

match "${PR_DESC}" "${CLOSE_PATTERN}"
if [ $? -eq 0 ]; then
  allClear
  exit 0
fi

match "${PR_DESC}" "${FIX_PATTERN}"
if [ $? -eq 0 ]; then
  allClear
  exit 0
fi

match "${PR_DESC}" "${RESOLVE_PATTERN}"
if [ $? -eq 0 ]; then
  allClear
  exit 0
fi

notLinked

exit 1