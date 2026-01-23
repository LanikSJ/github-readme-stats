#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Use the checked-out repository path by default (Actions sets GITHUB_WORKSPACE)
repo_dir="${GITHUB_WORKSPACE:-/repo}"

if [ ! -d "$repo_dir" ]; then
  echo "Repository directory $repo_dir not found. Exiting."
  exit 1
fi

cd "$repo_dir"

if [ -z "${PAT_1:-}" ]; then
  echo "No PAT_1 provided via environment; continuing using local checkout."
else
  echo "PAT_1 provided — ensure this token has least privilege and is stored in GitHub Secrets."
fi

if [ -f package.json ]; then
  has_dev_express=$(jq -e '.devDependencies.express // empty' package.json || true)
  has_dep_express=$(jq -e '.dependencies.express // empty' package.json || true)
  if [ -n "$has_dev_express" ] && [ -z "$has_dep_express" ]; then
    echo "Moving express from devDependencies to dependencies in package.json..."
    jq 'if .devDependencies and .devDependencies.express then .dependencies += {express:.devDependencies.express} | .devDependencies |= (del(.express) ) else . end' package.json > package.tmp.json
    mv package.tmp.json package.json
  fi
fi

if [ -f package-lock.json ]; then
  echo "Installing production dependencies with npm ci..."
  npm ci --production --no-audit --no-fund
else
  echo "No package-lock.json found: running npm install (not recommended for reproducible builds)."
  npm install --production --no-audit --no-fund
fi

echo "Entrypoint finished."
