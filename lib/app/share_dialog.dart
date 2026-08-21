import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nunu/theme.dart';
import 'package:nunu/widgets/dialog_shell.dart';

const String _shareUrl = 'https://www.nunu.monster';
const String _shareTitle = '努努加速器 — 永久免费的网络加速器';
const String _shareText = '我在用努努加速器，永久免费、不限流量、不限速度，推荐你也试试 ✦';

Future<void> showShareDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (context) => const _ShareDialog(),
  );
}

class _ShareDialog extends StatelessWidget {
  const _ShareDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DialogShell(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        '分享努努加速器',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                const _QrCard(url: _shareUrl),
                const Gap(16),
                _LinkRow(url: _shareUrl),
                const Gap(14),
                Center(
                  child: Text(
                    '谢谢你的分享 ✦',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              tooltip: '关闭',
              icon: Icon(
                Icons.close_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final targets = <_ShareTarget>[
      _ShareTarget(
        label: '微信',
        icon: Icons.chat_bubble_rounded,
        gradient: const [Color(0xFF34D399), Color(0xFF059669)],
        onTap: (context) async {
          await _copyShareText();
          _showToast(context, '链接已复制，请在微信中粘贴分享给好友');
        },
      ),
      _ShareTarget(
        label: 'QQ',
        icon: Icons.forum_rounded,
        gradient: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
        onTap: (context) async {
          await _copyShareText();
          _showToast(context, '链接已复制，请在 QQ 中粘贴分享给好友');
        },
      ),
      _ShareTarget(
        label: '微博',
        icon: Icons.public_rounded,
        gradient: const [Color(0xFFFB7185), Color(0xFFE11D48)],
        onTap: (context) async {
          final ok = await _openUrl(
            'https://service.weibo.com/share/share.php'
            '?url=${Uri.encodeComponent(_shareUrl)}'
            '&title=${Uri.encodeComponent(_shareTitle)}',
          );
          if (!ok && context.mounted) {
            _showToast(context, '无法打开浏览器');
          }
        },
      ),
      _ShareTarget(
        label: 'Telegram',
        icon: Icons.send_rounded,
        gradient: const [Color(0xFF22D3EE), Color(0xFF2563EB)],
        onTap: (context) async {
          final ok = await _openUrl(
            'https://t.me/share/url'
            '?url=${Uri.encodeComponent(_shareUrl)}'
            '&text=${Uri.encodeComponent(_shareText)}',
          );
          if (!ok && context.mounted) {
            _showToast(context, '无法打开 Telegram');
          }
        },
      ),
      _ShareTarget(
        label: 'X / Twitter',
        icon: Icons.alternate_email_rounded,
        gradient: const [Color(0xFF334155), Color(0xFF0F172A)],
        onTap: (context) async {
          final ok = await _openUrl(
            'https://twitter.com/intent/tweet'
            '?url=${Uri.encodeComponent(_shareUrl)}'
            '&text=${Uri.encodeComponent(_shareText)}',
          );
          if (!ok && context.mounted) {
            _showToast(context, '无法打开浏览器');
          }
        },
      ),
      _ShareTarget(
        label: '复制链接',
        icon: Icons.link_rounded,
        gradient: const [Color(0xFF60A5FA), Color(0xFF2563EB)],
        onTap: (context) async {
          await _copyShareText();
          _showToast(context, '链接已复制到剪贴板');
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 360 ? 3 : 3;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [for (final t in targets) _ShareTargetTile(target: t)],
        );
      },
    );
  }
}

class _ShareTarget {
  const _ShareTarget({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final List<Color> gradient;
  final Future<void> Function(BuildContext context) onTap;
}

class _ShareTargetTile extends StatelessWidget {
  const _ShareTargetTile({required this.target});

  final _ShareTarget target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => target.onTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: target.gradient,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: target.gradient.last.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(target.icon, color: Colors.white, size: 24),
            ),
            const Gap(8),
            Text(
              target.label,
              style: textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceOverlay,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.35 : 0.18,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: QrImageView(
                data: url,
                version: QrVersions.auto,
                size: 148,
                gapless: true,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF0F172A),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF0F172A),
                ),
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const Gap(12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const Gap(6),
                Text(
                  '扫码访问 nunu.monster',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceOverlay,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              url,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(8),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                ),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () async {
              await _copyShareText();
              if (context.mounted) {
                _showToast(context, '链接已复制到剪贴板');
              }
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('复制'),
          ),
        ],
      ),
    );
  }
}

Future<void> _copyShareText() {
  return Clipboard.setData(ClipboardData(text: '$_shareText $_shareUrl'));
}

Future<bool> _openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

void _showToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
  );
}
