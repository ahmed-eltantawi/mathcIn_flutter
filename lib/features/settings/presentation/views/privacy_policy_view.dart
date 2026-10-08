import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  InAppWebViewController? _webViewController;
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';

  void _reload() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _progress = 0.0;
    });
    _webViewController?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.privacyPolicy,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_progress < 1.0 && !_hasError)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                minHeight: 2.h,
              ),
            Expanded(
              child: _hasError ? _buildErrorView() : _buildWebView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialFile: 'assets/privacy_policy/privacy_policy.html',
      initialSettings: InAppWebViewSettings(
        useShouldOverrideUrlLoading: true,
        allowsInlineMediaPlayback: true,
        javaScriptEnabled: true,
        transparentBackground: true,
        supportZoom: false,
      ),
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onProgressChanged: (controller, progress) {
        if (!mounted) return;
        setState(() {
          _progress = progress / 100;
        });
      },
      onReceivedError: (controller, request, error) {
        if (!mounted) return;
        if (request.isForMainFrame == true) {
          setState(() {
            _hasError = true;
            _errorMessage = error.description;
          });
        }
      },
    );
  }

  Widget _buildErrorView() {
    final colors = context.colors;
    final theme = context.theme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colors.error,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Could not load Privacy Policy',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                _errorMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
