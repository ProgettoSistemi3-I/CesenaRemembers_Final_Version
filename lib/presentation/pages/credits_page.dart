import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_palette.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Riconoscimenti',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.olive.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cesena Remembers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Realizzato con passione per preservare la memoria storica della nostra città.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 48),

          // 🔴 NUOVA SEZIONE: FINANZIAMENTO
          const _SectionLabel('Finanziamento'),
          const SizedBox(height: 16),
          _CreditsCard(
            children: [
              _CreditRow(
                imageAsset: 'assets/icon/diplo_logo.png', // <-- Assicurati di avere l'immagine qui
                fallbackIcon: Icons.public,
                title: 'Rappresentanze Diplomatiche Tedesche in Italia',
                subtitle: 'Sviluppato grazie al loro prezioso contributo',
                accent: AppPalette.tan,
                onTap: () => launchUrl(
                  Uri.parse('https://italien.diplo.de/it-it'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // SEZIONE: IL TEAM
          const _SectionLabel('Il Team'),
          const SizedBox(height: 16),
          _CreditsCard(
            children: [
              _CreditRow(
                icon: Icons.code_rounded,
                title: 'Lorenzo Ostolani',
                subtitle: 'Sviluppo & Architettura',
                accent: AppPalette.olive,
                onTap: () => launchUrl(
                  Uri.parse('https://github.com/lorenzoostolani'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const _ThinDivider(),
              _CreditRow(
                icon: Icons.code_rounded,
                title: 'Luca Bazzocchi',
                subtitle: 'Sviluppo & Architettura',
                accent: AppPalette.olive,
                onTap: () => launchUrl(
                  Uri.parse('https://github.com/ilMastroDeiBug'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // SEZIONE: RINGRAZIAMENTI
          const _SectionLabel('Ringraziamenti'),
          const SizedBox(height: 16),
          _CreditsCard(
            children: [
              const _CreditRow(
                icon: Icons.school_outlined,
                title: 'Prof. David Veneti',
                subtitle: 'Docente Referente',
                accent: AppPalette.moss,
                isStatic: true,
              ),
              const _ThinDivider(),
              const _CreditRow(
                icon: Icons.groups_outlined,
                title: 'Classe 3I',
                subtitle: 'Supporto e Ideazione',
                accent: AppPalette.tan,
                isStatic: true,
              ),
              const _ThinDivider(),
              _CreditRow(
                imageAsset: 'assets/icon/logoScuola.png', // 🔴 Logo scuola
                fallbackIcon: Icons.account_balance_outlined,
                title: 'ITT Blaise Pascal',
                subtitle: 'Visita il sito web dell\'istituto',
                accent: AppPalette.olive,
                onTap: () => launchUrl(
                  Uri.parse('https://www.ispascalcomandini.it/'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMPONENTI INTERNI SPECIFICI PER I CREDITI
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppPalette.olive,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CreditsCard extends StatelessWidget {
  final List<Widget> children;
  const _CreditsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(children: children),
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 68),
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }
}

class _CreditRow extends StatelessWidget {
  final IconData? icon;
  final String? imageAsset;
  final IconData? fallbackIcon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback? onTap;
  final bool isStatic;

  const _CreditRow({
    this.icon,
    this.imageAsset,
    this.fallbackIcon,
    required this.title,
    required this.subtitle,
    required this.accent,
    this.onTap,
    this.isStatic = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Logica intelligente per caricare l'immagine o l'icona di fallback
    Widget imageWidget;
    if (imageAsset != null) {
      imageWidget = Image.asset(
        imageAsset!,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          fallbackIcon ?? Icons.error,
          color: accent,
          size: 22,
        ),
      );
    } else {
      imageWidget = Icon(icon, color: accent, size: 22);
    }

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: imageWidget,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isStatic && onTap != null)
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
        ],
      ),
    );

    if (isStatic) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: content,
      ),
    );
  }
}