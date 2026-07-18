import { PrismaClient } from '@prisma/client';
import { hashPassword, generateSalt } from './utils/crypto';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // 1. Create or verify Business 'felixpinski'
  let business = await prisma.business.findUnique({
    where: { id: 'felixpinski' },
  });

  if (!business) {
    business = await prisma.business.create({
      data: {
        id: 'felixpinski',
        name: 'Copy App',
        type: 'HOTEL',
        status: 'ACTIVE',
      },
    });
    console.log(`Created Business: ${business.name} (${business.id})`);
  } else {
    console.log(`Business ${business.name} already exists.`);
  }

  // 2. Create Users
  const usersToSeed = [
    {
      username: 'admin',
      password: 'kali',
      role: 'nexus_admin',
    },
    {
      username: 'felixpinski_pos',
      password: 'felixpinski_pos',
      role: 'cashier',
    },
    {
      username: 'felixpinski_boss',
      password: '123456',
      role: 'manager',
    },
  ];

  for (const u of usersToSeed) {
    const existingUser = await prisma.user.findUnique({
      where: { username: u.username },
    });

    if (!existingUser) {
      const salt = generateSalt();
      // We will store the hashed password in "password" column.
      // Wait, is there a salt column in the schema? Let's check requireAuth or User model.
      // Schema model User only has "password" column. It doesn't have a separate "salt" column.
      // To store salted hash when there is no salt column, we can store it as "salt:hash"!
      const hash = hashPassword(u.password, salt);
      const combined = `${salt}:${hash}`;

      await prisma.user.create({
        data: {
          username: u.username,
          password: combined,
          role: u.role,
          businessId: 'felixpinski',
          isActive: true,
        },
      });
      console.log(`Created User: ${u.username} (Role: ${u.role})`);
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
