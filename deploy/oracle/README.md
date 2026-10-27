# RoleMint on Oracle Cloud

Deployment preparation for the full Resume Matcher application. This is not
a static frontend or a tunnel to a desktop. Both application processes, PDF
rendering and database storage run on the Oracle VM.

## Files

- compose.yaml: pinned upstream application image and a Caddy HTTPS gateway.
- Caddyfile: password protection for every page and API route.
- install.sh: install Docker if absent, generate local credentials, and start
  services. Existing credentials and resume data are preserved on reruns.

The application image was verified to support both linux/amd64 and linux/arm64.
Use an existing Always Free-eligible VM. Confirm its actual available memory,
storage, shape and current tenancy allowance before creating resources.
An Ubuntu VM with enough memory for the application and Chromium is preferred.

## Deploy after VM access is available

Point a hostname to the VM's public IP. A domain you already own works; a DNS
service such as sslip.io can also provide a hostname without buying a domain.

    git clone https://github.com/shaswatshukla/rolemint.git
    cd rolemint/deploy/oracle
    sudo bash install.sh rolemint.YOUR-PUBLIC-IP.sslip.io

Replace YOUR-PUBLIC-IP with the VM address. No password or API key goes into Git.

Permit inbound TCP 80 and 443 on the relevant Oracle VCN rules and the VM
firewall. Keep SSH limited to the administration source IP. Port 3000 is private
to the Docker network. Caddy obtains and renews the TLS certificate automatically.

The initial username is shaswat. The generated password is stored on the VM
in /opt/rolemint/credentials.txt with root-only access.

## Data and operation

Resume data and encrypted provider settings live in a named Docker volume,
independent of a container restart. Caddy certificate data also persists.

    cd /opt/rolemint
    sudo docker compose ps
    sudo docker compose logs --tail=100
    sudo docker compose stop
    sudo docker compose up -d

Do not use docker compose down --volumes: that deletes stored resumes.
Back up the resume-data volume while the application is stopped; retain the
whole volume, including the encryption secret needed for stored provider keys.

AI starts in Coding agent mode, so the app makes no paid model API calls.
For generation directly in the website, select a provider and supply your own
key in Settings. Signing in with ChatGPT through the loopback-only upstream
flow is not configured for this remote deployment.

## Live deployment

Live URL: https://rolemint.137.23.55.229.sslip.io

Deployed on 27 October 2026 in the Mumbai home region, using an Always Free-eligible
VM.Standard.E2.1.Micro instance with 1 GB RAM and 4 GB swap. A1 provisioning was
unavailable because of regional capacity. The initial boot volume is within the
200 GB home-region free allowance; no paid account upgrade was performed.

Verified: trusted public HTTPS, HTTP-to-HTTPS redirect, login protection, authenticated
API health, resume creation and retrieval, and text-based PDF export. Saved data
survived an application-container restart. The temporary test resume was deleted.
The website remained healthy with the desktop app stopped. Login credentials stay
on the VM in /opt/rolemint/credentials.txt and are never committed to this repository.

The Python PDF renderer uses the private internal frontend URL so it can render
without passing through the public gateway's login prompt.
RoleMint is the deployment name. The underlying app retains upstream Resume
Matcher branding and its Apache-2.0 attribution. The pinned upstream image does
not include local source edits until a custom application image is built.
