#!/bin/bash
REPO_CLONE_DIR="./.tmp/"

# get repo clone URL from the Terraform output
REPO_CLONE_URL=$(terraform output -json | jq -r '.repo_clone_url.value')
AUTHED_REPO_CLONE_URL=$(echo $REPO_CLONE_URL | sed "s/https:\/\//https:\/\/$AZDO_PERSONAL_ACCESS_TOKEN@/g")

echo "Cloning from $REPO_CLONE_URL using AzDO PAT"
git clone "$AUTHED_REPO_CLONE_URL" "$REPO_CLONE_DIR"

cp *.yml "$REPO_CLONE_DIR"

(
    cd "$REPO_CLONE_DIR"                      && \
    git add -A                                && \
    git commit -m"Adding azure pipeline file" && \
    git push
)

rm -rf "$REPO_CLONE_DIR"
