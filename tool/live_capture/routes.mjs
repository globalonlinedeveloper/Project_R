// Route -> SCREEN_MAP mapping for the Ratel design-vs-LIVE capture pipeline.
//
// Source of truth for the numbering:
//   Apps/RATEL/design_conformance/SCREEN_MAP.md  (owner's 68 design shots)
// Source of truth for the routes:
//   lib/app/router.dart  (every GoRoute path, at base main d44476f)
//
// Fields
//   n        filename prefix, aligned to SCREEN_MAP shot numbers ('x-...' = a
//            real route with no numbered design shot).
//   route    the hash route (Flutter web uses hash routing: host/#/<route>).
//   slug     filename slug.
//   label    human label.
//   design   SCREEN_MAP shot number(s) this route corresponds to (for the diff).
//   long     capture extra scrolled frames (screen scrolls beyond one viewport).
//   query    query string appended after the hash route (arg-taking routes).
//   interact tap every labelled button (via the a11y tree) to capture the
//            sheet/dialog/sub-screen each opens (Full-coverage mode).
//   cap      per-screen button cap (default 8; Settings has many rows).
//   sequence {taps:N} — a wizard: tap the primary button N times, shooting each
//            step (onboarding #2-4, placement #5), WITHOUT resetting between.
export const routes = [
  { n: '01', route: '/welcome',       slug: 'welcome',        label: 'Onboarding Welcome',        design: [1] },
  { n: '02', route: '/onboarding',    slug: 'onboarding',     label: 'Onboarding steps',          design: [2, 3, 4], long: true, sequence: { taps: 4 } },
  { n: '05', route: '/placement',     slug: 'placement',      label: 'Onboarding Placement',      design: [5], long: true, sequence: { taps: 3 } },
  { n: '06', route: '/home',          slug: 'home',           label: 'HOME learning path',        design: [6], long: true, interact: true },
  { n: '09', route: '/practice',      slug: 'practice',       label: 'PRACTICE hub',              design: [9, 10], long: true, interact: true },
  { n: '14', route: '/library',       slug: 'library',        label: 'LIBRARY',                   design: [14, 15, 16], long: true, interact: true },
  { n: '17', route: '/tutor',         slug: 'tutor',          label: 'AI TUTOR hub',              design: [17], long: true, interact: true },
  { n: '18', route: '/paywall',       slug: 'paywall',        label: 'Paywall',                   design: [18, 19, 20], query: '?source=direct', long: true, interact: true },
  { n: '21', route: '/roleplay-live', slug: 'talk-live',      label: 'TALK / live roleplay',      design: [21], long: true, interact: true },
  { n: '23', route: '/roleplay',      slug: 'roleplay',       label: 'Roleplay scenes',           design: [23, 24, 25, 26], long: true, interact: true },
  { n: '28', route: '/story',         slug: 'story-reader',   label: 'STORY reader',              design: [28], long: true, interact: true },
  { n: '29', route: '/adventures',    slug: 'adventures',     label: 'ADVENTURES',                design: [29, 30], long: true, interact: true },
  { n: '31', route: '/leagues',       slug: 'leagues',        label: 'LEAGUES',                   design: [31, 32, 33], long: true, interact: true },
  { n: '34', route: '/quests',        slug: 'quests',         label: 'QUESTS',                    design: [34, 35], long: true, interact: true },
  { n: '36', route: '/profile',       slug: 'profile',        label: 'PROFILE',                   design: [36, 37], long: true, interact: true },
  { n: '38', route: '/progress',      slug: 'progress',       label: 'PROGRESS',                  design: [38, 39], long: true, interact: true },
  { n: '40', route: '/friends',       slug: 'friends',        label: 'Friends',                   design: [40, 41, 42], long: true, interact: true },
  { n: '43', route: '/shop',          slug: 'shop',           label: 'SHOP',                      design: [43], long: true, interact: true },
  { n: '44', route: '/notifications', slug: 'notifications',  label: 'Notifications',             design: [44], long: true, interact: true },
  { n: '45', route: '/settings',      slug: 'settings',       label: 'SETTINGS',                  design: [45, 46], long: true, interact: true, cap: 16 },
  { n: '51', route: '/themes',        slug: 'themes',         label: 'THEMES grid (deferred #51-59)', design: [51, 52, 53, 54, 56, 57], long: true },
  { n: '60', route: '/edit-profile',  slug: 'edit-profile',   label: 'Edit profile',              design: [60, 61], long: true, interact: true },

  // --- real routes with no numbered design shot ---
  { n: 'x-login',        route: '/login',         slug: 'login',          label: 'Login',                    design: [] },
  { n: 'x-signup',       route: '/signup',        slug: 'signup',         label: 'Signup',                   design: [] },
  { n: 'x-search',       route: '/search',        slug: 'library-search', label: 'Library search',           design: [42] },
  { n: 'x-stories',      route: '/stories',       slug: 'stories',        label: 'Stories list',             design: [], long: true },
  { n: 'x-podcasts',     route: '/podcasts',      slug: 'podcasts',       label: 'Podcasts list',            design: [], long: true },
  { n: 'x-watch',        route: '/watch',         slug: 'watch',          label: 'Watch list',               design: [], long: true },
  { n: 'x-daily-quiz',   route: '/daily-quiz',    slug: 'daily-quiz',     label: 'Daily quiz / lesson runner', design: [] },

  // --- player/detail routes (need content args; capture whatever renders) ---
  { n: 'x-podcast-arg',   route: '/podcast',       slug: 'podcast-arg',    label: 'Podcast player (no arg)',   design: [] },
  { n: 'x-watch-play',    route: '/watch-play',    slug: 'watch-play',     label: 'Watch player (no arg)',     design: [] },
  { n: 'x-roleplay-play', route: '/roleplay-play', slug: 'roleplay-play',  label: 'Roleplay player (no arg)',  design: [] },
  { n: 'x-adventure',     route: '/adventure',     slug: 'adventure',      label: 'Adventure player (no arg)', design: [] },
];

// Designed screens with NO independent route (documented gaps, per AUDIT.md):
// unbuilt, or living inside a bottom-sheet / sub-screen. Where reachable, the
// interaction layer (tap-through) captures them from their parent screen.
export const unrouted = [
  { design: [7, 8],     label: 'COURSES screen — no /courses route; opens as a Settings switch-sheet (interaction layer taps it)' },
  { design: [11],       label: 'STREAK screen — UNBUILT (top-bar chip only; interaction may open a sheet)' },
  { design: [12],       label: 'ENERGY screen — UNBUILT (top-bar chip only)' },
  { design: [13],       label: 'Diamonds sheet — bottom-sheet from the Home top-bar chip (interaction layer)' },
  { design: [22, 27],   label: 'CHAT tutor — UNBUILT (no /chat route/screen)' },
  { design: [47, 48],   label: 'Subscription / restore — Settings sub-screen (interaction layer)' },
  { design: [49],       label: 'Redeem code — Settings sub-screen/sheet (interaction layer)' },
  { design: [50],       label: 'Invite friends — Settings sub-screen/sheet (interaction layer)' },
  { design: [55, 58, 59], label: 'Theme-applied Home/Profile variants — DEFERRED (themes #51-59)' },
  { design: [62, 63, 64], label: 'Privacy / export / delete — Settings sub-screen (interaction layer)' },
  { design: [65, 66, 67], label: 'Help / contact / community — Settings sub-screen (interaction layer)' },
  { design: [68],       label: 'Settings logout confirm — dialog from the Settings logout button (interaction layer)' },
];
