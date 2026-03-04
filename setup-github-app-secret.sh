#!/bin/bash
PROJECT_ID=$1
SECRET_NAME=${2:-liferay-cloud-native-gitops-repo-credentials}

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: ./setup-github-app-secret.sh <PROJECT_ID> [SECRET_NAME]"
    echo ""
    echo "Examples:"
    echo "  Default (GitOps Repo): ./setup-github-app-secret.sh my-project"
    echo "  Workspace Repo:        ./setup-github-app-secret.sh my-project liferay-workspace-repo-credentials"
    exit 1
fi

echo "------------------------------------"
echo "GitHub App Secret Generator"
echo "Target Secret: $SECRET_NAME"
echo "------------------------------------"

read -p "Enter GitHub App ID: " APP_ID
read -p "Enter GitHub App Installation ID: " INSTALL_ID
echo "Paste your Private Key (PEM format) below."
echo "End with Ctrl+D when finished:"
PEM_CONTENT=$(cat)

if [ -z "$APP_ID" ] || [ -z "$INSTALL_ID" ] || [ -z "$PEM_CONTENT" ]; then
    echo "Error: All fields are required."
    exit 1
fi

# Convert PEM line breaks to \n for JSON
ESCAPED_PEM=$(echo "$PEM_CONTENT" | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')

# Create JSON file
cat <<EOF > github-app-credentials.json
{
  "github_app_id": "$APP_ID",
  "github_app_installation_id": "$INSTALL_ID",
  "github_app_private_key": "$ESCAPED_PEM"
}
EOF

echo "------------------------------------"
echo "Generated github-app-credentials.json"
echo "Uploading to Secret Manager."
echo "------------------------------------"

./setup-secret.sh "$PROJECT_ID" "$SECRET_NAME" github-app-credentials.json

# Cleanup
rm github-app-credentials.json

echo "✅ GitHub App credentials stored successfully and local file removed."
