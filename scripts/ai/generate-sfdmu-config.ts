import Anthropic from "@anthropic-ai/sdk";
import * as fs from "fs";
import * as readline from "readline";

// ============================================================================
// Types & Interfaces
// ============================================================================

interface SFDMUConfig {
    objects: ObjectConfig[];
}

interface ObjectConfig {
    query: string;
    operation: string;
    externalId: string;
}

// ============================================================================
// Main Function
// ============================================================================

async function generateSFDMUConfig(): Promise<void> {
    console.log("🤖 SFDMU Config Generator");
    console.log("=========================\n");

    // 1. Check API Key
    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) {
        console.error("❌ Error: ANTHROPIC_API_KEY environment variable is not set");
        process.exit(1);
    }

    // 2. Get user requirement
    const requirement = await promptUser(
        "📝 Describe your test data requirements:\n   (e.g., '10 Accounts with 5 Contacts each, all in Japan')\n\n> "
    );

    if (!requirement.trim()) {
        console.log("❌ No requirement provided. Exiting.");
        return;
    }

    // 3. Generate with AI
    console.log("\n🧠 Generating SFDMU configuration with Claude...\n");

    const client = new Anthropic({ apiKey });
    const config = await generateConfigWithAI(client, requirement);

    // 4. Save to file
    const outputPath = "data/export.json";
    const outputDir = "data";

    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    fs.writeFileSync(outputPath, config, "utf-8");

    console.log(`✅ SFDMU config saved to: ${outputPath}\n`);
    console.log("📖 Next steps:");
    console.log("   1. Review the generated config:");
    console.log(`      cat ${outputPath}`);
    console.log("   2. Export data:");
    console.log("      sf hardis:org:data:export");
    console.log("   3. Import to target org:");
    console.log("      sf hardis:org:data:import");
}

// ============================================================================
// Helper Functions
// ============================================================================

async function generateConfigWithAI(
    client: Anthropic,
    requirement: string
): Promise<string> {
    const prompt = `You are a Salesforce data migration expert. Generate a valid SFDMU export.json configuration for the following requirement:

"${requirement}"

SFDMU export.json format:
\`\`\`json
{
  "objects": [
    {
      "query": "SELECT Id, Name, ... FROM Account WHERE ...",
      "operation": "Upsert",
      "externalId": "Name"
    },
    {
      "query": "SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE ...",
      "operation": "Upsert",
      "externalId": "Email"
    }
  ]
}
\`\`\`

Important rules:
1. Include all necessary fields for relationships
2. Maintain referential integrity (parent objects first)
3. Use appropriate WHERE clauses for filtering
4. Choose correct externalId fields
5. Use Upsert operation by default
6. Include Id field in all queries

Return ONLY the valid JSON, no explanation.`;

    try {
        const response = await client.messages.create({
            model: "claude-3-7-sonnet-20250219",
            max_tokens: 4096,
            messages: [{
                role: "user",
                content: prompt
            }]
        });

        const firstContent = response.content[0];
        if (firstContent.type !== "text") {
            throw new Error("Unexpected response type from AI");
        }

        // Extract JSON from response
        const text = firstContent.text;
        const jsonMatch = text.match(/\{[\s\S]*\}/);

        if (!jsonMatch) {
            throw new Error("No valid JSON found in AI response");
        }

        // Validate JSON
        JSON.parse(jsonMatch[0]);

        return jsonMatch[0];
    } catch (error) {
        console.error("❌ Failed to generate config with AI:", error);
        throw error;
    }
}

function promptUser(query: string): Promise<string> {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
    });

    return new Promise((resolve) => {
        rl.question(query, (answer) => {
            rl.close();
            resolve(answer.trim());
        });
    });
}

// ============================================================================
// CLI Entry Point
// ============================================================================

generateSFDMUConfig().catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
});
