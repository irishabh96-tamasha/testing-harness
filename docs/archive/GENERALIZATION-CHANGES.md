# Onboarding Documentation Generalization Changes

## Overview

This document tracks the changes made to generalize onboarding documentation for broader adoption.

## Automated Script

Run the following script to apply all changes automatically:

```bash
bash scripts/generalize-onboarding-docs.sh
```

The script creates backups (.bak files) before making changes.

## Manual Changes (if script not used)

If you need to make changes manually, here are the specific updates required:

### Files to Update

1. `docs/onboarding/DAY-1-CHECKLIST.md`
2. `docs/onboarding/SOCIAL-MEDIA-SETUP.md`
3. `docs/onboarding/AGENT-SETUP-GUIDE.md`
4. `docs/onboarding/META-PROMPTS-FOR-USERS.md`
5. `docs/onboarding/USER-JOURNEY-VALIDATION-REPORT.md`

### Changes to Apply

#### 1. Replace "MOB SAFe" with "SAFe"

**Find:**

- `MOB SAFe Multi-Agent Development` → `SAFe Multi-Agent Development`
- `MOB SAFe methodology` → `SAFe multi-agent methodology`
- `the MOB methodology` → `the SAFe methodology`
- `MOB SAFe` → `SAFe multi-agent` (general references)

#### 2. Generalize GitHub URLs

**Find:** `https://github.com/tamasha-live/mobile-app-Agentic-Workflow`
**Replace:** `https://github.com/tamasha-live/mobile-app`

**Locations:**

- Clone commands
- Repository links
- PR links
- Discussion links

#### 3. Generalize GitIngest URLs

**Find:** `https://gitingest.com/tamasha-live/mobile-app-Agentic-Workflow`
**Replace:** `https://gitingest.com/tamasha-live/{{GITHUB_REPO}}`

#### 4. Generalize Project Name

**Find:** `cd mobile-app-Agentic-Workflow`
**Replace:** `cd mobile-app`

#### 5. Generalize Ticket Prefixes

**Find:** `MOB-{number}` (e.g., `MOB-326`, `MOB-123`)
**Replace:** `MOB-{number}`

**Find:** `PROJ-{number}` (example tickets)
**Replace:** `MOB-{number}`

#### 6. Keep Generic Examples

**DO NOT CHANGE** these generic GitHub URLs (they're useful examples):

- `https://github.com/settings/tokens`
- `https://linear.app/settings/api`
- `https://id.atlassian.com/manage-profile/security/api-tokens`

## File-Specific Changes

### DAY-1-CHECKLIST.md

```diff
- # Day 1 Checklist: MOB SAFe Multi-Agent Development
+ # Day 1 Checklist: SAFe Multi-Agent Development

- **Purpose**: Your first day with the MOB SAFe methodology
+ **Purpose**: Your first day with the SAFe multi-agent methodology

- git clone https://github.com/tamasha-live/mobile-app-Agentic-Workflow
- cd mobile-app-Agentic-Workflow
+ git clone https://github.com/tamasha-live/mobile-app
+ cd mobile-app

- Visit: https://gitingest.com/tamasha-live/mobile-app-Agentic-Workflow
+ Visit: https://gitingest.com/tamasha-live/{{GITHUB_REPO}}

- I want to create a test Linear ticket to validate my MOB SAFe setup.
+ I want to create a test Linear ticket to validate my SAFe multi-agent setup.

- Title: `PROJ-1: Add Hello World endpoint...`
+ Title: `MOB-1: Add Hello World endpoint...`

- **Congratulations!** You've completed Day 1 of the MOB SAFe Multi-Agent Development methodology.
+ **Congratulations!** You've completed Day 1 of the SAFe Multi-Agent Development methodology.

- GitHub Discussions: https://github.com/tamasha-live/mobile-app-Agentic-Workflow/discussions
+ GitHub Discussions: See your repository's discussions page

- Email: ronak@tamasha.live
+ (Remove or replace with your contact)
```

### SOCIAL-MEDIA-SETUP.md

```diff
- How to configure social sharing for the MOB SAFe Multi-Agent Development repository.
+ How to configure social sharing for the SAFe Multi-Agent Development repository.

- 1. Go to: https://github.com/tamasha-live/mobile-app-Agentic-Workflow
+ 1. Go to: https://github.com/tamasha-live/mobile-app

- **Project Name**: "MOB SAFe Multi-Agent Development"
+ **Project Name**: "mobile-app SAFe Multi-Agent Development"

- content="https://tamasha-live.github.io/mobile-app-Agentic-Workflow/"
+ content="https://tamasha-live.github.io/{{GITHUB_REPO}}/"
```

### AGENT-SETUP-GUIDE.md

```diff
- ## Installing and Using the 11-Agent MOB SAFe System
+ ## Installing and Using the 11-Agent SAFe System

- The MOB SAFe methodology uses **11 specialized AI agents**
+ The SAFe multi-agent methodology uses **11 specialized AI agents**

- git clone https://github.com/tamasha-live/mobile-app-Agentic-Workflow
- cd mobile-app-Agentic-Workflow
+ git clone https://github.com/tamasha-live/mobile-app
+ cd mobile-app

- Create spec for MOB-123
+ Create spec for MOB-123

- I need to implement MOB-123 (user profile feature).
+ I need to implement MOB-123 (user profile feature).

- You've successfully set up the MOB SAFe 11-agent system.
+ You've successfully set up the SAFe 11-agent system.
```

### META-PROMPTS-FOR-USERS.md

```diff
- # Meta-Prompts for MOB SAFe Multi-Agent Development
+ # Meta-Prompts for SAFe Multi-Agent Development

- **Repository**: https://github.com/tamasha-live/mobile-app-Agentic-Workflow
+ **Repository**: https://github.com/tamasha-live/mobile-app

- I want to set up the MOB SAFe Multi-Agent Development methodology
+ I want to set up the SAFe Multi-Agent Development methodology

- I've cloned the repository from https://github.com/tamasha-live/mobile-app-Agentic-Workflow
+ I've cloned the repository from https://github.com/tamasha-live/mobile-app

- I'm working on a task and need to know which MOB SAFe agent to invoke.
+ I'm working on a task and need to know which SAFe agent to invoke.

- Based on the MOB SAFe methodology with 11 agent roles:
+ Based on the SAFe multi-agent methodology with 11 agent roles:

- I've cloned the MOB SAFe Agentic Workflow repository
+ I've cloned the SAFe Agentic Workflow repository

- I want to integrate the MOB SAFe multi-agent workflow
+ I want to integrate the SAFe multi-agent workflow

- I've just set up the MOB SAFe Multi-Agent Development methodology.
+ I've just set up the SAFe Multi-Agent Development methodology.

- Repository cloned: `git clone https://github.com/tamasha-live/mobile-app-Agentic-Workflow`
+ Repository cloned: `git clone https://github.com/tamasha-live/mobile-app`

- I'm having trouble with the MOB SAFe Multi-Agent Development setup.
+ I'm having trouble with the SAFe Multi-Agent Development setup.

- **GitIngest Link**: https://gitingest.com/tamasha-live/mobile-app-Agentic-Workflow
+ **GitIngest Link**: https://gitingest.com/tamasha-live/{{GITHUB_REPO}}
```

### USER-JOURNEY-VALIDATION-REPORT.md

```diff
- ## mobile-app-Agentic-Workflow Repository
+ ## SAFe-Agentic-Workflow Repository

- **Ticket**: MOB-326
+ **Ticket**: MOB-326

- **Repository**: https://github.com/tamasha-live/mobile-app-Agentic-Workflow
+ **Repository**: https://github.com/tamasha-live/mobile-app

- **URL**: https://gitingest.com/tamasha-live/mobile-app-Agentic-Workflow
+ **URL**: https://gitingest.com/tamasha-live/{{GITHUB_REPO}}

- ### ✅ COMPLETED (MOB-326)
+ ### ✅ COMPLETED (MOB-326)

- ### Future Enhancements (Post-MOB-326)
+ ### Future Enhancements (Post-MOB-326)

- **MOB-326 Achievement**: Transformed user onboarding
+ **MOB-326 Achievement**: Transformed user onboarding
```

## Verification

After making changes, verify with:

```bash
# Check for remaining MOB references (should find none)
grep -r "MOB" docs/onboarding/*.md

# Check for hardcoded GitHub URLs (should find only generic ones)
grep -r "tamasha-live" docs/onboarding/*.md

# Check for MOB- ticket prefixes (should find none)
grep -r "MOB-" docs/onboarding/*.md
```

## Rollback

If you used the automated script and need to rollback:

```bash
for f in docs/onboarding/*.bak; do
  mv "$f" "${f%.bak}"
done
```

## Impact

These changes make the onboarding documentation:

1. **Portable**: Works for any project using this methodology
2. **Customizable**: Clear placeholders for project-specific values
3. **Professional**: No hardcoded references to original project
4. **Reusable**: Can be adopted without modification

## Next Steps

After generalization, teams adopting this methodology should:

1. Replace `https://github.com/tamasha-live/mobile-app` with their repository URL
2. Replace `tamasha-live` and `{{GITHUB_REPO}}` with their GitHub org/repo names
3. Replace `mobile-app` with their project directory name
4. Replace `MOB` with their ticket prefix (e.g., `PROJ`, `TASK`, `FEAT`)
5. Update contact information (remove or replace email addresses)

These replacements can be done with a single script or manually as part of repository customization.
