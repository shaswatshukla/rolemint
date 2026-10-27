# RoleMint public address

https://rolemint.wluk.workers.dev serves the anonymous, stateless public application on Oracle. Only /public-prefixed Oracle routes are proxied; private dashboard and shared configuration endpoints are not exposed through this address. Incoming Basic authorization is dropped. No shared AI key is stored. Each visitor supplies a key and explicitly agrees to send their resume and job description to their chosen provider. Responses are never cached.

Cloudflare Builds uses /deploy/cloudflare as its root and npx wrangler deploy. The Oracle compose configuration runs the public API separately without mounting the private database.
