# Lab 12 · Kubernetes Fundamentals Overlay

This overlay bootstraps the `label-lab` namespace plus a curated set of
manifests that mirror the scenarios in **Lab 12: Kubernetes Fundamentals Deep
Dive**.

## What's Included

- **Broken Frontend/Service pair** – intentionally mismatched labels to debug
- **Multi-Issue deployment** – probes, ports, and resource sizing problems for
	systematic troubleshooting practice
- **Trace Demo** – clean deployment + service used in the resource ownership
	walkthrough
- **Production Pattern** – reference deployment with recommended labels and
	probes
- **Label Challenge** – frontend/backend pairing with mismatched service
	selectors ready for you to correct

Every manifest pins container images to a stable version so static analysis
passes, then the overlay retags them to `:latest` at apply-time (per lab
instructions).

## Usage

```bash
kubectl apply -k labs/manifests/lab-12
```

After experimenting, clean up the namespace:

```bash
kubectl delete namespace label-lab
```

## Extending the Overlay

- Copy the generated YAML to tweak selectors or resource requests as you work
	through the lab exercises.
- To compare broken vs. fixed resources, duplicate the manifest, adjust labels,
	and re-apply.
- Need more scenarios? Add additional YAML under `broken/` or `scenarios/` and
	reference them from `kustomization.yaml`.
