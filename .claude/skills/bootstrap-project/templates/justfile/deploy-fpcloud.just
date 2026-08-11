
# ---- deploy (fpcloud) ----

# Context is the repo root: the Dockerfile builds the SPA and bakes it into the same image as
# the API. --provenance/--sbom off and oci-mediatypes=false because the registry rejects
# BuildKit's attestation index and OCI manifests ("manifest invalid").
# Build + push the image.
image-push:
    #!/usr/bin/env bash
    set -euo pipefail
    img="{{registry}}/web"
    # Register the fpcloud credential helper so docker/buildx authenticate using the current
    # login session (auto-refreshing, no static password). Idempotent.
    fpcloud auth configure-docker registry.cloud.fogpipe.com >/dev/null
    echo "building + pushing $img:{{image_tag}} for {{build_platform}}"
    docker buildx build --platform "{{build_platform}}" \
        --provenance=false --sbom=false \
        --output type=image,oci-mediatypes=false,push=true \
        --tag "$img:{{image_tag}}" --tag "$img:latest" \
        --file src/backend/Dockerfile .

# The bucket's owner secret only exists in bootstrap's local state (the platform doesn't
# re-serve it), so it is read from there. Re-run if the bucket key rotates.
# One-time: write the state bucket's creds to the gitignored [{{PROJECT}}-state] AWS profile.
s3-profile:
    #!/usr/bin/env bash
    set -euo pipefail
    b="tofu -chdir=tofu/bootstrap output -raw"
    umask 077
    printf '[{{PROJECT}}-state]\naws_access_key_id = %s\naws_secret_access_key = %s\n' \
        "$($b s3_access_key_id)" "$($b s3_secret_access_key)" > .aws-credentials
    echo "wrote .aws-credentials ([{{PROJECT}}-state])"

# Mint an fpcloud provider token from the current login session when FPCLOUD_API_KEY isn't set.
_fpauth:
    @[ -n "${FPCLOUD_API_KEY:-}" ] && echo "export FPCLOUD_API_KEY=$FPCLOUD_API_KEY" || echo "export FPCLOUD_API_KEY=$(fpcloud get-token | jq -r '.status.token')"

# State layers, each its own module + state. Apply order: bootstrap -> database -> application.
# bootstrap keeps LOCAL state (it creates the bucket the others use as their backend).

# tofu/bootstrap (project + state bucket). Only the provider token is needed.
tf-bootstrap *args:
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(just _fpauth)"
    tofu -chdir=tofu/bootstrap {{args}}
    chmod 600 tofu/bootstrap/terraform.tfstate* 2>/dev/null || true

# tofu/database (managed Postgres). Run `just s3-profile` once before this.
tf-db *args:
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(just _fpauth)"
    tofu -chdir=tofu/database {{args}}

# tofu/application (app + image tag, wired in from the current git sha).
tf-app *args:
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(just _fpauth)"
    export TF_VAR_image_tag="{{image_tag}}"
    tofu -chdir=tofu/application {{args}}

# The release command runs migrations before traffic, so there is no separate migrate step.
# bootstrap + database must already be applied.
# Build + push the image, then apply the application module onto that tag.
deploy: image-push
    @just tf-app init
    @just tf-app apply

cloud-logs *args:
    fpcloud --project {{PROJECT}} app logs web --follow {{args}}
