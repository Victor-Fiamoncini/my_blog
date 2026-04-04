import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// ─── Configuration ────────────────────────────────────────────────────────────

const BASE_URL = __ENV.BASE_URL || 'http://localhost';

const PROB_VISIT_INDEX = 0.70;  // 70% of users browse the index
const PROB_INDEX_PAGE1 = 0.80;  // 80% of index visitors land on page 1

const THINK_TIME_MIN_S = 0.5;
const THINK_TIME_MAX_S = 2.5;

const DEFAULT_SLUGS = ['my-published-post'];

// ─── Custom metrics ───────────────────────────────────────────────────────────

const errorRate    = new Rate('errors');
const indexTrend   = new Trend('index_page_duration');
const postTrend    = new Trend('post_page_duration');

// ─── Load stages ──────────────────────────────────────────────────────────────
// Ramp up gradually so SQLite/Puma have time to warm up, then push hard.

export const options = {
  stages: [
    { duration: '30s', target: 10  },  // warm-up
    { duration: '1m',  target: 10  },  // baseline
    { duration: '30s', target: 50  },  // ramp
    { duration: '1m',  target: 50  },  // mid load
    { duration: '30s', target: 100 },  // push
    { duration: '1m',  target: 100 },  // peak load
    { duration: '30s', target: 200 },  // stress
    { duration: '1m',  target: 200 },  // max stress
    { duration: '30s', target: 0   },  // cool-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000', 'p(99)<2000'],  // SLA: p95 < 1s, p99 < 2s
    errors:            ['rate<0.01'],                  // < 1% error rate
    http_req_failed:   ['rate<0.01'],
  },
};

// ─── Scenarios ────────────────────────────────────────────────────────────────

function visitIndex() {
  const page = Math.random() < PROB_INDEX_PAGE1 ? 1 : 2;
  const url  = page === 1 ? `${BASE_URL}/` : `${BASE_URL}/?page=${page}`;
  const res  = http.get(url, { tags: { name: 'index' } });

  indexTrend.add(res.timings.duration);
  errorRate.add(res.status !== 200);

  check(res, {
    'index: status 200':        r => r.status === 200,
    'index: has posts content': r => r.body && r.body.length > 0,
  });
}

function visitPost() {
  const slugs = __ENV.POST_SLUGS
    ? __ENV.POST_SLUGS.split(',').map(s => s.trim()).filter(Boolean)
    : DEFAULT_SLUGS;

  const slug = slugs[Math.floor(Math.random() * slugs.length)];
  const res  = http.get(`${BASE_URL}/posts/${slug}`, { tags: { name: 'post_show' } });

  postTrend.add(res.timings.duration);
  errorRate.add(res.status !== 200);

  check(res, {
    'post: status 200':       r => r.status === 200,
    'post: has article body': r => r.body && r.body.length > 0,
  });
}

// ─── Main ─────────────────────────────────────────────────────────────────────
// Simulates a realistic read-only blog visitor:
//   70% → browse index (paginated)
//   30% → read a specific post

export default function () {
  if (Math.random() < PROB_VISIT_INDEX) {
    visitIndex();
  } else {
    visitPost();
  }

  sleep(Math.random() * (THINK_TIME_MAX_S - THINK_TIME_MIN_S) + THINK_TIME_MIN_S);
}
