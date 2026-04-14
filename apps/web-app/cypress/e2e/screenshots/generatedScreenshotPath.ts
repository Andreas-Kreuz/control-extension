const ROOT_ROUTE_SLUG = 'home';

function safeDecode(value: string) {
  try {
    return decodeURIComponent(value);
  } catch {
    return value;
  }
}

function slugify(value: string) {
  return value
    .normalize('NFKD')
    .replace(/[^\x00-\x7F]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .replace(/-{2,}/g, '-');
}

function routeToSlug(route: string) {
  const decodedRoute = safeDecode(route);
  const segments = decodedRoute
    .split('/')
    .filter(Boolean)
    .map((segment) => segment.replace(/^#+/, ''))
    .map(slugify)
    .filter(Boolean);

  return segments.length > 0 ? segments.join('-') : ROOT_ROUTE_SLUG;
}

export function generatedScreenshotPath(route: string, name: string, viewport?: string) {
  const parts = [routeToSlug(route), slugify(name)];

  if (viewport) {
    parts.push(slugify(viewport));
  }

  return `assets/generated/${parts.join('--')}`;
}
