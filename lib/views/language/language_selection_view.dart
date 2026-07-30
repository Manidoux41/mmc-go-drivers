import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter01/viewmodels/locale_viewmodel.dart';
import 'package:flutter01/config/colors.dart';

class LanguageSelectionView extends StatelessWidget {
  const LanguageSelectionView({super.key});

  final List<Map<String, String>> languages = const [
    {'code': 'fr', 'name': 'Français', 'native': 'Français', 'flag': '🇫🇷'},
    {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇺🇸'},
    {'code': 'de', 'name': 'German', 'native': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'es', 'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    {'code': 'zh', 'name': 'Chinese', 'native': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': 'Japanese', 'native': '日本語', 'flag': '🇯🇵'},
    {'code': 'km', 'name': 'Khmer', 'native': 'ភាសាខ្មែរ', 'flag': '🇰🇭'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
  ];

  @override
  Widget build(BuildContext context) {
    final localeVM = Provider.of<LocaleViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/icon/logoMMCGo.png'),
            ),
            const SizedBox(height: 20),
            const Text(
              'MMC Go Drivers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                'Please select your language\nVeuillez choisir votre langue',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = localeVM.locale?.languageCode == lang['code'];

                    return InkWell(
                      onTap: () => localeVM.setLocale(Locale(lang['code']!)),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.tertiaryYellow : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lang['flag']!, style: const TextStyle(fontSize: 30)),
                            const SizedBox(height: 5),
                            Text(
                              lang['native']!,
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryBlue : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (localeVM.locale != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: ElevatedButton(
                  onPressed: () {
                    // Re-triggering notifyListeners via setLocale is enough
                    // but we can also do nothing here as main.dart will switch home.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiaryYellow,
                    foregroundColor: Colors.black87,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'CONTINUE / CONTINUER',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
