import 'package:dio/dio.dart';

import 'remote_data_source.dart';
import '../models/dtos.dart';

/// A drop-in replacement for [RemoteDataSource] that returns realistic
/// offline data. Swap [remoteDataSourceProvider] to use this in order
/// to run the app without a network connection.
class MockRemoteDataSource extends RemoteDataSource {
  MockRemoteDataSource() : super(dio: Dio()); // Dio unused — all overridden

  static String _mockPhotoUrl(int id) =>
      'https://i.pravatar.cc/256?u=mock-user-$id';

  static DateTime _mockCommentTimestamp(int id) =>
      DateTime.utc(2026, 1, 1).add(Duration(hours: id * 6));

  static Map<int, List<CommentDto>> _withMockCommentTimestamps(
    Map<int, List<CommentDto>> commentsByPost,
  ) {
    return commentsByPost.map(
      (postId, comments) => MapEntry(
        postId,
        comments
            .map(
              (comment) => comment.createdAt != null
                  ? comment
                  : comment.copyWith(
                      createdAt: _mockCommentTimestamp(comment.id),
                    ),
            )
            .toList(),
      ),
    );
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  static final _users = <int, UserDto>{
    1: UserDto.fromJson({
      'id': 1,
      'name': 'Sarah Chen',
      'username': 'sarah_chen',
      'email': 'sarah@techcorpsolutions.io',
      'website': 'techcorpsolutions.io',
      'company': {'name': 'TechCorp Solutions'},
    }).copyWith(photoUrl: _mockPhotoUrl(1)),
    2: UserDto.fromJson({
      'id': 2,
      'name': 'Marcus Johnson',
      'username': 'marcusj',
      'email': 'marcus@johnsondesign.studio',
      'website': 'johnsondesign.studio',
      'company': {'name': 'Johnson Design Studio'},
    }).copyWith(photoUrl: _mockPhotoUrl(2)),
    3: UserDto.fromJson({
      'id': 3,
      'name': 'Priya Patel',
      'username': 'priyap_dev',
      'email': 'priya@cloudnine.dev',
      'website': 'cloudnine.dev',
      'company': {'name': 'CloudNine Technologies'},
    }).copyWith(photoUrl: _mockPhotoUrl(3)),
    4: UserDto.fromJson({
      'id': 4,
      'name': 'Tyler Williams',
      'username': 'twilliams',
      'email': 'tyler@opendev.org',
      'website': 'opendev.org',
      'company': {'name': 'OpenDev Foundation'},
    }).copyWith(photoUrl: _mockPhotoUrl(4)),
    5: UserDto.fromJson({
      'id': 5,
      'name': 'Emma Rodriguez',
      'username': 'emma_r',
      'email': 'emma@pixel8.co',
      'website': 'pixel8.co',
      'company': {'name': 'Pixel8 Creative'},
    }).copyWith(photoUrl: _mockPhotoUrl(5)),
    6: UserDto.fromJson({
      'id': 6,
      'name': 'David Kim',
      'username': 'dkim_dev',
      'email': 'david@koreatechlab.com',
      'website': 'koreatechlab.com',
      'company': {'name': 'Korea Tech Lab'},
    }).copyWith(photoUrl: _mockPhotoUrl(6)),
    7: UserDto.fromJson({
      'id': 7,
      'name': 'Sophia Martinez',
      'username': 'sophiam',
      'email': 'sophia@greenlabs.io',
      'website': 'greenlabs.io',
      'company': {'name': 'GreenLabs Inc'},
    }).copyWith(photoUrl: _mockPhotoUrl(7)),
    8: UserDto.fromJson({
      'id': 8,
      'name': 'James O\'Brien',
      'username': 'jobrien',
      'email': 'james@irishtech.ie',
      'website': 'irishtech.ie',
      'company': {'name': 'Irish Tech Group'},
    }).copyWith(photoUrl: _mockPhotoUrl(8)),
    9: UserDto.fromJson({
      'id': 9,
      'name': 'Aisha Okafor',
      'username': 'aishao',
      'email': 'aisha@afrodigital.ng',
      'website': 'afrodigital.ng',
      'company': {'name': 'AfroDigital Solutions'},
    }).copyWith(photoUrl: _mockPhotoUrl(9)),
    10: UserDto.fromJson({
      'id': 10,
      'name': 'Noah Anderson',
      'username': 'noaha',
      'email': 'noah@northerncode.se',
      'website': 'northerncode.se',
      'company': {'name': 'Northern Code AB'},
    }).copyWith(photoUrl: _mockPhotoUrl(10)),
  };

  // ── Posts ──────────────────────────────────────────────────────────────────

  static final _posts = <PostDto>[
    // Sarah Chen — userId 1
    const PostDto(
      id: 1,
      userId: 1,
      title: 'Why we migrated our entire backend to Rust',
      body: 'After three years running Go microservices we hit a wall with '
          'memory allocations under peak load. This post walks through our '
          'decision criteria, the six-month migration timeline, and the '
          'hard-won lessons from running Rust in production at 40k rps.',
    ),
    const PostDto(
      id: 2,
      userId: 1,
      title: 'Designing APIs that developers actually love',
      body: 'Good API design is 80% empathy and 20% spec. In this piece I '
          'share the five principles my team applies before shipping any '
          'public endpoint — from consistent error shapes to versioning '
          'strategies that don\'t punish early adopters.',
    ),

    // Marcus Johnson — userId 2
    const PostDto(
      id: 3,
      userId: 2,
      title: 'Design systems at scale: lessons from rebuilding ours',
      body: 'Our first design system was a well-intentioned monolith that '
          'collapsed under its own weight. The rebuilt version ships as '
          'composable primitives. Here\'s the architecture, the token '
          'structure, and why we threw away Storybook for something smaller.',
    ),
    const PostDto(
      id: 4,
      userId: 2,
      title: 'Accessible colour: beyond the 4.5:1 ratio',
      body: 'WCAG contrast ratios are a floor, not a ceiling. I\'ve been '
          'testing our palette with users who have low-contrast sensitivity '
          'and the results changed how I think about every colour decision. '
          'Real data, real screenshots, real recommendations.',
    ),

    // Priya Patel — userId 3
    const PostDto(
      id: 5,
      userId: 3,
      title: 'Flutter on the web: a production retrospective',
      body: 'We shipped a Flutter web app to 200k monthly active users. '
          'CanvasKit vs HTML renderer, font loading jank, SEO limitations, '
          'and the sneaky places where Dart isolates saved us — all covered '
          'with real perf traces and bundle-size breakdowns.',
    ),
    const PostDto(
      id: 6,
      userId: 3,
      title: 'State management isn\'t the hard part',
      body: 'Everyone argues about Riverpod vs Bloc vs Provider, but the '
          'real challenge is deciding where state *lives*. Server state, '
          'UI state, navigation state, and form state each have different '
          'lifetimes and ownership models. Let\'s talk about those instead.',
    ),

    // Tyler Williams — userId 4
    const PostDto(
      id: 7,
      userId: 4,
      title: 'Open source sustainability: what actually works',
      body: 'I\'ve maintained three open-source libraries for six years. '
          'GitHub Sponsors, OpenCollective, dual-licensing, and paid support '
          'tiers — I\'ve tried them all. Here\'s an honest breakdown of '
          'what generated revenue and what generated noise.',
    ),
    const PostDto(
      id: 8,
      userId: 4,
      title: 'Writing documentation that gets read',
      body: 'Most docs fail because they\'re written for the author, not '
          'the reader. The Divio documentation system changed everything for '
          'me: tutorials, how-to guides, reference, and explanation are '
          'four fundamentally different types of content. Mixing them '
          'guarantees confusion.',
    ),

    // Emma Rodriguez — userId 5
    const PostDto(
      id: 9,
      userId: 5,
      title: 'Motion design principles for mobile apps',
      body: 'Animation should reduce cognitive load, not add to it. '
          'I break down the twelve principles of animation and how each '
          'applies specifically to mobile UI — with side-by-side examples '
          'of the same transition done poorly and done well.',
    ),
    const PostDto(
      id: 10,
      userId: 5,
      title: 'Figma variables vs design tokens: which should you use?',
      body: 'Figma variables solve a real problem but they\'re not the '
          'same thing as design tokens. If you\'re syncing with a codebase '
          'you need to understand the difference before you build your '
          'variable structure, or you\'ll be doing painful rework in six months.',
    ),

    // David Kim — userId 6
    const PostDto(
      id: 11,
      userId: 6,
      title: 'Zero-downtime database migrations in practice',
      body: 'The gap between theory and reality in database migrations is '
          'enormous. Expand-contract pattern, shadow tables, feature flags '
          'tied to migration phases — this is a step-by-step guide to '
          'deploying schema changes to a live Postgres database without '
          'touching a maintenance window.',
    ),
    const PostDto(
      id: 12,
      userId: 6,
      title: 'Observability is not monitoring',
      body: 'Dashboards show you what you expected to go wrong. '
          'Observability lets you debug what you didn\'t expect. Structured '
          'logs, distributed traces, and the three pillars — but also the '
          'fourth pillar nobody talks about: continuous profiling.',
    ),

    // Sophia Martinez — userId 7
    const PostDto(
      id: 13,
      userId: 7,
      title: 'Building a carbon-aware CI/CD pipeline',
      body: 'Our builds run in regions with the lowest grid carbon intensity '
          'at the time of execution. It sounds complicated but the '
          'implementation is under 200 lines of Go and a cron job. '
          'Here\'s exactly how we did it and the emissions data from year one.',
    ),
    const PostDto(
      id: 14,
      userId: 7,
      title: 'Developer experience as a product',
      body: 'Internal tooling has users too. When we started running '
          'usability studies on our internal developer platform, fix time '
          'dropped 40% in a quarter. Here\'s how to apply product thinking '
          'to the tools your own engineers use every day.',
    ),

    // James O'Brien — userId 8
    const PostDto(
      id: 15,
      userId: 8,
      title: 'The hidden cost of premature abstraction',
      body: 'Every senior engineer has a graveyard of abstractions that '
          'seemed clever at the time. I spent six months extracting a '
          '\"reusable\" data-fetching layer that the team promptly worked '
          'around. This is the story of what went wrong and what I do now.',
    ),
    const PostDto(
      id: 16,
      userId: 8,
      title: 'Code review culture: feedback without friction',
      body: 'A pull request is a conversation, not an audit. We changed '
          'three things — review SLAs, a comment taxonomy (nit / blocker / '
          'question), and async video walkthroughs for complex diffs — and '
          'our review cycle time halved within two sprints.',
    ),

    // Aisha Okafor — userId 9
    const PostDto(
      id: 17,
      userId: 9,
      title: 'Localisation beyond translation',
      body: 'Translating strings is the easy part. Date formats, number '
          'separators, RTL layouts, culturally inappropriate icons, and '
          'payment methods that only exist in one country — real '
          'localisation is a product problem, not a string-replacement job.',
    ),
    const PostDto(
      id: 18,
      userId: 9,
      title: 'Building for low-bandwidth users',
      body: 'Half the world\'s new internet users are coming online via '
          'a mobile connection that averages under 5 Mbps. Aggressive '
          'image compression, service workers, skeleton screens, and '
          'offline-first architecture aren\'t nice-to-haves — they\'re '
          'table stakes if your market includes emerging economies.',
    ),

    // Noah Anderson — userId 10
    const PostDto(
      id: 19,
      userId: 10,
      title: 'Why we chose boring technology',
      body: 'Our stack is PostgreSQL, Redis, and plain old HTTP APIs. '
          'No Kafka, no GraphQL federation, no service mesh. The '
          'competitive advantage isn\'t the technology — it\'s the '
          'headspace we freed up by not running distributed systems we '
          'didn\'t need yet.',
    ),
    const PostDto(
      id: 20,
      userId: 10,
      title: 'Async-first communication changed how we work',
      body: 'We went fully remote and fully async eighteen months ago. '
          'Meeting count dropped 70%. Written communication improved '
          'dramatically because people had to think before they typed. '
          'Here\'s the system: norms, tools, and the one meeting we kept.',
    ),
  ];

  // ── Comments ───────────────────────────────────────────────────────────────

  static final _comments = _withMockCommentTimestamps(<int, List<CommentDto>>{
    1: const [
      CommentDto(
          id: 1,
          postId: 1,
          name: 'Liam Torres',
          email: 'liam.torres@devmail.io',
          body:
              'The section on borrow checker friction during the migration was eye-opening. We hit the exact same wall on our audio pipeline rewrite.'),
      CommentDto(
          id: 2,
          postId: 1,
          name: 'Chloe Nakamura',
          email: 'chloe.n@systemsio.com',
          body:
              'Would love to see a follow-up on how you handle async runtimes. Tokio vs async-std is still something our team debates every six months.'),
    ],
    2: const [
      CommentDto(
          id: 3,
          postId: 2,
          name: 'Ben Osei',
          email: 'ben.osei@apicraft.dev',
          body:
              'The "error shapes" point is so underrated. We standardised on RFC 7807 Problem Details last year and onboarding time for new integrators dropped noticeably.'),
      CommentDto(
          id: 4,
          postId: 2,
          name: 'Fatima Al-Hassan',
          email: 'fatima@backendcafe.net',
          body:
              'Versioning via the Accept header vs URL paths debate could be its own article. URI versioning wins for discoverability every time IMO.'),
    ],
    3: const [
      CommentDto(
          id: 5,
          postId: 3,
          name: 'Raj Iyer',
          email: 'raj.iyer@uxnotes.co',
          body:
              'Composable primitives are the way. We made the same mistake shipping a monolith the first time. Atomic design helped us restructure, though we ended up with something closer to your token-first approach.'),
      CommentDto(
          id: 6,
          postId: 3,
          name: 'Grace Liu',
          email: 'grace.liu@designops.io',
          body:
              'Curious what you replaced Storybook with. We\'ve been looking at Histoire for Vue and Ladle for React — neither feels quite right.'),
    ],
    4: const [
      CommentDto(
          id: 7,
          postId: 4,
          name: 'Omar Farooq',
          email: 'ofarooq@a11yhub.org',
          body:
              'The APCA model (Accessible Perceptual Contrast Algorithm) blew my mind when I first encountered it. It handles large text, thin fonts, and dark mode way better than the old algorithm.'),
      CommentDto(
          id: 8,
          postId: 4,
          name: 'Ingrid Holm',
          email: 'ingrid.h@nordic.design',
          body:
              'Real user testing data is so rare in these conversations. The screenshot diffs between what you and a low-vision user see are genuinely shocking.'),
    ],
    5: const [
      CommentDto(
          id: 9,
          postId: 5,
          name: 'Carlos Mendes',
          email: 'carlos.m@flutterforum.dev',
          body:
              'The CanvasKit font loading issue bit us hard in production. Our LCP was awful until we preloaded the font subset. Have you experimented with the new impeller renderer?'),
      CommentDto(
          id: 10,
          postId: 5,
          name: 'Yuki Tanaka',
          email: 'yuki.t@mobilecraft.jp',
          body:
              'Interesting to see the bundle size numbers. We found skia.wasm to be the main culprit and ended up using the HTML renderer for first load with a CanvasKit upgrade on subsequent visits.'),
    ],
    6: const [
      CommentDto(
          id: 11,
          postId: 6,
          name: 'Aaliya Singh',
          email: 'aaliya.s@dartweekly.com',
          body:
              'Server state vs UI state is such a clean framing. The confusion usually starts when people try to cache server responses in "UI state" and suddenly everything is stale.'),
      CommentDto(
          id: 12,
          postId: 6,
          name: 'Pedro Alves',
          email: 'pedro.alves@riverpodpro.br',
          body:
              'This resonates. I\'ve seen teams spend weeks arguing Bloc vs Riverpod while completely ignoring that their data flow has five different sources of truth.'),
    ],
    7: const [
      CommentDto(
          id: 13,
          postId: 7,
          name: 'Nina Schulz',
          email: 'nina.s@opensourcefunding.eu',
          body:
              'The GitHub Sponsors honesty is refreshing. Most posts on this topic oversell it. Our experience matched yours — steady but modest income, better for relationship-building than revenue.'),
      CommentDto(
          id: 14,
          postId: 7,
          name: 'Kofi Asante',
          email: 'kofi.a@oss.africa',
          body:
              'Paid support tiers are underexplored. Would be curious what your SLA looked like and how you avoided it becoming a second full-time job.'),
    ],
    8: const [
      CommentDto(
          id: 15,
          postId: 8,
          name: 'Elena Petrov',
          email: 'elena.p@docscraft.io',
          body:
              'The Divio system reframed how our whole team thinks about writing. We now have separate templates for each quadrant and it\'s dramatically reduced the "is this a tutorial or a reference?" debates.'),
      CommentDto(
          id: 16,
          postId: 8,
          name: 'Arjun Nair',
          email: 'arjun.n@devxp.in',
          body:
              'The biggest unlock for us was realising that most docs failures are actually *process* failures — no one owns keeping them current after shipping.'),
    ],
    9: const [
      CommentDto(
          id: 17,
          postId: 9,
          name: 'Mei Ling',
          email: 'mei.ling@animationstudio.hk',
          body:
              'The "anticipation" principle is the one most mobile devs skip. That tiny spring before a card lifts is what makes interactions feel physical vs mechanical.'),
      CommentDto(
          id: 18,
          postId: 9,
          name: 'Sam Obuya',
          email: 'sam.obuya@mobileux.ke',
          body:
              'The side-by-side examples are what made this click for me. I\'ve tried explaining this in code reviews for years and a GIF pair is worth ten paragraphs.'),
    ],
    10: const [
      CommentDto(
          id: 19,
          postId: 10,
          name: 'Tara Brennan',
          email: 'tara.b@designtokens.ie',
          body:
              'The namespace collision problem between Figma variables and W3C design tokens is real. We ended up using a custom transformer in Style Dictionary to bridge the gap.'),
      CommentDto(
          id: 20,
          postId: 10,
          name: 'Hamid Rahimi',
          email: 'hamid.r@codedesign.dev',
          body:
              'This saved us from a painful rebuild. We\'d already started nesting Figma variables in a way that mapped cleanly to Figma but broke our token pipeline entirely.'),
    ],
    11: const [
      CommentDto(
          id: 21,
          postId: 11,
          name: 'Jessica Park',
          email: 'jpark@dbweekly.com',
          body:
              'The expand-contract breakdown is the clearest explanation I\'ve read. The thing people miss is that the "contract" phase has to wait until you\'re confident the old column has zero readers.'),
      CommentDto(
          id: 22,
          postId: 11,
          name: 'Tobias Werner',
          email: 'tobias.w@postgres.berlin',
          body:
              'Excellent write-up. One addition: logical replication slots for zero-downtime cutovers if you\'re switching primary. Learned that the hard way during a 30M row migration.'),
    ],
    12: const [
      CommentDto(
          id: 23,
          postId: 12,
          name: 'Nadia Volkov',
          email: 'nadia.v@observability.ru',
          body:
              'Continuous profiling deserves way more attention. Parca and Pyroscope have matured a lot. Being able to correlate a trace spike with a hot code path on the same timeline is a game changer.'),
      CommentDto(
          id: 24,
          postId: 12,
          name: 'Chris Adebayo',
          email: 'chris.a@infra.ng',
          body:
              'The "dashboards show what you expected" framing is going straight into our next oncall training session.'),
    ],
    13: const [
      CommentDto(
          id: 25,
          postId: 13,
          name: 'Elsa Björk',
          email: 'elsa.b@greengrid.se',
          body:
              'The Electricity Maps API integration is something we\'ve been evaluating too. Did you account for the embodied carbon of spinning up instances in greener regions vs the network latency penalty?'),
      CommentDto(
          id: 26,
          postId: 13,
          name: 'Mo Farhan',
          email: 'mo.farhan@carbonneutral.dev',
          body:
              'Love seeing sustainability thinking applied at the pipeline level, not just infra procurement. The 200-line implementation claim is bold — would you consider open-sourcing it?'),
    ],
    14: const [
      CommentDto(
          id: 27,
          postId: 14,
          name: 'Lily Chow',
          email: 'lily.c@platform.eng',
          body:
              'The usability study angle is something most platform teams never consider. We started embedding a TPM in our internal tools team and the qualitative signal we get now is incomparable to ticket volume alone.'),
      CommentDto(
          id: 28,
          postId: 14,
          name: 'Rafi Cohen',
          email: 'rafi.c@developerplatform.il',
          body:
              'The 40% fix-time reduction is a striking result. I\'d be curious whether that persisted past the first quarter or if it was partially a Hawthorne effect from the attention the team was getting.'),
    ],
    15: const [
      CommentDto(
          id: 29,
          postId: 15,
          name: 'Anna Müller',
          email: 'anna.m@softwarecraft.de',
          body:
              'The "abstraction that the team worked around" pattern is so common and so painful to watch happen. The worst part is that the workarounds themselves become load-bearing over time.'),
      CommentDto(
          id: 30,
          postId: 15,
          name: 'Leon Dubois',
          email: 'leon.d@pragmatic.fr',
          body:
              '"Clever at the time" is doing a lot of work in this post and I mean that as a compliment — honest post-mortems on our own decisions are rare.'),
    ],
    16: const [
      CommentDto(
          id: 31,
          postId: 16,
          name: 'Miriam Cohen',
          email: 'miriam.c@teamdynamics.com',
          body:
              'The nit/blocker/question taxonomy is something we independently arrived at too. Huge reduction in authors getting defensive when every comment has a clear weight attached.'),
      CommentDto(
          id: 32,
          postId: 16,
          name: 'Jack Sullivan',
          email: 'jack.s@eng.ie',
          body:
              'Async video walkthroughs for complex PRs — this is the one thing on your list we haven\'t tried. Any particular tool, or just Loom?'),
    ],
    17: const [
      CommentDto(
          id: 33,
          postId: 17,
          name: 'Amara Diallo',
          email: 'amara.d@i18n.africa',
          body:
              'The payment methods point can\'t be overstated. M-Pesa integration took our East Africa conversion rate from ~2% to ~28%. It\'s not an edge case when it\'s the dominant payment rail.'),
      CommentDto(
          id: 34,
          postId: 17,
          name: 'Zeynep Yıldız',
          email: 'zeynep.y@localise.dev',
          body:
              'RTL layouts feel like an afterthought in most frameworks and they are. We\'ve started auditing RTL support in every third-party library before adoption — it\'s saved so many late-stage surprises.'),
    ],
    18: const [
      CommentDto(
          id: 35,
          postId: 18,
          name: 'Kwame Asare',
          email: 'kwame.a@mobileafrica.org',
          body:
              'The service worker + offline-first framing is exactly right. We\'ve seen 3x retention improvements in markets with intermittent connectivity when we handle offline gracefully versus showing an error screen.'),
      CommentDto(
          id: 36,
          postId: 18,
          name: 'Sofia Papadopoulos',
          email: 'sofia.p@performance.gr',
          body:
              'Skeleton screens get overlooked as a low-bandwidth optimisation, but the perceived performance improvement in slow network conditions is significant even when actual load time is unchanged.'),
    ],
    19: const [
      CommentDto(
          id: 37,
          postId: 19,
          name: 'Max Lindqvist',
          email: 'max.l@simplicity.se',
          body:
              '"Headspace freed up by not running distributed systems we didn\'t need yet" is something I\'m quoting at our next architecture review. We\'ve been eyeing Kafka for a use case that cron + Postgres handles perfectly well.'),
      CommentDto(
          id: 38,
          postId: 19,
          name: 'Hannah Brooks',
          email: 'hannah.b@boringness.dev',
          body:
              'The constraint of boring tech also makes hiring easier. You can interview for fundamental skills instead of specific framework knowledge, and onboarding is measurably faster.'),
    ],
    20: const [
      CommentDto(
          id: 39,
          postId: 20,
          name: 'Olu Adeyemi',
          email: 'olu.a@remote.ng',
          body:
              'The "written communication improved because people had to think before typing" point is the one I quote most when making the async case to leadership. Forcing clarity up front reduces downstream misalignment.'),
      CommentDto(
          id: 40,
          postId: 20,
          name: 'Clara Rossi',
          email: 'clara.r@asyncfirst.it',
          body:
              'Would love to know which single meeting you kept. My guess is a weekly whole-team ritual of some kind. For us it\'s a 25-minute Friday retro and nothing else.'),
    ],
  });

  // ── Overrides ──────────────────────────────────────────────────────────────

  @override
  Future<List<PostDto>> fetchPosts() async => _posts;

  @override
  Future<PostDto> fetchPost(int id) async {
    return _posts.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Post $id not found'),
    );
  }

  @override
  Future<List<PostDto>> fetchPostsByUser(int userId) async =>
      _posts.where((p) => p.userId == userId).toList();

  @override
  Future<List<CommentDto>> fetchComments(int postId) async =>
      _comments[postId] ?? [];

  @override
  Future<CommentDto> createComment({
    required int postId,
    required String name,
    required String email,
    required String body,
    required DateTime createdAt,
  }) async {
    final allComments = _comments.values.expand((comments) => comments);
    final newId = allComments.fold<int>(
          0,
          (maxId, comment) => comment.id > maxId ? comment.id : maxId,
        ) +
        1;
    final comment = CommentDto(
      id: newId,
      postId: postId,
      name: name,
      email: email,
      body: body,
      createdAt: createdAt,
    );
    final existing = _comments[postId] ?? const <CommentDto>[];
    _comments[postId] = [...existing, comment];
    return comment;
  }

  @override
  Future<UserDto> fetchUser(int id) async {
    final user = _users[id];
    if (user == null) throw Exception('User $id not found');
    return user;
  }

  @override
  Future<UserDto> ensureGoogleUser({
    required String googleId,
    required String email,
    String? name,
    String? photoUrl,
  }) async {
    for (final entry in _users.entries) {
      final user = entry.value;
      if (user.googleId == googleId || user.email == email) {
        final updated = UserDto(
          id: user.id,
          name: name?.trim().isNotEmpty == true ? name!.trim() : user.name,
          username: user.username,
          email: user.email,
          website: user.website,
          companyName: user.companyName,
          googleId: googleId,
          photoUrl: photoUrl ?? user.photoUrl,
        );
        _users[entry.key] = updated;
        return updated;
      }
    }

    final newId =
        (_users.keys.fold<int>(0, (maxId, id) => id > maxId ? id : maxId)) + 1;
    final created = UserDto.fromGoogleAccount(
      id: newId,
      googleId: googleId,
      email: email,
      name: name,
      photoUrl: photoUrl,
    );
    _users[newId] = created;
    return created;
  }
}
