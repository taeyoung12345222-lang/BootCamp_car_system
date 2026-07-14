// Service Worker for caroom PWA
const CACHE_NAME = 'caroom-v1';
const ASSETS = [
  '/',
  '/car-system.html',
  '/manifest.json',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2'
];

// 설치 이벤트
self.addEventListener('install', event => {
  console.log('🔧 Service Worker 설치 중...');
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      console.log('📦 캐시에 자산 저장 중...');
      return cache.addAll(ASSETS).catch(err => {
        console.log('⚠️ 일부 자산 캐싱 실패:', err);
      });
    })
  );
  self.skipWaiting();
});

// 활성화 이벤트
self.addEventListener('activate', event => {
  console.log('✅ Service Worker 활성화됨');
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('🗑️  이전 캐시 삭제:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Fetch 이벤트 - 네트워크 우선, 실패 시 캐시에서 직업
self.addEventListener('fetch', event => {
  // Supabase API 요청은 항상 네트워크 사용
  if (event.request.url.includes('supabase')) {
    event.respondWith(
      fetch(event.request)
        .catch(() => caches.match(event.request))
    );
    return;
  }

  // 기타 요청 - 네트워크 우선
  event.respondWith(
    fetch(event.request)
      .then(response => {
        // 성공 응답 캐싱
        if (response && response.status === 200 && response.type === 'basic') {
          const responseToCache = response.clone();
          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, responseToCache);
          });
        }
        return response;
      })
      .catch(() => {
        // 네트워크 실패 시 캐시에서 반환
        return caches.match(event.request).then(response => {
          return response || new Response('오프라인 상태입니다. 인터넷 연결을 확인해주세요.', {
            status: 503,
            statusText: 'Service Unavailable',
            headers: new Headers({
              'Content-Type': 'text/plain'
            })
          });
        });
      })
  );
});

// 백그라운드 동기화 (선택)
self.addEventListener('sync', event => {
  if (event.tag === 'sync-reservations') {
    event.waitUntil(syncReservations());
  }
});

async function syncReservations() {
  try {
    console.log('🔄 예약 동기화 중...');
    // 동기화 로직 구현
  } catch (error) {
    console.error('❌ 동기화 실패:', error);
  }
}

// 푸시 알림 (선택)
self.addEventListener('push', event => {
  const data = event.data ? event.data.json() : {};
  const title = data.title || 'caroom 알림';
  const options = {
    body: data.body || '새로운 알림이 있습니다.',
    icon: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192"><rect fill="%231e3c72" width="192" height="192"/><text x="50%" y="50%" font-size="80" font-weight="bold" fill="%23ffffff" text-anchor="middle" dominant-baseline="central" font-family="Arial">🚗</text></svg>',
    badge: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96"><circle cx="48" cy="48" r="48" fill="%231e3c72"/></svg>',
    tag: 'caroom-notification',
    requireInteraction: false
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

// 알림 클릭 이벤트
self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window' }).then(clientList => {
      for (let client of clientList) {
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});

console.log('✅ caroom Service Worker 로드됨');
