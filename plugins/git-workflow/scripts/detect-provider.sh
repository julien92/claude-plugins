#!/bin/bash
# Detect Git provider from remote URL
# Returns: github | gitlab | bitbucket | unknown
#
# Usage in commands:
#   Provider: !`bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-provider.sh`
#
# Supports:
#   - GitHub (github.com)
#   - GitLab (gitlab.com)
#   - Bitbucket (bitbucket.org)
#   - Custom via GIT_PROVIDER env var

# Allow override via environment variable
if [[ -n "$GIT_PROVIDER" ]]; then
    echo "$GIT_PROVIDER"
    exit 0
fi

# Get remote URL
remote_url=$(git remote get-url origin 2>/dev/null)

if [[ -z "$remote_url" ]]; then
    echo "unknown"
    exit 0
fi

# Detect provider from URL
if [[ "$remote_url" == *"github"* ]]; then
    echo "github"
elif [[ "$remote_url" == *"gitlab"* ]]; then
    echo "gitlab"
elif [[ "$remote_url" == *"bitbucket"* ]]; then
    echo "bitbucket"
else
    echo "unknown"
fi
