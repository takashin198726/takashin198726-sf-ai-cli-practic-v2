import Anthropic from "@anthropic-ai/sdk";
import * as fs from "fs";
import * as path from "path";

// ============================================================================
// Types & Interfaces
// ============================================================================

interface AnalysisOptions {
    reportPath: string;
    outputPath: string;
    language: "en" | "ja";
}

interface LintIssue {
    severity: string;
    file: string;
    line: number;
    rule: string;
    message: string;
}

// ============================================================================
// Main Function
// ============================================================================

async function analyzeLintReport(options: AnalysisOptions): Promise<void> {
    console.log("🤖 AI Lint Analysis");
    console.log("==================\n");

    // 1. Check API Key
    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) {
        console.error("❌ Error: ANTHROPIC_API_KEY environment variable is not set");
        process.exit(1);
    }

    // 2. Load Mega-Linter Report
    console.log(`📄 Loading report: ${options.reportPath}`);

    if (!fs.existsSync(options.reportPath)) {
        console.error(`❌ Error: Report file not found: ${options.reportPath}`);
        console.log("\n💡 Tip: Run 'npm run quality:lint' first to generate the report");
        process.exit(1);
    }

    const reportContent = fs.readFileSync(options.reportPath, "utf-8");
    let report: any;

    try {
        report = JSON.parse(reportContent);
    } catch (error) {
        console.error("❌ Error: Invalid JSON in report file");
        process.exit(1);
    }

    // 3. Extract Issues
    const issues = extractIssues(report);

    if (issues.length === 0) {
        console.log("✅ No issues found! Your code is clean.");
        return;
    }

    console.log(`Found ${issues.length} issue(s)\n`);

    // 4. Analyze with AI
    console.log("🧠 Analyzing with Claude...");

    const client = new Anthropic({ apiKey });
    const analysis = await analyzeWithAI(client, issues, report, options.language);

    // 5. Save Results
    const outputDir = path.dirname(options.outputPath);
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    fs.writeFileSync(options.outputPath, analysis, "utf-8");

    console.log(`\n✅ AI analysis saved to: ${options.outputPath}`);
    console.log("\n📖 View the analysis:");
    console.log(`   cat ${options.outputPath}`);
}

// ============================================================================
// Helper Functions
// ============================================================================

function extractIssues(report: any): LintIssue[] {
    const issues: LintIssue[] = [];

    // Mega-Linter report structure varies by linter
    // Extract from common formats
    if (report.linters) {
        for (const linter of report.linters) {
            if (linter.files) {
                for (const file of linter.files) {
                    if (file.errors) {
                        for (const error of file.errors) {
                            issues.push({
                                severity: error.severity || linter.status,
                                file: file.file,
                                line: error.line || 0,
                                rule: error.rule || linter.linter_name,
                                message: error.message || error.desc || "No description"
                            });
                        }
                    }
                }
            }
        }
    }

    // Fallback: Parse from summary if detailed info not available
    if (issues.length === 0 && report.summary) {
        // Create summary-level issues
        for (const [linterName, linterInfo] of Object.entries(report.summary)) {
            if (typeof linterInfo === 'object' && linterInfo !== null) {
                const info = linterInfo as any;
                if (info.errors > 0 || info.warnings > 0) {
                    issues.push({
                        severity: info.errors > 0 ? "error" : "warning",
                        file: "Multiple files",
                        line: 0,
                        rule: linterName,
                        message: `${info.errors || 0} errors, ${info.warnings || 0} warnings`
                    });
                }
            }
        }
    }

    return issues;
}

async function analyzeWithAI(
    client: Anthropic,
    issues: LintIssue[],
    fullReport: any,
    language: "en" | "ja"
): Promise<string> {
    const isJapanese = language === "ja";

    const prompt = isJapanese ? `
あなたはSalesforce開発のエキスパートです。以下のMega-Linterレポートを分析してください。

## レポート内容
\`\`\`json
${JSON.stringify({ issues, summary: fullReport.summary }, null, 2)}
\`\`\`

以下の形式で分析結果を提供してください：

# 📊 コード品質分析レポート

## 🔴 優先度別の問題

### Critical（緊急）
（重大な問題のみリスト）

### High（高）
（重要な問題のリスト）

### Medium（中）
（中程度の問題のリスト）

### Low（低）
（軽微な問題のリスト）

## 🔧 修正提案

各問題に対して：
1. **問題:** 何が問題か
2. **影響:** なぜ修正すべきか
3. **修正方法:** 具体的なコード例

## 📚 Salesforceベストプラクティス

違反しているベストプラクティスと推奨事項

## 💡 改善推奨事項

コード全体の品質向上のための提案

---

**重要:** 
- 優先度は実際の影響度に基づいて判断
- 修正方法は具体的なコード例を含める
- Salesforce特有の観点を重視
` : `
You are a Salesforce development expert. Analyze this Mega-Linter report.

## Report Content
\`\`\`json
${JSON.stringify({ issues, summary: fullReport.summary }, null, 2)}
\`\`\`

Provide analysis in the following format:

# 📊 Code Quality Analysis Report

## 🔴 Issues by Priority

### Critical
(List critical issues only)

### High
(List high priority issues)

### Medium
(List medium priority issues)

### Low
(List low priority issues)

## 🔧 Fix Suggestions

For each issue:
1. **Problem:** What is the issue
2. **Impact:** Why it should be fixed
3. **Solution:** Specific code example

## 📚 Salesforce Best Practices

Violated best practices and recommendations

## 💡 Improvement Recommendations

Suggestions for overall code quality improvement

---

**Important:**
- Prioritize based on actual impact
- Include specific code examples in solutions
- Focus on Salesforce-specific considerations
`;

    try {
        const response = await client.messages.create({
            model: "claude-3-7-sonnet-20250219",
            max_tokens: 8192,
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
        console.error("❌ Failed to analyze with AI:", error);
        throw error;
    }
}

// ============================================================================
// CLI Entry Point
// ============================================================================

const args = process.argv.slice(2);

const language = args.includes("--ja") ? "ja" : "en";
const positionalArgs = args.filter(arg => !arg.startsWith("--"));
const reportPath = positionalArgs[0] || "megalinter-reports/megalinter-report.json";
const outputPath = positionalArgs[1] || "megalinter-reports/ai-analysis.md";

analyzeLintReport({
    reportPath,
    outputPath,
    language
}).catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
});
