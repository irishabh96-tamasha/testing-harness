/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/src"],
  testMatch: ["**/*.test.ts"],
  clearMocks: true,
  setupFiles: ["dotenv/config"],
  // The DB-backed tests hold a Prisma connection open; let Jest exit cleanly.
  forceExit: true,
};
