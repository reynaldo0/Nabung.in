import 'package:material_ui/material_ui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onComplete, super.key});

  final Future<bool> Function() onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.flag_outlined,
      eyebrow: 'MULAI DENGAN TUJUAN',
      title: 'Wujudkan rencana,\nsatu target setiap saat.',
      description: 'Nabung.in membantumu mengubah keinginan menjadi target tabungan yang jelas dan terukur.',
      color: Color(0xFFE5F5EF),
    ),
    _OnboardingPageData(
      icon: Icons.track_changes_outlined,
      eyebrow: 'PANTAU PROGRES',
      title: 'Lihat progresmu\ndengan lebih tenang.',
      description: 'Pantau saldo dan perkembangan setiap target dalam satu dashboard yang ringkas dan mudah dipahami.',
      color: Color(0xFFE8F3F7),
    ),
    _OnboardingPageData(
      icon: Icons.account_balance_wallet_outlined,
      eyebrow: 'CATAT DENGAN RAPI',
      title: 'Setiap rupiah punya\ncerita dan tujuan.',
      description: 'Catat tabungan secara offline. Datamu tersimpan di perangkat dan tetap bisa diakses tanpa internet.',
      color: Color(0xFFFFF3DF),
    ),
    _OnboardingPageData(
      icon: Icons.celebration_outlined,
      eyebrow: 'RAYAKAN PENCAPAIAN',
      title: 'Konsisten hari ini,\nlebih dekat esok hari.',
      description: 'Ketika target tercapai, tandai sebagai selesai dan nikmati rasa puas dari progres yang kamu bangun sendiri.',
      color: Color(0xFFF0EAF9),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    final completed = await widget.onComplete();
    if (!mounted) return;
    if (!completed) {
      setState(() => _isCompleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onboarding gagal disimpan. Coba lagi.')),
      );
    }
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Nabung.in',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF16856B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _isCompleting ? null : _finish,
                      child: const Text('Lewati'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: _pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 7,
                        width: index == _currentPage ? 24 : 7,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? const Color(0xFF16856B)
                              : const Color(0xFFB7E2D3),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isCompleting ? null : _next,
                      child: _isCompleting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isLastPage ? 'Mulai menabung' : 'Lanjut'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final Color color;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 190,
                width: 190,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  size: 86,
                  color: const Color(0xFF16856B),
                ),
              ),
              const SizedBox(height: 38),
              Text(
                data.eyebrow,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF16856B),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
