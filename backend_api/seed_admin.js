const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  const hashedPassword = await bcrypt.hash('kali', 10);
  
  const superAdmin = await prisma.user.upsert({
    where: { email: 'admin@mobawi.com' },
    update: { password: hashedPassword, role: 'SUPER_ADMIN' },
    create: {
      email: 'admin@mobawi.com',
      password: hashedPassword,
      name: 'Kali Admin',
      role: 'SUPER_ADMIN',
    }
  });
  
  console.log('Super admin seeded!', superAdmin.email);
}
main().catch(console.error).finally(() => prisma.$disconnect());
