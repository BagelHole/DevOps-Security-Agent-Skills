---
name: firebase-app-platform
description: Build and operate apps on Firebase using Auth, Firestore, Cloud Functions, and Hosting.
license: MIT
metadata:
  author: devops-skills
  version: "1.0"
---

# Firebase App Platform

Ship mobile and web backends with Firebase managed services.

## Core Setup

```bash
npm install -g firebase-tools
firebase login
firebase init
firebase deploy
```

## Security and Scale

- Write strict Firestore security rules first.
- Separate environments by Firebase project.
- Enable budget alerts and quota monitoring.
- Move privileged logic into Cloud Functions.

## Related Skills

- [gcp-cloud-functions](../../cloud-gcp/gcp-cloud-functions/) - Function runtime patterns
- [vercel-deployments](../vercel-deployments/) - Frontend deployment option
