# RoleMint public address

The Cloudflare Worker at https://rolemint.wluk.workers.dev proxies the existing HTTPS Oracle deployment. It forwards the visitor's existing Basic authentication; no password or API key is embedded in the Worker. Private responses are never cached.

Cloudflare Builds uses this directory as the root, with `npx wrangler deploy`. The app, PDF renderer, database, and persistent volume remain on Oracle. No paid Workers plan is required for this small proxy within free plan limits.
