// Public, stateless RoleMint. Private administration is never proxied.
const ORIGIN = 'https://rolemint.137.23.55.229.sslip.io';
export default {
  async fetch(request) {
    const incoming = new URL(request.url);
    const target = new URL(ORIGIN);
    target.pathname = "/public" + incoming.pathname;
    target.search = incoming.search;
    const headers = new Headers(request.headers);
    headers.delete('host');
    headers.delete('authorization');
    headers.delete('x-forwarded-host');
    if (headers.get('origin') === incoming.origin) headers.set('origin', ORIGIN);
    headers.set('x-forwarded-proto', 'https');
    try {
      const upstream = await fetch(new Request(target, {
        method: request.method,
        headers,
        body: ['GET', 'HEAD'].includes(request.method) ? undefined : request.body,
        redirect: 'manual'
      }), { cf: { cacheTtl: 0, cacheEverything: false } });
      const response = new Response(upstream.body, upstream);
      response.headers.set('Cache-Control', 'private, no-store');
      response.headers.delete('CDN-Cache-Control');
      response.headers.delete('Cloudflare-CDN-Cache-Control');
      const location = response.headers.get('Location');
      if (location) {
        const redirect = new URL(location, ORIGIN);
        if (redirect.origin === ORIGIN) {
          response.headers.set('Location', incoming.origin + (redirect.pathname.replace(/^\/public(?=\/|$)/, "") || "/") + redirect.search + redirect.hash);
        }
      }
      return response;
    } catch {
      return new Response('RoleMint is temporarily unavailable. Please try again shortly.', {
        status: 502, headers: { 'Content-Type': 'text/plain; charset=utf-8', 'Cache-Control': 'no-store' }
      });
    }
  }
};
