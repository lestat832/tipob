# Recent Work - Security Fix & Analytics

## December 2025

### Security Fix (Dec 10)
- Removed GoogleService-Info.plist from git history using filter-branch
- Added comprehensive .gitignore entries for secrets
- Documented Firebase setup in README

### Git History Cleanup Pattern
```bash
# Stash changes first
git stash

# Remove file from all history
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch path/to/secret/file' \
  --prune-empty --tag-name-filter cat -- --all

# Clean up refs
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push
git push --force origin main
```

### Analytics Events Active
- start_game (menu only)
- replay_game (play again only)  
- discreet_mode_toggled

### Prevention Best Practices
- Add sensitive files to .gitignore BEFORE creating them
- Never commit API keys, plist files, or credentials
- Use environment variables or download from console
