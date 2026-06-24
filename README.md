# Hotel POS System

This repository contains the completely refactored POS system.

## Project Structure
- `/operations_app`: The original POS interface stripped of complex UI changes and M-Pesa logic. It is strictly meant for data-entry.
- `/boss_app`: A premium, dark-themed analytical dashboard for management oversight. Contains interactive charts, system health monitoring, and activity logging.
- `/backend_api`: A centralized Node.js/Express backend that provides a RESTful API and connects to PostgreSQL using Prisma ORM.

## How to run locally

### Backend
```bash
cd backend_api
npm install
npx prisma generate
npx ts-node src/index.ts
```

### Operations App
```bash
cd operations_app
flutter run
```

### Boss App
```bash
cd boss_app
flutter run -d chrome
```

## History
This repository includes a full rollback to a simpler architecture per management request, moving all analytics and executive functions into an independent module. Git tracking was introduced to prevent future source code loss.
