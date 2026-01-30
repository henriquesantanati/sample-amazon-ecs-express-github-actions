## Security Scan Suppressions

This document explains the security scan findings that have been suppressed and why they are acceptable for this project.

### Checkov Findings (Static Analysis for IaC)

#### CKV_DOCKER_3: Container User Creation
**Location:** `Dockerfile:1`  
**Suppression:** `# checkov:skip=CKV_DOCKER_3`

**Justification:**  
The base image ([aws-containers/retail-store-sample-ui](https://github.com/aws-containers/retail-store-sample-app/blob/main/src/ui/Dockerfile)) already creates a non-root user. Since we inherit from this official AWS container image, the security control is already implemented at the base layer. Re-creating a user would be redundant and could introduce conflicts.

**Risk Assessment:** ✅ Low - Base image implements proper user security

---

#### CKV_DOCKER_2: HEALTHCHECK Instructions
**Location:** `Dockerfile:1`  
**Suppression:** `# checkov:skip=CKV_DOCKER_2`

**Justification:**  
Health checks are handled at the infrastructure layer by ECS and Application Load Balancer (ALB):
- **ECS Health Checks:** Container-level health monitoring through ECS task health checks
- **ALB Target Health:** Application-level health validation via ALB target group health checks

Dockerfile-level HEALTHCHECK instructions would be redundant and could conflict with ECS health check configurations.

**Risk Assessment:** ✅ Low - Health monitoring is properly configured at the orchestration layer

---

#### CKV2_GHA_1: GitHub Actions Permissions
**Location:** `.github/workflows/deploy.yml:21`  
**Suppression:** `# checkov:skip=CKV2_GHA_1`

**Justification:**  
The deployment workflow requires write permissions for:
- **contents: write** - Updating deployment status and tagging releases
- **id-token: write** - OIDC authentication with AWS IAM roles

These permissions follow the principle of least privilege for the deployment automation use case. The workflow is protected by:
- Branch protection rules on `main`
- Required code review approvals
- AWS IAM role trust policies with specific conditions

**Risk Assessment:** ✅ Low - Permissions are scoped to deployment needs with proper access controls

---

### Semgrep Findings (Static Analysis for Code Patterns)

#### third-party-action-not-pinned-to-commit-sha
**Location:** `.github/workflows/deploy.yml` (lines 30, 38, 47, 55)  
**Suppression:** `# nosemgrep: dockerfile-source-not-pinned` / `# nosemgrep: third-party-action-not-pinned-to-commit-sha`

**Justification:**  
GitHub Actions are pinned to **semantic versioned tags** rather than commit SHAs for the following reasons:

1. **Official AWS Actions:** All flagged actions are from `aws-actions/*` - official AWS-maintained repositories
   - `aws-actions/configure-aws-credentials@v4`
   - `aws-actions/amazon-ecr-login@v2`
   - `aws-actions/amazon-ecs-render-task-definition@v1`
   - `aws-actions/amazon-ecs-deploy-task-definition@v1`

2. **Maintainability:** Semantic versions make it easier to:
   - Understand what version is being used
   - Apply security patches through minor/patch version updates
   - Review release notes and changelogs

3. **Trust Model:** AWS-maintained actions undergo security reviews and are widely trusted in the community

4. **Renovate/Dependabot Support:** Automated dependency updates work better with semantic versions

**Alternative Mitigation:**
- GitHub Actions are monitored for updates through Dependabot/Renovate
- Workflow runs are auditable through GitHub Actions logs
- AWS IAM role trust policies limit the blast radius of potential compromise

**Risk Assessment:** ✅ Low - Using official AWS actions with semantic versioning provides a good balance between security and maintainability

---

#### dockerfile-source-not-pinned (Base Image)
**Location:** `Dockerfile:1`  
**Suppression:** `# nosemgrep: dockerfile-source-not-pinned`

**Justification:**  
The base image uses a specific version tag: `public.ecr.aws/aws-containers/retail-store-sample-ui:1.3.0`

While pinning to SHA256 would provide stronger immutability guarantees, the current approach is acceptable because:
- The image is from an official AWS ECR Public repository
- Version `1.3.0` is explicitly specified (not using `latest`)
- The retail-store-sample is a reference architecture maintained by AWS
- ECR Public provides image scanning and vulnerability reporting

**Future Enhancement:** Consider pinning to SHA256 digest for production deployments:
```dockerfile
FROM public.ecr.aws/aws-containers/retail-store-sample-ui:1.3.0@sha256:<digest>
```

**Risk Assessment:** ⚠️ Medium-Low - Version pinning provides reasonable protection; SHA pinning would be ideal for production

---

## Compliance Notes

All suppressions have been reviewed and documented to ensure:
- ✅ Security controls exist at appropriate layers
- ✅ Suppressions are justified with technical rationale
- ✅ Risk levels are acceptable for the application context
- ✅ Alternative mitigations are in place where applicable

**Last Reviewed:** 2026-01-30  
**Review Frequency:** Quarterly or when new findings are introduced
