import Anthropic from "@anthropic-ai/sdk";
import * as fs from "fs";
import * as path from "path";

// ============================================================================
// Types & Interfaces
// ============================================================================

interface TranslateOptions {
    inputPath: string;
    outputPath: string;
}

// ============================================================================
// Main Function
// ============================================================================

async function translateDocumentation(options: TranslateOptions): Promise<void> {
    console.log("🤖 Documentation Translator");
    console.log("===========================\n");

    // 1. Check API Key
    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) {
        console.error("❌ Error: ANTHROPIC_API_KEY environment variable is not set");
        process.exit(1);
    }

    // 2. Load English documentation
    console.log(`📄 Loading documentation: ${options.inputPath}`);

    if (!fs.existsSync(options.inputPath)) {
        console.error(`❌ Error: Documentation file not found: ${options.inputPath}`);
        console.log("\n💡 Tip: Run 'sf hardis:doc:project2markdown --use-ai' first");
        process.exit(1);
    }

    const englishDoc = fs.readFileSync(options.inputPath, "utf-8");

    // 3. Translate with AI
    console.log("🧠 Translating to Japanese with Claude...\n");

    const client = new Anthropic({ apiKey });
    const japaneseDoc = await translateWithAI(client, englishDoc);

    // 4. Save Results
    const outputDir = path.dirname(options.outputPath);
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    fs.writeFileSync(options.outputPath, japaneseDoc, "utf-8");

    console.log(`✅ Japanese documentation saved to: ${options.outputPath}\n`);
    console.log("📖 View the documentation:");
    console.log(`   cat ${options.outputPath}`);
}

// ============================================================================
// Helper Functions
// ============================================================================

async function translateWithAI(
    client: Anthropic,
    englishDoc: string
): Promise<string> {
    const prompt = `You are a professional Japanese translator specializing in technical documentation for Salesforce development.

Translate the following English documentation to Japanese:

${englishDoc}

Translation guidelines:
1. Maintain technical accuracy
2. Keep code blocks and examples unchanged
3. Translate comments within code to Japanese
4. Use appropriate Japanese technical terminology
5. Maintain markdown formatting
6. Keep URLs and file paths unchanged
7. Translate section headings and descriptions
8. Use natural Japanese technical writing style

Return ONLY the translated Japanese markdown, no explanation.`;

    try {
        const response = await client.messages.create({
            model: "claude-3-7-sonnet-20250219",
            max_tokens: 16000,
            messages: [{
                role: "user",
                content: prompt
            }]
        });

        const firstContent = response.content[0];
        if (firstContent.type !== "text") {
            throw new Error("Unexpected response type from AI");
        }

        return firstContent.text;
    } catch (error) {
        console.error("❌ Failed to translate with AI:", error);
        throw error;
    }
}

// ============================================================================
// CLI Entry Point
// ============================================================================

const args = process.argv.slice(2);

const inputPath = args[0] || "docs/generated/project-documentation.md";
const outputPath = args[1] || "docs/generated/project-documentation-ja.md";

translateDocumentation({
    inputPath,
    outputPath
}).catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
});
