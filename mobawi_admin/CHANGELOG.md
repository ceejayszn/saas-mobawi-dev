# Changelog

All notable changes to the `mobawi_admin` project will be documented in this file.

## [1.1.0+1] - 2026-07-16

### Added
- Rebuilt God Mode CEO dashboard screen to match Fillio Design layout structure in premium Dark Mode.
- Implemented double line graphs utilizing `fl_chart` to track active workspaces and traffic trends.
- Implemented full Subscriptions and Billing module screen featuring MRR/ARR KPIs, active packages list, overdue/paid invoices overview, and real-time transaction ledger.
- Implemented Security Command Center screen with live access session controls, threat alerts severity indicators, dynamic IP blacklist block forms, and proxy unban policies.
- Implemented global configuration settings screen with webhook toggle rules, rate limits index, environment details list, and custom server URL parameter adjustments.
- Implemented infrastructure and developer screen featuring real Neon PostgreSQL cluster metrics, links to developer portals, and a live stdout logging console window.
- Implemented AI Center screen with total execution request charts, cost estimates in USD, model breakdowns (Gemini 1.5 Pro vs Flash), and custom fl_chart graph.
- Implemented Co-Founder AI Assistant live chat screen with user message bubbles, prompt chips, and Gemini query routing backend.
- Implemented Website integrations panel with Cloudflare traffic visitor metrics and SSL certificate details.

### Fixed
- Fixed Switch activeColor deprecation warning in settings_screen.dart.
- Removed unused local variables in god_mode_screen.dart and ai_assistant_screen.dart.
- Passed 100% clean static analyzer check.
