#!/bin/bash

# Ensure necessary directories exist
mkdir -p logs
mkdir -p deploy

# Check for changes in the Git repository
changed_files=$(git status --porcelain)

if [ -n "$changed_files" ]; then
    echo "Changes detected in the repository:"
    echo "$changed_files"

    # Stage all changes
    git add .

    # Commit the changes
    commit_msg="Auto-deploy on $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$commit_msg"

    # Push changes to the remote repository
    git push

    # Copy all .sh files from src/ to deploy/
    cp src/*.sh deploy/ 2>/dev/null

    # Log deployment timestamp and copied files to logs/deploy.log
    {
        echo "Deployment Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Files copied to deploy/:"
        ls deploy/*.sh 2>/dev/null
        echo "-----------------------------"
    } >> logs/deploy.log

    echo "Deployment complete. Log saved to logs/deploy.log"

else
    echo "No changes to deploy."
fi

