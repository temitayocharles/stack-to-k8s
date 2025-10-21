# Image Tag Update Playbook 🏷️

Use this checklist whenever you bump container image versions inside the lab manifests.

## 1. Identify what changed

- Note the application module and environment (for example, `weather-app`, lab 01).
- Capture the new tag and the previous tag for rollback reference.
- Confirm the new image is already pushed to the registry accessible by learners.

## 2. Update manifests safely

1. Edit the relevant manifest in `labs/manifests/<lab>/` or the application `k8s/` folder.
2. Change the `image:` field and keep the digest if one is specified.
3. Search for duplicate references (backend, worker, CronJob) to keep tags consistent.

## 3. Validate locally

```bash
# Rebuild and push multi-arch images if required
./scripts/build-multiarch-images.sh --app weather-app --tag v1.3.0

# Re-run the manifest validation suite
./scripts/validate-lab.sh lab-01
```

- Deploy into a disposable namespace (`kubectl create namespace <name>`) and run smoke tests.
- Check pods pull the new image without `ImagePullBackOff` errors.

## 4. Update documentation

- Mention the new tag in the affected lab walkthrough if learners must reference it.
- Record the update and rationale in `labs/manifests/ARCHITECTURE-DECISIONS.md` (section "Image Tag Updates").
- If the change fixes a bug, link to the incident or GitHub issue.

## 5. Submit the change

1. Re-run `./scripts/validate-links.sh <touched-files>` to maintain doc hygiene.
2. Include the validation command output in the PR description.
3. Tag the maintainer for the given application.

## Rollback procedure

- Revert the manifest change.
- Re-deploy the earlier tag across affected workloads.
- Update this playbook entry with the rollback date and reason.

Maintaining clear records of image upgrades keeps the labs reproducible and helps learners trust the instructions.
