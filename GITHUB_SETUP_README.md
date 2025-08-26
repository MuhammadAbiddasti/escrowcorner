# GitHub Setup Guide for EscrowCorner

This guide will help you set up a new GitHub repository for your EscrowCorner Flutter project and establish a daily workflow for code updates.

## Step 1: Create a New GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in to your account
2. Click the "+" icon in the top right corner and select "New repository"
3. Repository name: `escrowcorner` (or your preferred name)
4. Description: `Flutter-based escrow payment application`
5. Make it **Public** or **Private** (your choice)
6. **DO NOT** initialize with README, .gitignore, or license (we already have these)
7. Click "Create repository"

## Step 2: Connect Your Local Project to GitHub

After creating the repository, GitHub will show you commands. Use these commands in your terminal:

```bash
# Add the new remote origin (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/escrowcorner.git

# Or if you prefer SSH (if you have SSH keys set up):
git remote add origin git@github.com:YOUR_USERNAME/escrowcorner.git
```

## Step 3: First Push to GitHub

```bash
# Add all your current files
git add .

# Commit all changes
git commit -m "Initial commit: EscrowCorner Flutter project"

# Push to GitHub (this will set the upstream branch)
git push -u origin main
```

## Step 4: Daily Workflow

### Option 1: Use the Automated Scripts

We've created two scripts for you:

- **`daily_git_push.bat`** - Windows batch file
- **`daily_git_push.ps1`** - PowerShell script

To use them:
1. Double-click `daily_git_push.bat` (Windows) or
2. Right-click `daily_git_push.ps1` → "Run with PowerShell"

### Option 2: Manual Commands

If you prefer manual control, use these commands daily:

```bash
# Check what files have changed
git status

# Add all changes
git add .

# Commit with a descriptive message
git commit -m "Daily update: [describe your changes]"

# Push to GitHub
git push origin main
```

## Step 5: Best Practices for Daily Updates

1. **Commit Message Format**: Use descriptive commit messages
   - Good: `"Add user authentication feature"`
   - Good: `"Fix login screen UI issues"`
   - Avoid: `"Update"` or `"Changes"`

2. **Commit Frequency**: 
   - Commit at least once daily
   - Commit when you complete a feature or fix
   - Don't let changes accumulate for too long

3. **Before Pushing**:
   - Test your code to ensure it works
   - Review what you're about to commit (`git status`)
   - Make sure you're not committing sensitive information

## Step 6: Troubleshooting

### If you get "rejected" errors:
```bash
# Pull the latest changes first
git pull origin main

# Then push again
git push origin main
```

### If you need to check your remote:
```bash
git remote -v
```

### If you need to change remote URL:
```bash
git remote set-url origin https://github.com/YOUR_USERNAME/escrowcorner.git
```

## Step 7: Verify Setup

After setup, verify everything works:

```bash
# Check remote
git remote -v

# Check status
git status

# Check branch
git branch
```

## Daily Workflow Summary

1. **Morning**: Pull latest changes (`git pull origin main`)
2. **During development**: Make your changes
3. **End of day**: Run the daily push script or manual commands
4. **Before major changes**: Create a new branch for features

## Need Help?

- Git documentation: https://git-scm.com/doc
- GitHub guides: https://guides.github.com/
- Flutter documentation: https://flutter.dev/docs

---

**Remember**: The goal is to push code daily to keep your GitHub repository updated with your latest work!
