import 'package:blog_app/core/theme/app_pallete.dart';
import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:blog_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  static Route<void> route(User user) => MaterialPageRoute(
        builder: (context) => HomePage(user: user),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                LoginPage.route(),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name.isNotEmpty ? user.name : user.email}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover stories, ideas, and perspectives from the community.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppPallete.greyColor,
                  ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 72,
                      color: AppPallete.gradient2.withValues(alpha: 0.8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your blog feed will appear here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppPallete.greyColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppPallete.gradient1,
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }
}
