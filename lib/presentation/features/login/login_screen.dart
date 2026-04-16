import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // ── Logo / wordmark ─────────────────────────────────────
              Icon(
                Icons.article_outlined,
                size: 72,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Byline',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stories worth reading.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(flex: 3),
              // ── Sign-in button ───────────────────────────────────────
              if (auth.isLoading)
                const CircularProgressIndicator()
              else ...[
                if (auth.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Sign-in failed. Please try again.',
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _GoogleSignInButton(
                  onPressed: () => ref.read(authProvider.notifier).signIn(),
                ),
              ],
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google 'G' logo using coloured icon segments
          _GoogleLogo(),
          const SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simple coloured 'G' using a CustomPaint to avoid image assets.
    return const SizedBox(
      width: 24,
      height: 24,
      child: _GoogleGPainter(),
    );
  }
}

class _GoogleGPainter extends StatelessWidget {
  const _GoogleGPainter();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GPainter());
  }
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const blue = Color(0xFF4285F4);
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    // Red (top-left arc)
    paint.color = red;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -2.36, 1.57, true, paint,
    );
    // Yellow (bottom-left arc)
    paint.color = yellow;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.79, -1.57, true, paint,
    );
    // Green (bottom-right arc)
    paint.color = green;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0.0, 1.57, true, paint,
    );
    // Blue (right arc + horizontal bar)
    paint.color = blue;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.79, 0.79, true, paint,
    );

    // White centre circle
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.6, paint);

    // Blue horizontal bar
    paint.color = blue;
    canvas.drawRect(
      Rect.fromLTRB(cx, cy - r * 0.18, cx + r, cy + r * 0.18),
      paint,
    );

    // White inner fill (to make the 'G' shape)
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.42, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
