import { PrismaClient } from '@prisma/client';
import { hashPassword, generateSalt } from './utils/crypto';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  const businesses = [
    { id: 'felixpinski', name: 'Copy App', type: 'HOTEL' },
    { id: 'natty_gym', name: 'Natty Gym', type: 'GYM' },
    { id: 'delights_juice_shop', name: 'Delights Juice Shop', type: 'RESTAURANT' },
    { id: 'base_application', name: 'Base Application', type: 'RETAIL' },
  ];

  for (const b of businesses) {
    let business = await prisma.business.findUnique({
      where: { id: b.id },
    });

    if (!business) {
      business = await prisma.business.create({
        data: {
          id: b.id,
          name: b.name,
          type: b.type,
          status: 'ACTIVE',
        },
      });
      console.log(`Created Business: ${business.name} (${business.id})`);
    } else {
      console.log(`Business ${business.name} already exists.`);
    }
  }

  // 2. Create Users
  const usersToSeed = [
    {
      username: 'admin',
      password: 'kali',
      role: 'nexus_admin',
      businessId: 'felixpinski', // Admin can be attached anywhere, or global if schema allows
    },
    ...businesses.flatMap((b) => [
      {
        username: `${b.id}_pos`,
        password: `${b.id}_pos`,
        role: 'cashier',
        businessId: b.id,
      },
      {
        username: `${b.id}_boss`,
        password: '123456',
        role: 'manager',
        businessId: b.id,
      },
    ]),
  ];

  for (const u of usersToSeed) {
    const existingUser = await prisma.user.findUnique({
      where: { username: u.username },
    });

    if (!existingUser) {
      const salt = generateSalt();
      const hash = hashPassword(u.password, salt);
      const combined = `${salt}:${hash}`;

      await prisma.user.create({
        data: {
          username: u.username,
          password: combined,
          role: u.role,
          businessId: u.businessId,
          isActive: true,
        },
      });
      console.log(`Created User: ${u.username} (Role: ${u.role}, Business: ${u.businessId})`);
    } else {
      console.log(`User ${u.username} already exists.`);
    }
  }

  console.log('Seeding finished successfully.');
}

main()
  .catch((e) => {
    console.error('Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
