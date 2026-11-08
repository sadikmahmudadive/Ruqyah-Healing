# Courses and Learn Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the single course screen into a free **Learn** side and a paid **Courses** side (10-second preview, mocked purchase, certificate for courses only) behind one bottom-nav tab, and redesign both plus their detail, player, quiz and certificate screens.

**Architecture:** `LearnTab` becomes a thin shell holding a Learn/Courses switch and one shared category row; free and paid logic live in separate views, models and services so a free lesson can never reach a paywall or certificate. Content comes through an injectable `LearnContentSource` (Firestore with built-in sample fallback); unlock state through an injectable `CourseAccessService` (mocked purchase). Real video via `video_player`, with the 10-second limit in a pure, testable `PreviewLimiter`.

**Tech Stack:** Flutter/Dart (Material 3), `video_player`, `cloud_firestore` (existing), `shared_preferences` (existing), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-11-05-courses-and-learn-redesign-design.md`

## Global Constraints

- Preview length is `kPreviewLimit = Duration(seconds: 10)`; quiz pass mark is `kQuizPassPercent = 70`. Both are named constants in `lib/models/course_model.dart`.
- Free Learn lessons have **no price, lock, preview or certificate** anywhere (model, widgets, screens).
- Certificate rule: `enrollment.paid && every lesson completed && examScore >= 70`, and the course must have at least one lesson and one quiz question.
- The 10 categories are one const list in `lib/models/learn_category.dart`; counts are computed from data, never typed.
- Learn progress is stored on the phone only (`shared_preferences`); no account needed. Signed-out users are asked to sign in at Unlock, not before browsing.
- Payment is a mock: `CourseAccessService.purchase` is the only place a gateway would be added; `paymentRef` is `"mock"`.
- New strings go in all four languages in `lib/localization/app_localizations.dart` (en, bn, ar, ur). Prices keep the "Tk" display.
- Visual style: flat `ModernCard`, hairline borders, one gradient hero, existing `FadeSlideIn` / `PressScale` / `EmptyState` / `FlatIllustration` / `ShimmerBox` / `AppToast`; light and dark, RTL; animate transform/opacity only and respect reduced motion; never `pumpAndSettle` with looping animations in tests.
- The working tree already has many uncommitted changes from other work. **Every commit must `git add` only the files named in that task**, never `git add -A` or `.`.
- Files in the repo use CRLF; preserve line endings, and run `dart format` only on files the task touched.
- Tests must not need Firebase: all Firestore/auth access goes through the injectable seams defined in Tasks 3 and 4.

## Review Focus

1. Firestore returns nothing or throws (offline, not initialised in tests): both sides show the built-in samples, never a blank screen. (Task 4)
2. A course with no lessons or no quiz questions: "all lessons completed" is vacuously true, so certificate eligibility must still be false and nothing crashes. (Task 3, Task 10)
3. Preview: a seek past 10s is clamped, pressing play after the limit does not run past it, and the Unlock card appears exactly once. (Task 5)
4. A signed-out user taps Unlock: they are sent to sign in, and **no enrollment is written**. (Task 3, Task 8)
5. A video lesson with an empty URL, or an article with an empty body: an inline message, no crash; a category empty on one side but not the other: empty state, and the selected category survives switching sides. (Tasks 7, 9)

---

### Task 1: Dependency, models, categories and sample data

**Files:**
- Modify: `pubspec.yaml` (add `video_player: ^2.9.2`; dev_dependency `video_player_platform_interface` if the analyzer asks for it)
- Create: `lib/models/learn_category.dart`, `lib/models/learn_lesson_model.dart`, `lib/data/course_samples.dart`, `lib/data/learn_samples.dart`
- Modify: `lib/models/course_model.dart`
- Test: `test/learn_models_test.dart`

**Interfaces:**
- Produces:
  - `class LearnCategory { final String id; final String title; final IconData? icon; final Widget Function(double size)? iconBuilder; final Color tint; }` and `const List<LearnCategory> kLearnCategories` (ids: `quran`, `hadis`, `sirat`, `ruqyah`, `hijama`, `acupuncture`, `acupressure`, `homeopathy`, `naturopathy`, `pathology`).
  - `enum LearnLessonKind { video, article }`; `class LearnLesson { id, title, categoryId, kind, videoUrl, body, durationMinutes, thumbnailUrl (String?), order; factory LearnLesson.fromMap(Map<String,dynamic>, String docId); Map<String,dynamic> toMap(); }` (no price/preview/certificate fields).
  - `CourseModel` gains `categoryId, level, instructorName, isInstructorVerified, thumbnailUrl (String?), rating (double), reviewCount (int), previewVideoUrl (String?)` plus `String get previewUrl` (preview url, else first lesson's `videoUrl`, else `''`), `List<Lesson> get allLessons`. `Lesson` gains `durationSeconds` (int, default 0). `CourseEnrollment` gains `paid (bool, false)`, `purchasedAt (DateTime?)`, `paymentRef (String?)`.
  - `const Duration kPreviewLimit`, `const int kQuizPassPercent`.
  - `final List<CourseModel> kSampleCourses` (the ten courses now hard-coded in `learn_tab.dart`, mapped to the category ids above, each with 3+ lessons and 1 quiz of 3 questions) and `final List<LearnLesson> kSampleLearnLessons` (at least 2 per category, mixed video/article).

- [ ] **Step 1: Write the failing test** in `test/learn_models_test.dart`: `LearnLesson round-trips through toMap/fromMap`; `LearnLesson has no price, preview or certificate keys` (`toMap().keys` contains none of `price`, `preview`, `certificate`); `CourseModel.fromMap reads the new fields and defaults missing ones` (rating 0, reviewCount 0, categoryId `''`); `previewUrl falls back to the first lesson when previewVideoUrl is null, and to '' with no lessons`; `kLearnCategories has the 10 ids listed above, all unique`; `every sample course and lesson uses a known category id`; `CourseEnrollment round-trips paid, purchasedAt and paymentRef`.
- [ ] **Step 2: Run** `flutter test test/learn_models_test.dart`. Expected: FAIL (types undefined).
- [ ] **Step 3: Implement** the interfaces above. Add `video_player` and run `flutter pub get`. Keep `CourseModel.toFirestore`/`fromMap` key style (`snake_case`; new keys `category_id, level, instructor_name, instructor_verified, thumbnail_url, rating, review_count, preview_video_url`). Sample videos use one public https test MP4 constant `kSampleVideoUrl`. Leave `learn_tab.dart` untouched in this task (its duplicate class is removed in Task 8).
- [ ] **Step 4: Run** the test again. Expected: all PASS; also `flutter analyze lib/models lib/data` reports no new issues.
- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/models/learn_category.dart lib/models/learn_lesson_model.dart lib/models/course_model.dart lib/data/course_samples.dart lib/data/learn_samples.dart test/learn_models_test.dart
git commit -m "feat: add learn/course models, categories and sample data"
```

### Task 2: Learn progress service

**Files:**
- Create: `lib/services/learn_progress_service.dart`
- Test: `test/learn_progress_service_test.dart`

**Interfaces:**
- Produces: `class LearnProgressService extends ChangeNotifier { static final LearnProgressService instance; Future<void> load(); bool isDone(String lessonId); Future<void> setDone(String lessonId, bool done); Set<String> get doneIds; String? lastOpenedId; Future<void> setLastOpened(String lessonId); }` backed by `SharedPreferences` keys `learn_done` (string list) and `learn_last`.

- [ ] **Step 1: Write the failing tests** (`SharedPreferences.setMockInitialValues`): `marks a lesson done and remembers it after a reload`; `unmarking removes it`; `setLastOpened persists`; `notifies listeners on change`.
- [ ] **Step 2: Run** `flutter test test/learn_progress_service_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement** `LearnProgressService` as above. A fresh instance per test via a public constructor `LearnProgressService()` (the `instance` field stays for the app). Preference errors are caught and logged with `debugPrint`, never thrown.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/services/learn_progress_service.dart test/learn_progress_service_test.dart
git commit -m "feat: add on-device learn progress service"
```

### Task 3: Course access service (mocked purchase, certificate rule)

**Files:**
- Create: `lib/services/course_access_service.dart`
- Test: `test/course_access_service_test.dart`

**Interfaces:**
- Consumes: `CourseModel`, `CourseEnrollment` (Task 1), `kQuizPassPercent`.
- Produces:
  - `abstract class CourseAccessStore { Stream<CourseEnrollment?> watch(String courseId, String uid); Future<void> save(String courseId, CourseEnrollment e); }` and `class FirestoreCourseAccessStore implements CourseAccessStore` (uses `FirebaseService.saveCourseEnrollment` for save and a new `FirebaseService.watchCourseEnrollment(courseId, uid)` for reads; add that method in `firebase_service.dart`).
  - `class SignInRequiredException implements Exception`.
  - `class CourseAccessService { CourseAccessService({CourseAccessStore? store, String? Function()? uid}); static CourseAccessService instance; Stream<CourseEnrollment?> enrollment(String courseId); Future<void> purchase(CourseModel c); Future<void> markLessonComplete(CourseModel c, String lessonId); Future<void> saveExamResult(CourseModel c, int percent); static bool isUnlocked(CourseEnrollment? e); static bool certificateEligible(CourseModel c, CourseEnrollment? e); }`. `uid` defaults to `FirebaseService.currentUser?.uid`.

- [ ] **Step 1: Write the failing tests** with an in-memory fake store: `purchase writes a paid enrollment with paymentRef "mock"`; `purchase with no signed-in user throws SignInRequiredException and writes nothing`; `isUnlocked is false for null and for paid:false`; `markLessonComplete records the lesson once and updates progressPercentage`; `saveExamResult stores the percent`; certificate rule, one test per missing condition: unpaid, a lesson not completed, no exam score, score 69 (false) vs 70 (true); `a course with zero lessons is never eligible`; `a course with zero quiz questions is never eligible`.
- [ ] **Step 2: Run** `flutter test test/course_access_service_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement** the service. `progressPercentage` = completed / total lessons × 100 (0 when there are no lessons). `purchase` and `markLessonComplete` merge into the existing enrollment instead of overwriting it.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/services/course_access_service.dart lib/services/firebase_service.dart test/course_access_service_test.dart
git commit -m "feat: add mocked course purchase and certificate eligibility"
```

### Task 4: Content source with sample fallback

**Files:**
- Create: `lib/services/learn_content_source.dart`
- Modify: `lib/services/firebase_service.dart` (add `static Stream<List<LearnLesson>> getLearnLessonsStream()`)
- Test: `test/learn_content_source_test.dart`

**Interfaces:**
- Produces: `class LearnContentSource { LearnContentSource({Stream<List<CourseModel>> Function()? courses, Stream<List<LearnLesson>> Function()? lessons}); static LearnContentSource instance; Stream<List<CourseModel>> courses(); Stream<List<LearnLesson>> lessons(); }`. Defaults read Firestore. Each stream emits the samples when the source is empty, errors, or throws synchronously (Firebase not initialised); every stream emits at least once.

- [ ] **Step 1: Write the failing tests:** `courses falls back to samples when the source is empty`; `... when the stream errors`; `... when the factory throws`; `lessons does the same`; `real data wins when it is non-empty`.
- [ ] **Step 2: Run** `flutter test test/learn_content_source_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement** with `async*` wrappers around the injected factories and a `try/catch` around the whole call.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/services/learn_content_source.dart lib/services/firebase_service.dart test/learn_content_source_test.dart
git commit -m "feat: add learn content source with sample fallback"
```

### Task 5: Preview limiter and video player widget

**Files:**
- Create: `lib/widgets/learn/preview_limiter.dart`, `lib/widgets/learn/course_video_player.dart`, `lib/widgets/learn/unlock_card.dart`
- Test: `test/preview_limiter_test.dart`, `test/course_video_player_test.dart`, `test/support/fake_video_player.dart`

**Interfaces:**
- Produces:
  - `class PreviewLimiter { PreviewLimiter({Duration limit = kPreviewLimit}); Duration get limit; bool get reached; bool onPosition(Duration p); Duration clampSeek(Duration target); void reset(); }` (`onPosition` returns true the first time `p >= limit` and false afterwards).
  - `class UnlockCard extends StatelessWidget { UnlockCard({required String priceLabel, required VoidCallback onUnlock, VoidCallback? onReplay}); }`.
  - `class CourseVideoPlayer extends StatefulWidget { CourseVideoPlayer({required String url, bool locked = false, String? priceLabel, VoidCallback? onUnlock, VoidCallback? onEnded, String? title}); }`. Locked mode plays at most `kPreviewLimit`, then pauses and shows `UnlockCard`; unlocked mode plays fully with a seek bar and calls `onEnded` at the end. An empty `url` or a load failure shows an inline message with Retry. The controller is disposed with the widget.
  - Test support: `FakeVideoPlayer` (a `VideoPlayerPlatform` fake whose position the test can advance), installed per test.

- [ ] **Step 1: Write the failing tests.** Limiter: `reached is false before 10s and true at 10s`; `onPosition returns true only once`; `clampSeek(30s) == 10s and clampSeek(4s) == 4s`; `reset clears reached`. Widget (fake platform): `locked mode pauses at 10s and shows the Unlock card once`; `play after the limit stays at the limit`; `unlocked mode does not show the Unlock card past 10s`; `unlocked mode calls onEnded at the end`; `empty url shows an inline message and no crash`; `dispose releases the controller`.
- [ ] **Step 2: Run** the two test files. Expected: FAIL.
- [ ] **Step 3: Implement** the three widgets. The player listens to the controller and feeds positions to the limiter; on the limit it calls `pause()` and `seekTo(limit)`.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/widgets/learn test/preview_limiter_test.dart test/course_video_player_test.dart test/support/fake_video_player.dart
git commit -m "feat: add 10-second preview limiter and course video player"
```

### Task 6: Shared Learn widgets

**Files:**
- Create: `lib/widgets/learn/learn_switch.dart`, `lib/widgets/learn/category_row.dart`, `lib/widgets/learn/lesson_card.dart`, `lib/widgets/learn/course_card.dart`
- Test: `test/learn_widgets_test.dart`

**Interfaces:**
- Consumes: `LearnCategory`, `LearnLesson`, `CourseModel`.
- Produces:
  - `enum LearnSide { learn, courses }`; `class LearnSwitch { LearnSwitch({required LearnSide side, required ValueChanged<LearnSide> onChanged}); }` (sliding thumb, semantic labels "Learn, free" and "Courses, paid", selected state announced).
  - `class CategoryRow { CategoryRow({required String? selectedId, required ValueChanged<String?> onSelected, required Map<String,int> counts, required String countNoun}); }` (null id = All; tapping the selected one clears it).
  - `class LessonCard { LessonCard({required LearnLesson lesson, required bool done, required VoidCallback onTap}); }` shows a video/article badge, minutes, "Free" tag and a done tick; **no price or lock**.
  - `class CourseCard { CourseCard({required CourseModel course, required bool owned, required VoidCallback onTap, required VoidCallback onPreview}); }` shows price (`Tk`), rating, "Certificate" badge, a "Preview 10s" button (hidden when owned) and an "Owned" badge when owned.

- [ ] **Step 1: Write the failing tests:** switch tap fires `onChanged(LearnSide.courses)`; category tap selects, second tap clears; counts render as `N Lessons`/`N Courses`; `LessonCard` finds no text containing `Tk`, no lock icon and no `Certificate`; `CourseCard` shows `Tk`, `Certificate`, `Preview` for an unowned course and `Owned` but no `Preview` when owned; each widget builds without overflow at width 320 with text scale 2.0.
- [ ] **Step 2: Run** `flutter test test/learn_widgets_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement** the four widgets with the flat card style; any strings go through `context.tr` with new keys added in Task 8.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/widgets/learn test/learn_widgets_test.dart
git commit -m "feat: add learn switch, category row, lesson and course cards"
```

### Task 7: Learn (free) view and lesson screen

**Files:**
- Create: `lib/screens/learn/learn_free_view.dart`, `lib/screens/learn/learn_lesson_screen.dart`
- Test: `test/learn_free_view_test.dart`

**Interfaces:**
- Consumes: `LearnContentSource.instance.lessons()`, `LearnProgressService.instance`, `LessonCard`, `CourseVideoPlayer`.
- Produces: `class LearnFreeView { LearnFreeView({required String? categoryId, required void Function(Map<String,int> counts) onCounts}); }` (continue card for the last unfinished lesson, list of `LessonCard`s, `EmptyState` when the category has none, `ShimmerBox` while loading) and `class LearnLessonScreen { LearnLessonScreen({required LearnLesson lesson, required List<LearnLesson> siblings}); }` (video via `CourseVideoPlayer(locked: false)` or the article body; "Mark as done"; "Next lesson"). It shows no price, lock or certificate.

- [ ] **Step 1: Write the failing tests** (inject `LearnContentSource` and a fresh `LearnProgressService`): `lists lessons filtered by category`; `shows an empty state for a category with no lessons`; `tapping a lesson opens the lesson screen`; `Mark as done persists and shows the tick on return`; `Next lesson opens the following lesson and is absent on the last`; `an article with an empty body shows an inline message`; `a video lesson with an empty url shows an inline message`; `the lesson screen contains no 'Tk', lock icon or 'Certificate'`.
- [ ] **Step 2: Run** `flutter test test/learn_free_view_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement** both. Opening a lesson calls `setLastOpened`; counts are reported up through `onCounts` after the first frame.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/screens/learn/learn_free_view.dart lib/screens/learn/learn_lesson_screen.dart test/learn_free_view_test.dart
git commit -m "feat: add free Learn view and lesson screen"
```

### Task 8: Courses view, purchase sheet, Learn tab shell and wiring

**Files:**
- Create: `lib/screens/learn/courses_view.dart`, `lib/widgets/learn/purchase_sheet.dart`
- Modify: `lib/screens/tabs/learn_tab.dart` (rewrite to the shell; delete the duplicate `CourseModel` and `CourseModuleInfo`), `lib/screens/tabs/services_tab.dart` (target `LearnTab(initialSide: LearnSide.courses)`), `lib/localization/app_localizations.dart`
- Test: `test/courses_view_test.dart`, `test/learn_tab_test.dart`

**Interfaces:**
- Consumes: `LearnContentSource`, `CourseAccessService`, `CourseCard`, `LearnSwitch`, `CategoryRow`, `LearnFreeView`, `CourseDetailScreen` (Task 9; until then navigate with a `CourseDetailScreen(course: course)` call that Task 9 satisfies).
- Produces:
  - `class CoursesView { CoursesView({required String? categoryId, required void Function(Map<String,int>) onCounts}); }` ("My courses" strip for owned courses, `CourseCard` list, `EmptyState`, loading skeleton). A card's Preview button opens `CourseDetailScreen(course:, autoPreview: true)`.
  - `Future<bool> showPurchaseSheet(BuildContext context, CourseModel course)`: shows summary, price, a "Test payment" note and "Pay Tk X"; on success shows an animated check and returns true; a signed-out user (`SignInRequiredException`) is routed to `SigninScreen` and nothing is written; a failure shows a Retry toast and returns false.
  - `class LearnTab { const LearnTab({super.key, this.initialSide = LearnSide.learn}); }`; the selected category is kept when the side changes.

- [ ] **Step 1: Write the failing tests.** `courses_view_test`: `lists courses with price, Certificate badge and Preview`; `owned courses show Owned, not Preview, and appear in My courses`; `category filter works and an empty category shows the empty state`. `learn_tab_test`: `opens on Learn by default and on Courses with initialSide`; `switching sides keeps the selected category`; `Learn side shows no 'Tk' or 'Certificate'`; `Courses side shows both`; `purchase sheet: Pay unlocks the course (fake store)`; `purchase sheet signed out: no enrollment written and sign-in is opened`; `purchase failure shows Retry and the course stays locked`; `Services 'Courses' card opens the tab on the Courses side`.
- [ ] **Step 2: Run** both files. Expected: FAIL.
- [ ] **Step 3: Implement.** Add localization keys for every new string in en/bn/ar/ur (switch labels, "Free", "Owned", "Preview 10s", "Unlock for", "Test payment", "My courses", empty-state texts). Use `AppPageRoute.sharedAxis` for navigation. The existing hero "Continue" card and community banner stay but use real progress (last opened lesson / owned course) and hide when there is none.
- [ ] **Step 4: Run** both files plus `flutter test test/ui_robustness_test.dart --plain-name LearnTab`. Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/screens/learn/courses_view.dart lib/widgets/learn/purchase_sheet.dart lib/screens/tabs/learn_tab.dart lib/screens/tabs/services_tab.dart lib/localization/app_localizations.dart test/courses_view_test.dart test/learn_tab_test.dart
git commit -m "feat: split Learn and Courses behind one tab with mocked purchase"
```

### Task 9: Course detail and course player

**Files:**
- Modify: `lib/screens/course_detail_screen.dart` (restyle; constructor becomes `CourseDetailScreen({required CourseModel course, bool autoPreview = false})`)
- Create: `lib/screens/learn/course_player_screen.dart`
- Test: `test/course_detail_screen_test.dart`

**Interfaces:**
- Consumes: `CourseModel`, `CourseAccessService`, `CourseVideoPlayer`, `showPurchaseSheet`, `UnlockCard`.
- Produces: `class CoursePlayerScreen { CoursePlayerScreen({required CourseModel course, required Lesson lesson}); }` (full playback for owned courses; calls `markLessonComplete` on end; "Take the quiz" appears once every lesson is complete). `CourseDetailScreen`: preview card on top (locked `CourseVideoPlayer` for an unowned course), tabs Curriculum / Overview / Instructor, locked lessons show a lock icon, and a sticky bottom bar shows **Unlock for Tk X** (unowned) or **Continue** (owned). Lessons are tappable only when owned.

- [ ] **Step 1: Write the failing tests:** `unowned: bottom bar says Unlock, lessons show a lock, preview is locked`; `owned: bottom bar says Continue, no lock, tapping a lesson opens the player`; `Unlock opens the purchase sheet and, after paying, the bar changes to Continue`; `autoPreview starts the preview`; `finishing the last lesson shows 'Take the quiz'`; `a course with no lessons shows an empty curriculum message and no crash`; no overflow at width 320 / text 2.0.
- [ ] **Step 2: Run** `flutter test test/course_detail_screen_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement** both screens; remove the screen's hard-coded sample curriculum and use `course.syllabus`.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/screens/course_detail_screen.dart lib/screens/learn/course_player_screen.dart test/course_detail_screen_test.dart
git commit -m "feat: redesign course detail and add course player"
```

### Task 10: Quiz and certificate gating

**Files:**
- Modify: `lib/screens/quiz_certificate_screen.dart` (constructor `QuizCertificateScreen({required CourseModel course})`; restyle)
- Test: `test/quiz_certificate_screen_test.dart`

**Interfaces:**
- Consumes: `CourseAccessService.certificateEligible/saveExamResult/enrollment`, `kQuizPassPercent`, `Quiz`.
- Produces: the screen runs the course's real `Quiz` questions, saves the percent with `saveExamResult`, and shows the certificate card, preview and download only when `certificateEligible` is true; otherwise a locked state naming what is missing (lessons left, quiz not passed, course not purchased, or no quiz available). Download stays the existing toast. No Learn screen links here.

- [ ] **Step 1: Write the failing tests:** `answering at least 70% saves the score and shows the certificate`; `69% shows a retry and no certificate`; `lessons left shows the locked state naming them`; `an unpurchased course shows the locked state`; `a course with no quiz questions shows 'no quiz available' and no certificate`; `no certificate text appears anywhere on a Learn lesson screen` (guards the Learn side).
- [ ] **Step 2: Run** `flutter test test/quiz_certificate_screen_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implement.** Reuse the existing certificate card styling; replace the single mock question with the course's quiz.
- [ ] **Step 4: Run.** Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/screens/quiz_certificate_screen.dart test/quiz_certificate_screen_test.dart
git commit -m "feat: gate certificate to completed, passed paid courses"
```

### Task 11: Stress tests, analysis and full suite

**Files:**
- Modify: `test/ui_robustness_test.dart` (add `LearnTab` Courses side, `LearnLessonScreen`, `CourseDetailScreen`, and `QuizCertificateScreen` using the first sample course/lesson)

- [ ] **Step 1:** Add the new screens to the `_screens` map (they run through small / 1.6× / 2× / RTL+dark / tablet with real fonts and semantics).
- [ ] **Step 2: Run** `flutter test test/ui_robustness_test.dart`. Expected: PASS; fix any overflow found in the screens (not by relaxing the test).
- [ ] **Step 3: Run** `flutter analyze lib test`. Expected: no new issues beyond the existing 20.
- [ ] **Step 4: Run** the full suite `flutter test`. Expected: all tests pass.
- [ ] **Step 5: Commit**

```bash
git add test/ui_robustness_test.dart
git commit -m "test: stress-test the new Learn and Courses screens"
```

## Self-review notes

- Spec coverage: sections 1 (purpose/decisions) → Tasks 6–10; 4.1–4.3 → Task 1; 4.4 → Task 3; 4.5 → Task 2; 4.6 → Task 4; 4.7 → Tasks 3 and 10; 5.1–5.3 → Tasks 6–8; 5.4–5.5 → Tasks 5 and 9; 5.6 → Task 8; 5.7 → Task 10; 6 file plan → matches; 7 error handling → Review Focus 1, 3, 4, 5 and Tasks 5/7/9; 8 testing → Tasks 1–11. Section 9 (admin setup) is documentation only, no task.
- Names used across tasks: `LearnSide`, `LearnContentSource.instance`, `CourseAccessService.instance`, `LearnProgressService.instance`, `kPreviewLimit`, `kQuizPassPercent`, `showPurchaseSheet`, `CourseDetailScreen(course:, autoPreview:)`, `QuizCertificateScreen(course:)`.
