#!/usr/bin/env bash
set -e
ARGS="--threads=2"
BIN_NAME="gitleaks_bin/gitleaks"

mkdir -p repos gitleaks_bin reports
curl -LO "https://github.com/zricethezav/gitleaks/releases/download/v3.0.3/gitleaks-linux-amd64"

mv gitleaks-linux-amd64 $BIN_NAME
chmod +x $BIN_NAME

for i in `cat repo-list.txt`; do
  echo "Scanning $i"
  basename=$(basename $i)
  reponame=${basename%.*}
  if [ -d "repos/$reponame" ]; then
    rm -rf "repos/$reponame"
  fi
  git clone --depth=20 $i repos/$reponame
  $BIN_NAME ${ARGS} --report=reports/${reponame}.json --repo-path=repos/$reponame
  if [ -f "${reponame}.json" ]; then
    cat reports/${reponame}.json | jq -c '.[]' > reports/${reponame}-l.json
    rm reports/${reponame}.json
  fi
done

rm -rf repos gitleaks_bin
if [ -z "$(ls -A reports)" ]; then
    echo "No secrets leaked"
else
    cat reports/*-l.json > reports/full-report.json
    ls -lh reports
fi

