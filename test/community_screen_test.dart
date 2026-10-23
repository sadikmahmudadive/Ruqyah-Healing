import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruqyahhealing/models/community_models.dart';
import 'package:ruqyahhealing/screens/community_screen.dart';
import 'package:ruqyahhealing/widgets/community/comments_sheet.dart';
import 'package:ruqyahhealing/widgets/community/create_post_sheet.dart';
import 'package:ruqyahhealing/widgets/community/create_story_sheet.dart';
import 'package:ruqyahhealing/widgets/community/post_card.dart';
import 'package:ruqyahhealing/widgets/community/post_composer_bar.dart';
import 'package:ruqyahhealing/widgets/community/stories_carousel_bar.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('Community & Stories Feature Tests', () {
    testWidgets('CommunityScreen renders header, composer, stories, and feed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const CommunityScreen()));
      await tester.pumpAndSettle();

      // Top title
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Share reflections, stories & du\'as'), findsOneWidget);

      // Composer bar
      expect(find.text("What's on your mind? Share a reflection..."), findsOneWidget);

      // Stories bar
      expect(find.text('Community Stories'), findsOneWidget);
      expect(find.text('Create Story'), findsOneWidget);
      expect(find.text('Ust. Ahmad Idris'), findsWidgets);

      // Category filter pills
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Du\'a Request'), findsWidgets);
      expect(find.text('Healing Story'), findsWidgets);
    });

    testWidgets('PostComposerBar triggers category modal when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: PostComposerBar(onPostCreated: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Du'a Request" quick action
      await tester.tap(find.text('Du\'a Request'));
      await tester.pumpAndSettle();

      // Modal appears
      expect(find.text('Create Community Post'), findsOneWidget);
      expect(find.text('Select Category'), findsOneWidget);
      expect(find.text('Anonymous Member'), findsNothing); // Identity visible initially
    });

    testWidgets('CreatePostSheet allows anonymous toggling and posting',
        (WidgetTester tester) async {
      CommunityPost? createdPost;

      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: CreatePostSheet(
              onPostCreated: (p) => createdPost = p,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Toggle anonymous
      await tester.tap(find.text('Identity visible'));
      await tester.pumpAndSettle();
      expect(find.text('Anonymous'), findsOneWidget);

      // Enter content
      await tester.enterText(
        find.byType(TextField).last,
        'May Allah heal everyone who is tested with illness.',
      );
      await tester.pumpAndSettle();

      // Tap Publish Post
      await tester.ensureVisible(find.text('Publish Post'));
      await tester.tap(find.text('Publish Post'));
      await tester.pumpAndSettle();

      expect(createdPost, isNotNull);
      expect(createdPost!.isAnonymous, isTrue);
      expect(createdPost!.authorName, 'Anonymous');
    });

    testWidgets('CreateStorySheet allows selecting gradient and Ayah',
        (WidgetTester tester) async {
      StorySlide? createdSlide;

      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: CreateStorySheet(
              onStoryCreated: (s) => createdSlide = s,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add to Your Story'), findsOneWidget);
      expect(find.text('Story Theme'), findsOneWidget);

      // Select an Ayah chip
      await tester.ensureVisible(find.text('وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ'));
      await tester.tap(find.text('وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ'));
      await tester.pumpAndSettle();

      // Tap Share to Story
      await tester.ensureVisible(find.text('Share to Story'));
      await tester.tap(find.text('Share to Story'));
      await tester.pumpAndSettle();

      expect(createdSlide, isNotNull);
      expect(createdSlide!.arabicVerse, 'وَإِذَا مَرِضْتُ فَهُوَ يَشْفِينِ');
    });

    testWidgets('PostCard renders reactions and triggers inline comment',
        (WidgetTester tester) async {
      final post = CommunityPost(
        id: 'test_post',
        authorName: 'Dr. Zayd',
        authorRole: 'Therapist',
        timeAgo: '1h ago',
        isVerified: true,
        category: 'Ruqyah Advice',
        title: 'Morning protection',
        content: 'Recite Ayat al Kursi after Fajr prayer.',
        commentsCount: 1,
        sharesCount: 2,
        comments: [
          PostComment(
            id: 'c_test',
            authorName: 'Umar',
            authorRole: 'Member',
            timeAgo: '10m ago',
            text: 'JazakAllahu khair!',
          ),
        ],
      );

      var updated = false;

      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: SingleChildScrollView(
              child: PostCard(
                post: post,
                onPostUpdated: () => updated = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Zayd'), findsOneWidget);
      expect(find.text('Morning protection'), findsOneWidget);
      expect(find.text('🤲 Ameen'), findsOneWidget);

      // Tap inline quick "🤲 Ameen" button
      await tester.tap(find.text('🤲 Ameen'));
      await tester.pumpAndSettle();

      expect(updated, isTrue);
      expect(post.comments.length, 2);
    });

    testWidgets('CommentsSheet renders comment list and adds new comment',
        (WidgetTester tester) async {
      final post = CommunityPost(
        id: 'p_comment',
        authorName: 'Ali',
        authorRole: 'Member',
        timeAgo: '10m ago',
        category: 'Question',
        title: 'Question',
        content: 'How often should Hijama be done?',
        commentsCount: 0,
      );

      PostComment? added;

      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: CommentsSheet(
              post: post,
              onCommentAdded: (c) => added = c,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Comments'), findsOneWidget);
      expect(find.text('No comments yet'), findsOneWidget);

      // Tap quick chip "🤲 Ameen"
      await tester.tap(find.text('🤲 Ameen'));
      await tester.pumpAndSettle();

      expect(added, isNotNull);
      expect(added!.text, '🤲 Ameen');
    });
  });
}
