# Web App Developer Notes

## Start With Vite

Run the web app development server from the repository root:

```bash
yarn workspace @ce/web-app run dev
```

By default, the app connects Socket.IO to the current browser hostname on port `3000`.

## Connect Socket.IO To Another Host

Set `VITE_SOCKET_URL` before starting Vite to point the web app at a different Socket.IO server.

macOS/Linux:

```bash
VITE_SOCKET_URL=http://my-other-host:3000 yarn workspace @ce/web-app run dev
```

Windows PowerShell:

```powershell
$env:VITE_SOCKET_URL="http://my-other-host:3000"
yarn workspace @ce/web-app run dev
```

Windows `cmd.exe`:

```cmd
set VITE_SOCKET_URL=http://my-other-host:3000
yarn workspace @ce/web-app run dev
```

For a persistent local override, create `apps/web-app/.env.local` with:

```env
VITE_SOCKET_URL=http://my-other-host:3000
```
