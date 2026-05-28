import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radioflow/l10n/app_localizations.dart';

import '../bloc/favorites_cubit.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.station, this.size = 24});

  final Station station;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (a, b) =>
          a.isFavorite(station.uuid) != b.isFavorite(station.uuid),
      builder: (context, state) {
        final isFavorite = state.isFavorite(station.uuid);
        final l10n = AppLocalizations.of(context);
        return IconButton(
          iconSize: size,
          tooltip: isFavorite ? l10n.favoriteRemove : l10n.favoriteAdd,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? AppColors.accent : AppColors.textMuted,
          ),
          onPressed: () => context.read<FavoritesCubit>().toggle(station),
        );
      },
    );
  }
}
