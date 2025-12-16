# Jujutsu Parallel Development Setup

This directory contains scripts for Phase 3: Parallel Development Infrastructure using Jujutsu VCS.

## Quick Start

### 1. Install and Setup Jujutsu

```bash
bash scripts/parallel-dev/jj-setup.sh
```

This will:
- Install Jujutsu (if not already installed)
- Initialize Jujutsu in colocate mode with Git
- Configure parallel development settings
- Set up useful aliases and templates

### 2. Start Parallel Development

```bash
# Start working on 3 features simultaneously
bash scripts/parallel-dev/multi-feature.sh start "account-sync" "lead-scoring" "email-campaign"
```

### 3. Switch Between Features

```bash
# Switch to a feature (instant, no stashing needed!)
jj edit account-sync

# Make changes, then commit
jj commit -m "Implement account sync logic"

# Switch to another feature instantly
jj edit lead-scoring
```

### 4. Sync and Merge

```bash
# Periodically sync all features with main
bash scripts/parallel-dev/multi-feature.sh sync

# List all parallel features
bash scripts/parallel-dev/multi-feature.sh list
```

## Why Jujutsu?

### Key Benefits

1. **Conflict-Free Workflows**
   - Conflicts are stored as first-class objects
   - Continue working even with unresolved conflicts
   - No workflow interruptions

2. **Instant Context Switching**
   - No need for `git stash`
   - Working copy is always a commit
   - Switch features in milliseconds

3. **Automatic Rebasing**
   - Changes automatically propagate to descendants
   - No manual rebase chains
   - Stacked PRs made easy

4. **Safe Exploration**
   - Every operation is logged
   - Easy undo with `jj undo`
   - Experiment freely

## Scripts

### jj-setup.sh

Initializes Jujutsu environment:
- Installs Jujutsu via Homebrew
- Configures colocate mode (works alongside Git)
- Sets up parallel development aliases
- Creates `.jjconfig.toml`

### multi-feature.sh

Main parallel development tool:

**Commands:**
- `start` - Create multiple feature branches
- `switch` - Switch to a feature
- `sync` - Sync all features with main
- `list` - Show parallel feature status
- `help` - Show detailed help

**Example Workflow:**

```bash
# Day 1: Start 3 features
./multi-feature.sh start "feat-a" "feat-b" "feat-c"

# Work on feat-a
jj edit feat-a
# ... make changes ...
jj commit -m "Implement feat-a logic"

# Instant switch to feat-b
jj edit feat-b
# ... make changes ...
jj commit -m "Implement feat-b UI"

# Day 2: Sync with latest main
./multi-feature.sh sync

# Day 3: Create PRs
for feat in feat-a feat-b feat-c; do
  jj edit $feat
  jj git push --branch $feat
done
```

## Advanced Usage

### View Parallel Development Status

```bash
jj log -r parallel
```

### Check for Conflicts

```bash
jj log -r 'conflict()'
```

### Create Stacked PRs

```bash
# Create dependent features
jj new feat-a -m "feat: Dependent feature B"
jj branch create feat-b

# When feat-a changes, feat-b auto-rebases!
```

## Integration with Git

Jujutsu runs in **colocate mode**, meaning:
- Git repository still works normally
- Team members can use Git
- You get Jujutsu's advanced features
- Push/pull works with Git remotes

## Next Steps (Week 2-4)

- Week 2: iTerm2 multi-pane environment
- Week 3: AI conflict resolution (auto-resolve.ts)
- Week 4: Real-time dashboard

## Learn More

- [Jujutsu Official Docs](https://martinvonz.github.io/jj/)
- [Jujutsu GitHub](https://github.com/martinvonz/jj)
