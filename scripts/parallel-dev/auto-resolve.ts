import Anthropic from "@anthropic-ai/sdk";
import { execSync } from "child_process";
import * as fs from "fs";
import * as path from "path";
import * as readline from "readline";

// ============================================================================
// Types & Interfaces
// ============================================================================

interface ResolveOptions {
    mode: "advisor" | "interactive" | "auto";
    showReasoning: boolean;
}

interface ConflictFile {
    path: string;
    content: string;
}

interface ConflictAnalysis {
    file: ConflictFile;
    type: string;
    complexity: "Low" | "Medium" | "High";
    risk: "Low" | "Medium" | "High";
    reasoning: string;
    suggestion: string;
}

// ============================================================================
// Main Function
// ============================================================================

async function resolveConflicts(options: ResolveOptions): Promise<void> {
    console.log(`🤖 AI Conflict Advisor [${options.mode.toUpperCase()} mode]\n`);

    // 1. API Key確認
    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) {
        console.error("❌ Error: ANTHROPIC_API_KEY environment variable is not set");
        console.log("   Set it with: export ANTHROPIC_API_KEY='your-api-key'");
        process.exit(1);
    }

    const client = new Anthropic({ apiKey });

    // 2. Auto modeの警告
    if (options.mode === "auto") {
        const confirmed = await confirmAutoMode();
        if (!confirmed) {
            console.log("Aborted.");
            return;
        }
    }

    // 3. コンフリクト検出
    console.log("🔍 Detecting conflicts...\n");
    const conflicts = getConflictFiles();

    if (conflicts.length === 0) {
        console.log("✅ No conflicts found");
        return;
    }

    console.log(`Found ${conflicts.length} conflicted file(s)\n`);

    // 4. 各コンフリクトを処理
    for (let i = 0; i < conflicts.length; i++) {
        const conflict = conflicts[i];
        console.log(`${"=".repeat(60)}`);
        console.log(`📝 Conflict ${i + 1}/${conflicts.length}: ${conflict.path}`);
        console.log(`${"=".repeat(60)}\n`);

        // AIで分析
        const analysis = await analyzeConflict(client, conflict, options.showReasoning);

        // モード別処理
        switch (options.mode) {
            case "advisor":
                await handleAdvisorMode(analysis);
                break;
            case "interactive":
                await handleInteractiveMode(analysis);
                break;
            case "auto":
                await handleAutoMode(analysis);
                break;
        }

        console.log("\n");
    }

    console.log("✅ Conflict advisor completed!");
}

// ============================================================================
// Conflict Detection
// ============================================================================

function getConflictFiles(): ConflictFile[] {
    try {
        const statusOutput = execSync("jj status", { encoding: "utf-8" });
        const conflictLines = statusOutput
            .split("\n")
            .filter((line) => line.trim().startsWith("C "));

        const files: ConflictFile[] = [];
        for (const line of conflictLines) {
            const match = line.match(/^C\s+(.+)$/);
            if (match) {
                const filePath = match[1].trim();
                if (fs.existsSync(filePath)) {
                    const content = fs.readFileSync(filePath, "utf-8");
                    files.push({ path: filePath, content });
                }
            }
        }

        return files;
    } catch (error) {
        return [];
    }
}

// ============================================================================
// AI Analysis
// ============================================================================

async function analyzeConflict(
    client: Anthropic,
    conflict: ConflictFile,
    showReasoning: boolean
): Promise<ConflictAnalysis> {
    const fileExt = path.extname(conflict.path);
    const language = getLanguage(fileExt);

    const prompt = `You are an expert Salesforce code conflict analyzer.

Analyze this ${language} file conflict and provide:
1. Conflict type (e.g., "Method additions", "Logic changes", etc.)
2. Complexity assessment (Low/Medium/High)
3. Risk level (Low/Medium/High)
4. Detailed reasoning
5. Resolved code suggestion

File: ${conflict.path}

Conflicted Content:
\`\`\`${language}
${conflict.content}
\`\`\`

Respond in JSON format:
{
  "type": "conflict type",
  "complexity": "Low|Medium|High",
  "risk": "Low|Medium|High",
  "reasoning": "why this conflict occurred and how to resolve",
  "resolvedCode": "complete resolved code without conflict markers"
}`;

    try {
        const response = await client.messages.create({
            model: "claude-3-5-sonnet-20241022",
            max_tokens: 8192,
            messages: [{ role: "user", content: prompt }],
        });

        const jsonMatch = response.content[0].text.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
            throw new Error("Failed to parse AI response");
        }

        const result = JSON.parse(jsonMatch[0]);

        return {
            file: conflict,
            type: result.type,
            complexity: result.complexity,
            risk: result.risk,
            reasoning: result.reasoning,
            suggestion: result.resolvedCode,
        };
    } catch (error) {
        console.error(`❌ Failed to analyze ${conflict.path}:`, error);
        throw error;
    }
}

// ============================================================================
// Mode Handlers
// ============================================================================

async function handleAdvisorMode(analysis: ConflictAnalysis): Promise<void> {
    console.log("📊 Conflict Analysis:");
    console.log(`  Type:       ${analysis.type}`);
    console.log(`  Complexity: ${analysis.complexity}`);
    console.log(`  Risk:       ${analysis.risk}`);
    console.log("");

    console.log("💡 Reasoning:");
    console.log(`  ${analysis.reasoning}`);
    console.log("");

    console.log("✨ AI Suggestion:");
    console.log("  (Use option 1 below to view full code)");
    console.log("");

    console.log("❓ Actions:");
    console.log("  1. Show full suggested code");
    console.log("  2. Copy suggestion to clipboard");
    console.log("  3. Next conflict");
    console.log("  q. Quit");

    const choice = await promptUser("\nChoose [1/2/3/q]: ");

    switch (choice.toLowerCase()) {
        case "1":
            console.log("\n" + "─".repeat(60));
            console.log(analysis.suggestion);
            console.log("─".repeat(60));
            await promptUser("\nPress Enter to continue...");
            break;
        case "2":
            // クリップボードにコピー（環境依存）
            try {
                execSync(`echo "${analysis.suggestion.replace(/"/g, '\\"')}" | pbcopy`);
                console.log("✅ Copied to clipboard");
            } catch {
                console.log("⚠️  Clipboard not available. Suggestion:");
                console.log(analysis.suggestion);
            }
            break;
        case "3":
            // 次へ
            break;
        case "q":
            console.log("Quitting...");
            process.exit(0);
            break;
    }
}

async function handleInteractiveMode(analysis: ConflictAnalysis): Promise<void> {
    console.log("📊 Analysis:");
    console.log(`  Type: ${analysis.type} | Complexity: ${analysis.complexity} | Risk: ${analysis.risk}`);
    console.log("");

    console.log("💡 Reasoning:");
    console.log(`  ${analysis.reasoning}`);
    console.log("");

    console.log("✨ Suggested Resolution:");
    const preview = analysis.suggestion.split("\n").slice(0, 10).join("\n");
    console.log(preview);
    console.log(`  ... (${analysis.suggestion.split("\n").length} lines total)\n`);

    console.log("❓ Apply this suggestion?");
    console.log("  [y] Yes, apply and continue");
    console.log("  [d] Show full diff");
    console.log("  [n] No, skip this conflict");
    console.log("  [q] Quit");

    const choice = await promptUser("\nChoose [y/d/n/q]: ");

    switch (choice.toLowerCase()) {
        case "y":
            applyResolution(analysis);
            console.log(`✅ Applied resolution to ${analysis.file.path}`);
            break;
        case "d":
            console.log("\n" + "─".repeat(60));
            console.log(analysis.suggestion);
            console.log("─".repeat(60));
            await handleInteractiveMode(analysis); // 再度プロンプト
            break;
        case "n":
            console.log("⏭️  Skipped");
            break;
        case "q":
            console.log("Quitting...");
            process.exit(0);
            break;
    }
}

async function handleAutoMode(analysis: ConflictAnalysis): Promise<void> {
    console.log(`⚡ Auto-resolving: ${analysis.file.path}`);
    console.log(`   Type: ${analysis.type} | Risk: ${analysis.risk}`);

    applyResolution(analysis);
    console.log(`✅ Resolved`);
}

// ============================================================================
// Helper Functions
// ============================================================================

function applyResolution(analysis: ConflictAnalysis): void {
    fs.writeFileSync(analysis.file.path, analysis.suggestion, "utf-8");
}

async function confirmAutoMode(): Promise<boolean> {
    console.log("⚠️  WARNING: AUTO MODE");
    console.log("This will automatically resolve ALL conflicts without confirmation.");
    console.log("This mode is experimental and intended for Phase 6-9 preparation.\n");

    const answer = await promptUser("Are you absolutely sure? Type 'YES' to continue: ");
    return answer === "YES";
}

function getLanguage(ext: string): string {
    const langMap: Record<string, string> = {
        ".cls": "apex",
        ".trigger": "apex",
        ".js": "javascript",
        ".ts": "typescript",
        ".html": "html",
        ".css": "css",
        ".xml": "xml",
        ".json": "json",
        ".sh": "bash",
        ".md": "markdown",
    };

    return langMap[ext] || "text";
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

const args = process.argv.slice(2);
const mode = args.includes("--interactive")
    ? "interactive"
    : args.includes("--auto")
        ? "auto"
        : "advisor";

const showReasoning = !args.includes("--no-reasoning");

resolveConflicts({ mode, showReasoning }).catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
});
