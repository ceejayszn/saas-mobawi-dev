const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  await prisma.user.update({
    where: { username: 'admin' },
    data: { role: 'SUPER_ADMIN' }
  });
  console.log('Admin role updated to SUPER_ADMIN!');
}
main().catch(console.error).finally(() => prisma.$disconnect());
