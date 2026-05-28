import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'station_artwork.dart';

class StationTile extends StatelessWidget {
  const StationTile({
    super.key,
    required this.station,
    this.onTap,
    this.trailing,
    this.active = false,
  });

  final Station station;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final flag = Country.flagEmoji(station.countryCode);
    final subtitle = [
      if (flag.isNotEmpty) flag,
      station.country,
      station.primaryTag,
    ].where((e) => e.isNotEmpty).join(' · ');
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: StationArtwork(station: station, size: 48),
      title: Text(
        station.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.titleMedium?.copyWith(
          color: active ? AppColors.accent : null,
        ),
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing,
    );
  }
}
