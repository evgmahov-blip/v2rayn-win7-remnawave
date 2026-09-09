# v2rayN Win7 Remnawave

Portable installer/repair toolkit for **Windows 7 x64** using a Win7-compatible v2rayN GUI and the dedicated **XTLS Xray Win7 core**.

## Current compatibility target

- Windows 7 SP1 x64
- v2rayN **7.16.9** (pinned GUI; community-confirmed as the newest Win7-compatible v2rayN line)
- Xray-core: dedicated asset **`Xray-win7-64.zip`** only
- Remnawave subscriptions / VLESS / REALITY / XHTTP are handled by Xray-core; routing JSON remains an Xray concern

> Important: do **not** replace the core with `Xray-windows-64.zip`. Win7 requires `Xray-win7-64.zip`.

## Install

Download the repository and run `INSTALL.cmd` as Administrator.

The installer:

1. checks Windows 7 x64;
2. enables TLS 1.2 for downloads;
3. downloads pinned v2rayN 7.16.9 SelfContained x64;
4. downloads the newest XTLS release that exposes `Xray-win7-64.zip`;
5. verifies downloaded files by SHA-256 when GitHub exposes a digest;
6. installs to `%LOCALAPPDATA%\v2rayN-Win7-Remnawave` by default;
7. replaces only the Xray core with the Win7 build;
8. verifies `xray.exe version`;
9. creates a Desktop shortcut.

Optional Remnawave subscription URL can be supplied to `INSTALL.cmd` as the first argument. It is saved locally for convenient import and never sent anywhere except to the URL itself by v2rayN when you add/update the subscription.

```cmd
INSTALL.cmd "https://your-subscription.example/path"
```

## Maintenance

- `UPDATE-XRAY.cmd` — update **only** the Win7 Xray core.
- `REPAIR.cmd` — restore the pinned v2rayN build while preserving user data where possible, then reinstall the Win7 Xray core.
- `DIAG.cmd` — print OS, GUI and Xray versions and important paths.

## Why the GUI is pinned

Recent v2rayN builds moved beyond Windows 7 support. The GUI is therefore pinned while the Xray core can be updated independently, provided XTLS still publishes `Xray-win7-64.zip`.

## Security notes

- Downloads come only from official GitHub repositories `2dust/v2rayN` and `XTLS/Xray-core`.
- The updater refuses to silently fall back to the ordinary Windows Xray build.
- Subscription URLs are not committed to this repository.

## Status

Initial implementation. Test on a disposable Windows 7 SP1 x64 VM before wide deployment.
