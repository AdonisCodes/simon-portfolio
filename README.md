# Base
Automa's Base Repository used for everything!

# Setup

Run the following commands to setup the base of this REPO:
```bash
git clone --recurse-submodules --remote-submodules https://github.com/GetAutomaApp/Base.git
cd Base
npm run install:all
```

> [!NOTE]
> This is a template repo, add any other initialization steps here please!

> [!WARNING]
> This REPO uses the GPL-3.0 license, this license only applies if you modify this template and intend to use this as a template repo!
> If this repo is applied as a new project, feel free to close source it!

# Universal Links (AutoZone)

This site serves the Apple App Site Association file for the AutoZone workout
app (`J9GLPBP73D.com.adoniscodes.zonerun`) and a browser fallback page at `/w`
for shared workout links (`/w?d=<base64url JSON payload>`).

Verify after a deploy:

```bash
# Both must return HTTP 200 (no redirect) with Content-Type: application/json
curl -I https://simonferns.com/.well-known/apple-app-site-association
curl -I https://simonferns.com/apple-app-site-association

# Or run all checks at once (also checks /w):
scripts/check-universal-links.sh

# Check what Apple's CDN sees (this is what devices actually use):
curl https://app-site-association.cdn-apple.com/a/v1/simonferns.com
```
