'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "56829bc4ee854d6882b34987e1b40834",
"version.json": "dcbf6a40295b0deb6ffc0bd18be32085",
"favicon111.png": "5dcef449791fa27946b3d35ad8803796",
"index.html": "f891e3ae0d47426aab5f6de238b55da8",
"/": "f891e3ae0d47426aab5f6de238b55da8",
"main.dart.js": "141dd72ae1630f62dbd8a560b860cf77",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "8a00d4156cd97f7b6d55b06a207ce621",
"icons/Icon-192.png": "8a00d4156cd97f7b6d55b06a207ce621",
"icons/Icon-maskable-192.png": "8a00d4156cd97f7b6d55b06a207ce621",
"icons/Icon-maskable-512.png": "8a00d4156cd97f7b6d55b06a207ce621",
"icons/Icon-512.png": "8a00d4156cd97f7b6d55b06a207ce621",
"manifest.json": "188f121516993bcc120127e6c4d5f5a5",
"assets/NOTICES": "424560a3335e3353f9cd4d33a59417db",
"assets/FontManifest.json": "f20f63904b2d3a198f8e6c5b78655e28",
"assets/AssetManifest.bin.json": "2517fbec179920cb74123ac58d45e456",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "d10e18d03c805f3019463c2ad52f292e",
"assets/fonts/MaterialIcons-Regular.otf": "a074ccce46d11c793f1352fc4e013b54",
"assets/assets/Screenshot%25202025-12-30%2520at%252008.24.37.png": "0d7899f8dc466c0a4fa9b223d37c3df0",
"assets/assets/Screenshot%25202026-01-07%2520at%252010.32.39.png": "0b261919bdb81dcabc28ca593b64f16e",
"assets/assets/flags/gb.svg": "6dcadf6916764560c2f1fec586e2c1de",
"assets/assets/flags/al.svg": "6eef7622cecbab02f24192d8eba30bf7",
"assets/assets/flags/de.svg": "e88d88604d655d0bd7059cf1fbd59ec2",
"assets/assets/flags/sy.svg": "3eb9d0f06233d918805e757d70d66840",
"assets/assets/flags/hr.svg": "5314bd175ad41aa5c42b8e41e2af7173",
"assets/assets/flags/ro.svg": "e9130a28a9ba2b93433f21a2cd5971f3",
"assets/assets/flags/hu.svg": "966f49336f7466efd6f8dbe19f9fc300",
"assets/assets/Screenshot%25202025-12-11%2520at%252010.35.15.png": "1ea7e91eb2ec2afe300c74159447711a",
"assets/assets/icons/cards_star.svg": "4ec34c25cc1c7a193cd1284cd989ddc2",
"assets/assets/Codriver_logo_dark.png": "89f6c6b782e86814d6285b570f5683d3",
"assets/assets/codriver_logo.png": "9ecf1d29e9cdd60b27d6d0ef40f8664d",
"assets/assets/fonts/MaterialSymbolsOutlined.ttf": "c932d43157796cfcfe9aabb25bf0af69",
"assets/assets/Screenshot%25202025-12-30%2520at%252008.26.28.png": "58e3a91dd77eb53928eec6911920b9be",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
