import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../../../../app/di.dart';
import '../../audio/audio_controller.dart';

const Map<String, List<double>> _presets = {
  'Normal': [0, 0, 0, 0, 0],
  'Classical': [5, 3, -1, 3, 4],
  'Dance': [6, 2, 0, 2, 5],
  'Flat': [0, 0, 0, 0, 0],
  'Folk': [3, 1, 0, 1, 2],
  'Jazz': [4, 2, -1, 2, 4],
  'Rock': [5, 2, -1, 2, 5],
  'Vocal': [-2, 1, 4, 2, -1],
};

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  final AndroidEqualizer _eq = getIt<AudioController>().equalizer;
  AndroidEqualizerParameters? _params;
  String _activePreset = '';

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) _load();
  }

  Future<void> _load() async {
    await _eq.setEnabled(true);
    final params = await _eq.parameters;
    if (mounted) setState(() => _params = params);
  }

  void _applyPreset(String name) {
    final params = _params;
    if (params == null) return;
    final curve = _presets[name]!;
    for (var i = 0; i < params.bands.length; i++) {
      final value = curve[i < curve.length ? i : curve.length - 1];
      params.bands[i].setGain(
        value.clamp(params.minDecibels, params.maxDecibels),
      );
    }
    setState(() => _activePreset = name);
  }

  void _reset() => _applyPreset('Flat');

  String _freqLabel(double hz) =>
      hz >= 1000 ? '${(hz / 1000).round()}k' : hz.round().toString();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.equalizerTagline.toUpperCase(), style: textTheme.labelSmall),
            Text(l10n.equalizer, style: textTheme.titleLarge),
          ],
        ),
        actions: [
          if (Platform.isAndroid && _params != null)
            TextButton(onPressed: _reset, child: Text(l10n.reset)),
        ],
      ),
      body: SafeArea(
        top: false,
        child: !Platform.isAndroid
            ? _Unavailable(message: l10n.equalizerUnavailable)
            : _params == null
            ? const Center(child: CircularProgressIndicator())
            : _content(context, _params!),
      ),
    );
  }

  Widget _content(BuildContext context, AndroidEqualizerParameters params) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(l10n.equalizerDesc, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              for (final band in params.bands)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 42,
                        child: Text(
                          _freqLabel(band.centerFrequency),
                          style: textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          min: params.minDecibels,
                          max: params.maxDecibels,
                          value: band.gain.clamp(
                            params.minDecibels,
                            params.maxDecibels,
                          ),
                          onChanged: (value) {
                            band.setGain(value);
                            setState(() => _activePreset = '');
                          },
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${band.gain >= 0 ? '+' : ''}${band.gain.toStringAsFixed(1)}',
                          textAlign: TextAlign.right,
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.presets.toUpperCase(), style: textTheme.labelSmall),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 3.4,
          children: [
            for (final name in _presets.keys)
              _PresetChip(
                label: name,
                selected: _activePreset == name,
                onTap: () => _applyPreset(name),
              ),
          ],
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.35)
                : AppColors.line,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: selected ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.equalizer_rounded,
              size: 44,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
