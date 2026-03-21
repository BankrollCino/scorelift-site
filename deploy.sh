#!/bin/bash
# deploy.sh — Deploy ScoreLift website to GitHub Pages
# Run this ONCE after: gh auth login
#
# Usage: bash deploy.sh

set -e

echo "🚀 Deploying ScoreLift to GitHub Pages..."

# 1. Authenticate check
if ! gh auth status &>/dev/null; then
  echo "❌ Not logged into GitHub. Run: gh auth login"
  echo "   Then re-run this script."
  exit 1
fi

GITHUB_USER=$(gh api user --jq '.login')
echo "✅ Logged in as: $GITHUB_USER"

# 2. Create the repo (public, for GitHub Pages)
echo "📁 Creating repo: scorelift-site..."
gh repo create scorelift-site \
  --public \
  --description "ScoreLift Credit Repair — Professional Credit Repair Service" \
  --source . \
  --remote origin \
  --push \
  2>/dev/null || echo "  Repo may already exist — pushing..."

# If repo already exists, just add remote and push
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$GITHUB_USER/scorelift-site.git" 2>/dev/null || true
git push -u origin main --force

# 3. Enable GitHub Pages (branch: main, folder: / root)
echo "🌐 Enabling GitHub Pages..."
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$GITHUB_USER/scorelift-site/pages" \
  -f source='{"branch":"main","path":"/"}' \
  2>/dev/null || true

# Also try PUT (to update if already exists)
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$GITHUB_USER/scorelift-site/pages" \
  -f source='{"branch":"main","path":"/"}' \
  2>/dev/null || true

echo ""
echo "✅ Done! Your website will be live at:"
echo "   🔗 https://$GITHUB_USER.github.io/scorelift-site/"
echo ""
echo "   (It may take 1-2 minutes for GitHub Pages to activate)"
echo ""
echo "📌 Also available at:"
echo "   https://github.com/$GITHUB_USER/scorelift-site"
