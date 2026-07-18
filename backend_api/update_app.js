const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  await prisma.application.updateMany({
    where: { packageName: 'com.mobawi.dynamic' },
    data: { name: 'Delights Juice Shop', packageName: 'com.delights.juiceshop' }
  });
  console.log('App name updated!');
}
main().catch(console.error).finally(() => prisma.$disconnect());
