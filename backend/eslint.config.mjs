// @ts-check
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  {
    ignores: [
      "dist/**",
      "node_modules/**",
      "src/generated/**",
      "jest.config.js",
    ],
  },
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      // RLS ENFORCEMENT: forbid direct Prisma access outside the RLS context layer.
      // All DB access MUST go through withUserContext/withAdminContext/withSystemContext
      // (see patterns_library/database + .claude/skills/rls-patterns).
      "no-restricted-syntax": [
        "error",
        {
          selector: "MemberExpression[object.name='prisma']",
          message:
            "Direct prisma.* access is forbidden. Use withUserContext / withAdminContext / withSystemContext from src/lib/rls-context.",
        },
      ],
    },
  },
  {
    // The RLS layer + seed/maintenance scripts may touch the raw client.
    files: ["src/lib/prisma.ts", "src/lib/rls-context.ts", "prisma/**/*.ts"],
    rules: {
      "no-restricted-syntax": "off",
    },
  },
);
