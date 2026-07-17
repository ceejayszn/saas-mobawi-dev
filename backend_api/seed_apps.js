const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  await prisma.application.createMany({
    data: [
      { name: 'Felixpinski POS', packageName: 'com.felixpinski.pos', platform: 'Android', version: '1.0.0', buildNumber: '1', environment: 'production', onlineStatus: 'ONLINE' },
      { name: 'Dynamic App', packageName: 'com.mobawi.dynamic', platform: 'Web', version: '2.1.0', buildNumber: '42', environment: 'production', onlineStatus: 'ONLINE' },
      { name: 'Natty Gym Kiosk', packageName: 'com.nattygym.kiosk', platform: 'Windows', version: '1.1.5', buildNumber: '12', environment: 'staging', onlineStatus: 'OFFLINE' }
    ],
    skipDuplicates: true
  });
  console.log('Seeded applications!');
}
main().catch(console.error).finally(() => prisma.$disconnect());
