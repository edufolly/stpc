'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"/manifest.json": "42903caad27563e7c959ed923af05c93",
"/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"/assets/AssetManifest.json": "6697f9d3eac6f1e2943c5251d487f3e0",
"/assets/LICENSE": "d114bb591d9d3b37dc0fc50dde41c36b",
"/assets/assets/logo-small.png": "ac41d0cc2a13fdca0ccc2689f36dec52",
"/assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"/assets/FontManifest.json": "580ff1a5d08679ded8fcf5c6848cece7",
"/main.dart.js": "0a2e529e73051f6d7ebb3258387937e2",
"/index.html": "5b6376f8c82f3d36f2eac79d69708329"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
