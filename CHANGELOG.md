# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-07-15
### Added
- Rebuilt Splash Screen in pure black, centering the Copy App logo, featuring Helvetica corporate typography, and integrating a smooth 0% to 96% progress bar transition.
- Implemented `GlobalHeader` reusable widget used consistently across screens, featuring a rounded logo container, styled Helvetica typography, and an Exit/Logout confirmation flow.
- Added 5 new production-grade detail screens: `SalesDetailScreen`, `OrdersDetailScreen`, `ExpensesDetailScreen`, `DeliveriesDetailScreen`, and `InventoryDetailScreen` mapped from the Home Dashboard overview cards.
- Integrated search bar, sorting, filtering, statistics overview, and empty state illustrations on all detail screens.

### Changed
- Rebuilt corporate typography styling across the application to utilize Helvetica (or platform equivalent fallback).
- Updated Home Dashboard Grid to display cards with navigation link handlers instead of modal dialogs.
- Repositioned actions on `ExpensesScreen` to use modern floating action buttons (FABs).
- Refactored `OrdersScreen` to place TabBar inside a clean body layout under the unified `GlobalHeader`.

