import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:edit_snap/image_select_screen.dart';


class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(l10n.startScreenTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.helloWorldOn(DateTime.now()),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              child: Text(l10n.start),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ImageSelectScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
