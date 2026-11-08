# Courses and Learn redesign: design

Date: 2026-11-05. Status: draft for review. Nothing here is implemented yet.

## 1. Purpose

Today the app has one screen that mixes two things. The bottom-nav **Learn** tab and the Services **Courses** card both open `lib/screens/tabs/learn_tab.dart`, which lists ten hard-coded paid courses with a "Free Lessons" count and a "Certificate" badge.

The owner wants two different products that share the same ten categories:

| | **Learn** | **Courses** |
|---|---|---|
| Price | Free, always | Paid |
| Content | Short video or article lessons | Modules of video lessons, plus a quiz |
| Preview | Not needed, everything is open | Each course has a **10-second video preview** |
| Certificate | **No** | **Yes**, after finishing the lessons and passing the quiz |

Success looks like this:

- A user can browse both sides with one category row.
- A free lesson never shows a price, a lock or a certificate.
- A paid course can be previewed for exactly 10 seconds, unlocked through a mocked purchase, completed, and certified.
- The screens use the app's lighter, flat visual style.

### Decisions already made (from the conversation)

1. One bottom-nav **Learn** tab with a top switch: `Learn (Free)` / `Courses (Paid)`. The Services "Courses" card opens it on the Courses side.
2. Learn content is **standalone short video or article lessons**. There are no modules, quiz or certificate.
3. Payment is **mocked**: the full buy flow and an enrollment saved to Firestore, with no payment gateway.
4. Video is **real**, through the `video_player` package.

### Assumptions (change any of these)

- The quiz pass mark is **70%**.
- The preview length is **10 seconds**, a single constant.
- Prices keep the existing "Tk" display.
- Learn progress ("done" marks) is kept **on the phone** only, so Learn works without an account.
- Anyone signed in can buy a course. Signed-out users are asked to sign in at the Unlock step, not before browsing.

## 2. Out of scope

- A real payment gateway (bKash, Stripe) and server-side purchase verification.
- Real PDF generation for the certificate. Today "Download Certificate" only shows a toast, and that stays for now. The certificate screen itself is restyled and gated.
- An admin screen for uploading courses and lessons. Content comes from Firestore (see section 4); the admin-side setup is documented, not built.
- Video protection (DRM, signed URLs).
- Reviews, comments and ratings entry. Ratings are read-only data.

## 3. Approach

Two feature areas built on shared parts, behind one tab shell. Free and paid logic live in separate views and separate models. That makes it impossible for a free lesson to reach a paywall or a certificate by accident, which is the main rule of this feature.

Rejected: a single list with a `paid` flag (certificate and preview rules would tangle into one screen) and two fully separate tabs (the category row and cards would be duplicated and drift apart).

## 4. Data

### 4.1 Categories (shared)

New `lib/models/learn_category.dart`: `LearnCategory { id, title, icon, tint }` and one const list of the ten categories now typed inline in `learn_tab.dart` (Quran Sikkha, Hadis Sikkha, Sirat Sikkha, Ruqyah, Hijama, Acupuncture, Acupressure, Homeopathy, Naturopathy, Pathology). Both sides filter by `category.id`. The "N Courses" / "N Lessons" counts are **computed from the data**, not typed in.

### 4.2 Courses (paid)

Extend the existing `CourseModel` in `lib/models/course_model.dart`, which is the Firestore-backed one. Add:

- `categoryId`, `level`, `instructorName`, `isInstructorVerified`
- `thumbnailUrl` (nullable)
- `rating`, `reviewCount`
- `previewVideoUrl` (nullable; falls back to the first lesson's `videoUrl`)

Add `durationSeconds` to `Lesson`. Add `kPreviewLimit = Duration(seconds: 10)` and `kQuizPassPercent = 70` as named constants.

There is a second, UI-only class also called `CourseModel` inside `learn_tab.dart`. It is removed and its ten sample courses move to `lib/data/course_samples.dart` as real `CourseModel` values, which removes the name clash.

### 4.3 Learn lessons (free)

New `lib/models/learn_lesson_model.dart`: `LearnLesson { id, title, categoryId, kind (video | article), videoUrl, body, durationMinutes, thumbnailUrl, order }`. There is **no price, no preview and no certificate field**. Firestore collection: `learn_lessons`. Samples in `lib/data/learn_samples.dart`.

### 4.4 Enrollment and unlock (courses only)

The existing `courses/{courseId}/enrollments/{uid}` document (`CourseEnrollment`) gains `paid` (bool), `purchasedAt` (timestamp) and `paymentRef` (string, `"mock"` for now). A course is **unlocked** when that document exists with `paid == true`.

New `lib/services/course_access_service.dart`:

- `Stream<bool> isUnlocked(courseId)`
- `Future<void> purchase(course)`: the mocked purchase. It writes the enrollment and returns, and it is the only place a real gateway would later be added.
- `Future<void> markLessonComplete(courseId, lessonId)` and `Future<void> saveExamResult(courseId, score)`
- The store behind it is injectable, so tests need no Firebase.

### 4.5 Learn progress (free)

New `lib/services/learn_progress_service.dart`: a set of completed lesson ids in `shared_preferences`. No account, no network.

### 4.6 Sample data fallback

When Firestore returns nothing, or a read fails, the views show the built-in samples so the app is never blank. A one-line label in code marks them as samples. Sample videos use a public test video URL.

### 4.7 Certificate rule

`certificateEligible = enrollment.paid && every lesson completed && examScore >= 70%`. `QuizCertificateScreen` is only reachable from a course, takes a `courseId`, and shows a "locked" state if the rule is not met. No Learn screen links to it.

### 4.8 Known limitation of the mock

Unlock is decided on the phone, and `videoUrl` for every lesson is in the course document, so a determined user could read it. Fine for a mock. Before real payments: verify purchases server-side, tighten Firestore rules, and serve video through signed URLs.

## 5. Screens

### 5.1 Learn tab shell (`learn_tab.dart`, slimmed)

Header with the title and a **sliding two-option switch**: `Learn · Free` / `Courses · Paid`. Below it, the shared category row (single selection, "All" by default, kept when switching sides). Then the active side's view. The switch and category selection animate with transform and opacity only, and respect reduced motion. `LearnTab({initialSide})` lets the Services card open on Courses.

### 5.2 Learn (free) view: `learn_free_view.dart`

- "Continue" card for the last unfinished lesson, if there is one.
- A list of `LessonCard`s: thumbnail, a video or article badge, duration, a green "Free" tag, and a done tick.
- Empty state with an illustration when a category has no lessons.
- `LearnLessonScreen`: a video player (full playback) or an article body, "Mark as done", and "Next lesson". It shows **no price, lock or certificate**.

### 5.3 Courses (paid) view: `courses_view.dart`

- A list of `CourseCard`s: thumbnail, title, instructor (verified tick), level, rating, price, a "Certificate" badge, a **"Preview 10s"** button, and an "Owned" badge when unlocked.
- A "My courses" strip on top for owned courses, with progress.
- Empty state per category.

### 5.4 Course detail (`course_detail_screen.dart`, restyled, takes a `CourseModel`)

Preview card at the top, then tabs for Curriculum, Overview and Instructor. A sticky bottom bar shows the price and **Unlock** if the course is not owned, or **Continue** if it is. Locked lessons in the curriculum show a lock; the first lesson is previewable.

### 5.5 Preview and lesson player

One widget, two modes, in `lib/widgets/learn/course_video_player.dart`:

- **Preview (locked):** plays up to `kPreviewLimit`, then pauses, blocks seeking past the limit, and covers the video with the **Unlock card** (price and "Unlock" button).
- **Full (unlocked):** normal playback with a seek bar. Reaching the end marks the lesson complete.

The limiter logic is separate from the widget (`PreviewLimiter`) so it can be tested without video.

### 5.6 Purchase sheet

A bottom sheet with the course summary and price, a "Pay Tk X" button, and a clear "Test payment" note. On success: an animated check, a toast, the course unlocks, and the enrollment is saved. A signed-out user is sent to sign in first. Failure shows a retry toast.

### 5.7 Quiz and certificate (restyled)

The quiz screen reads the course's real `Quiz` (not the single mock question) and saves `examScore`. The certificate card, preview and download button show only after passing; otherwise a locked state explains what is missing (lessons left, or quiz not passed).

### 5.8 Visual style

Follows the earlier "lighter surfaces" direction: flat cards with hairline borders, one gradient hero, the existing `FadeSlideIn`, `PressScale`, `FlatIllustration`/`EmptyState`, `ShimmerBox` for loading and `AppToast`. Dark mode and RTL are supported. New strings are added in all four languages (en, bn, ar, ur).

## 6. File plan

**New**
- `lib/models/learn_category.dart`, `lib/models/learn_lesson_model.dart`
- `lib/data/course_samples.dart`, `lib/data/learn_samples.dart`
- `lib/services/course_access_service.dart`, `lib/services/learn_progress_service.dart`
- `lib/widgets/learn/`: `learn_switch.dart`, `category_row.dart`, `lesson_card.dart`, `course_card.dart`, `course_video_player.dart` (with `PreviewLimiter`), `unlock_card.dart`, `purchase_sheet.dart`
- `lib/screens/learn/`: `learn_free_view.dart`, `courses_view.dart`, `learn_lesson_screen.dart`, `course_player_screen.dart`

**Changed**
- `lib/screens/tabs/learn_tab.dart` (slimmed to the shell), `lib/screens/course_detail_screen.dart`, `lib/screens/quiz_certificate_screen.dart`
- `lib/screens/tabs/services_tab.dart` (open on the Courses side)
- `lib/models/course_model.dart`, `lib/services/firebase_service.dart` (learn lessons stream, enrollment read and write)
- `lib/localization/app_localizations.dart`, `pubspec.yaml` (`video_player`)

## 7. Error handling

- No network or a failed read: show samples (see 4.6) and a small "offline" note.
- Video fails to load: an inline error with Retry; the screen never crashes.
- Purchase write fails: the course stays locked and a retry toast is shown.
- Signed-out purchase: redirect to sign in, then return to the Unlock sheet.
- Leaving a screen disposes the video controller, and a preview timer is cancelled on dispose.

## 8. Testing

- **Unit:** model `fromMap`/`toMap` for `CourseModel`, `LearnLesson` and the enrollment; `PreviewLimiter` (stops at 10s, blocks seeks past it, resumes inside it); `CourseAccessService` (purchase unlocks, a missing enrollment stays locked) with a fake store; `LearnProgressService`; the certificate eligibility rule (all three conditions).
- **Widget (fake video platform):** the switch swaps sides and the category survives it; a Learn lesson shows no price, lock or certificate; a course card shows price, the preview button and the certificate badge; the preview ends with the Unlock card at 10s; purchasing unlocks the course and removes the lock; the quiz result gates the certificate; Services "Courses" opens the Courses side.
- **Stress:** add `LearnTab` (both sides), the lesson screen, course detail and the purchase sheet to `test/ui_robustness_test.dart` (small phone, 1.6×/2× text, RTL + dark, tablet, real fonts).
- Existing suite stays green. Not verifiable by tests, so reported as such: real video decoding on a device, and how it looks.

## 9. Admin-side setup (documented, not built)

- Firestore `courses` documents with the fields in 4.2 (price in `price_bdt`, lessons under `syllabus`), and `learn_lessons` documents with the fields in 4.3.
- Firestore rules: public read on `learn_lessons`; read on `courses`; an enrollment document readable and writable only by its own `uid`.
