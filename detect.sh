#!/usr/bin/env bash

ARGS="--disk --threads=4 --redact"
BIN_NAME="gitleaks_bin/gitleaks"

mkdir -p gitleaks_bin reports
curl -LO "https://github.com/zricethezav/gitleaks/releases/download/v3.0.3/gitleaks-linux-amd64"

mv gitleaks-linux-amd64 $BIN_NAME
chmod +x $BIN_NAME

for i in `cat repo-list.txt`; do
  echo "Scanning $i"
  basename=$(basename $i)
  reponame=${basename%.*}
  $BIN_NAME ${ARGS} -r ${i} --report=reports/${reponame}.json
  cat reports/${reponame}.json | jq -c '.[]' > reports/${reponame}-l.json
done

cat reports/*-l.json > reports/full-report.json

rm -rf gitleaks_bin
ls -lh reports
