#!/usr/bin/env python3
"""
Claude Code Cost Tracker

Tracks Claude Code session costs, token usage, and performance metrics.
Saves detailed reports as markdown files for analysis and budgeting.

Usage:
    ./claude-cost-tracker.py start --session-name "jwt-auth-development"
    ./claude-cost-tracker.py log --tokens-in 1500 --tokens-out 800 --model "claude-sonnet-4"
    ./claude-cost-tracker.py end --generate-report
"""

import json
import argparse
import datetime
import os
import sys
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional, Tuple
import subprocess

@dataclass
class ModelPricing:
    """Anthropic Claude pricing structure (as of 2025)"""
    input_price_per_1k: float  # Price per 1,000 input tokens
    output_price_per_1k: float  # Price per 1,000 output tokens
    
# Current Anthropic pricing (update as needed)
MODEL_PRICING = {
    "claude-sonnet-4": ModelPricing(3.0, 15.0),  # $3/$15 per 1K tokens
    "claude-opus-4": ModelPricing(15.0, 75.0),   # $15/$75 per 1K tokens  
    "claude-haiku-3": ModelPricing(0.25, 1.25),  # $0.25/$1.25 per 1K tokens
    "claude-sonnet-3.5": ModelPricing(3.0, 15.0), # Legacy pricing
}

@dataclass
class SessionEntry:
    timestamp: str
    operation: str  # "chat", "code_generation", "review", "analysis"
    model: str
    tokens_input: int
    tokens_output: int
    cost_input: float
    cost_output: float
    total_cost: float
    context: str = ""  # What was being worked on
    
@dataclass
class SessionSummary:
    session_id: str
    session_name: str
    start_time: str
    end_time: Optional[str]
    project_path: str
    git_commit_start: Optional[str]
    git_commit_end: Optional[str]
    total_entries: int
    total_tokens_input: int
    total_tokens_output: int
    total_cost: float
    operations: Dict[str, int]  # Count by operation type
    models_used: Dict[str, int]  # Count by model
    entries: List[SessionEntry]

class CostTracker:
    def __init__(self, session_dir: str = ".claude-sessions"):
        self.session_dir = Path(session_dir)
        self.session_dir.mkdir(exist_ok=True)
        self.current_session_file = self.session_dir / "current_session.json"
        
    def calculate_cost(self, model: str, tokens_input: int, tokens_output: int) -> Tuple[float, float, float]:
        """Calculate cost for given token usage"""
        if model not in MODEL_PRICING:
            print(f"Warning: Unknown model {model}, using claude-sonnet-4 pricing")
            model = "claude-sonnet-4"
            
        pricing = MODEL_PRICING[model]
        cost_input = (tokens_input / 1000.0) * pricing.input_price_per_1k
        cost_output = (tokens_output / 1000.0) * pricing.output_price_per_1k
        total_cost = cost_input + cost_output
        
        return cost_input, cost_output, total_cost
    
    def get_git_commit(self) -> Optional[str]:
        """Get current git commit hash"""
        try:
            result = subprocess.run(
                ["git", "rev-parse", "HEAD"], 
                capture_output=True, 
                text=True, 
                cwd="."
            )
            return result.stdout.strip() if result.returncode == 0 else None
        except:
            return None
    
    def start_session(self, session_name: str, context: str = "") -> str:
        """Start a new cost tracking session"""
        session_id = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        
        session = SessionSummary(
            session_id=session_id,
            session_name=session_name,
            start_time=datetime.datetime.now().isoformat(),
            end_time=None,
            project_path=os.getcwd(),
            git_commit_start=self.get_git_commit(),
            git_commit_end=None,
            total_entries=0,
            total_tokens_input=0,
            total_tokens_output=0,
            total_cost=0.0,
            operations={},
            models_used={},
            entries=[]
        )
        
        # Save current session
        with open(self.current_session_file, 'w') as f:
            json.dump(asdict(session), f, indent=2)
        
        print(f"✅ Started session: {session_name} (ID: {session_id})")
        if context:
            print(f"📝 Context: {context}")
        
        return session_id
    
    def log_usage(self, tokens_input: int, tokens_output: int, model: str, 
                  operation: str, context: str = "") -> None:
        """Log token usage for current session"""
        if not self.current_session_file.exists():
            print("❌ No active session. Start a session first with 'start' command.")
            return
        
        # Load current session
        with open(self.current_session_file, 'r') as f:
            session_data = json.load(f)
        
        # Calculate costs
        cost_input, cost_output, total_cost = self.calculate_cost(model, tokens_input, tokens_output)
        
        # Create entry
        entry = SessionEntry(
            timestamp=datetime.datetime.now().isoformat(),
            operation=operation,
            model=model,
            tokens_input=tokens_input,
            tokens_output=tokens_output,
            cost_input=cost_input,
            cost_output=cost_output,
            total_cost=total_cost,
            context=context
        )
        
        # Update session totals
        session_data["entries"].append(asdict(entry))
        session_data["total_entries"] += 1
        session_data["total_tokens_input"] += tokens_input
        session_data["total_tokens_output"] += tokens_output
        session_data["total_cost"] += total_cost
        
        # Update operation counts
        if operation not in session_data["operations"]:
            session_data["operations"][operation] = 0
        session_data["operations"][operation] += 1
        
        # Update model counts
        if model not in session_data["models_used"]:
            session_data["models_used"][model] = 0
        session_data["models_used"][model] += 1
        
        # Save updated session
        with open(self.current_session_file, 'w') as f:
            json.dump(session_data, f, indent=2)
        
        print(f"💰 Logged: {tokens_input}→{tokens_output} tokens, ${total_cost:.4f} ({model})")
        if context:
            print(f"📝 Context: {context}")
    
    def end_session(self, generate_report: bool = True) -> Optional[str]:
        """End current session and optionally generate report"""
        if not self.current_session_file.exists():
            print("❌ No active session to end.")
            return None
        
        # Load current session
        with open(self.current_session_file, 'r') as f:
            session_data = json.load(f)
        
        # Update end time and git commit
        session_data["end_time"] = datetime.datetime.now().isoformat()
        session_data["git_commit_end"] = self.get_git_commit()
        
        # Save final session data
        session_file = self.session_dir / f"{session_data['session_id']}.json"
        with open(session_file, 'w') as f:
            json.dump(session_data, f, indent=2)
        
        # Generate markdown report
        report_file = None
        if generate_report:
            report_file = self.generate_markdown_report(session_data)
        
        # Clean up current session
        self.current_session_file.unlink()
        
        print(f"✅ Session ended: {session_data['session_name']}")
        print(f"💰 Total cost: ${session_data['total_cost']:.4f}")
        print(f"📊 Total tokens: {session_data['total_tokens_input']}→{session_data['total_tokens_output']}")
        
        if report_file:
            print(f"📄 Report saved: {report_file}")
        
        return str(report_file) if report_file else None
    
    def generate_markdown_report(self, session_data: dict) -> Path:
        """Generate detailed markdown report"""
        session_id = session_data["session_id"]
        report_file = self.session_dir / f"session_report_{session_id}.md"
        
        # Calculate session duration
        start_time = datetime.datetime.fromisoformat(session_data["start_time"])
        end_time = datetime.datetime.fromisoformat(session_data["end_time"]) if session_data["end_time"] else start_time
        duration = end_time - start_time
        
        # Generate report content
        report_content = f"""# Claude Code Session Report

**Date**: {start_time.strftime("%Y-%m-%d")}
**Time**: {start_time.strftime("%H:%M:%S UTC")}

## Session Overview

| Metric | Value |
|--------|-------|
| **Session ID** | `{session_data['session_id']}` |
| **Session Name** | {session_data['session_name']} |
| **Start Time** | {start_time.strftime("%Y-%m-%d %H:%M:%S UTC")} |
| **End Time** | {end_time.strftime("%Y-%m-%d %H:%M:%S UTC")} |
| **Duration** | {str(duration).split('.')[0]} |
| **Project Path** | `{session_data['project_path']}` |
| **Git Commit (Start)** | `{session_data.get('git_commit_start', 'N/A')}` |
| **Git Commit (End)** | `{session_data.get('git_commit_end', 'N/A')}` |

## Cost Summary

| Cost Breakdown | Amount |
|----------------|--------|
| **Total Cost** | **${session_data['total_cost']:.4f}** |
| **Input Tokens** | {session_data['total_tokens_input']:,} |
| **Output Tokens** | {session_data['total_tokens_output']:,} |
| **Total Tokens** | {session_data['total_tokens_input'] + session_data['total_tokens_output']:,} |
| **Avg Cost per Token** | ${(session_data['total_cost'] / max(1, session_data['total_tokens_input'] + session_data['total_tokens_output'])):.6f} |

## Usage Breakdown

### By Operation Type
"""
        
        # Operations breakdown
        for operation, count in session_data["operations"].items():
            percentage = (count / session_data["total_entries"]) * 100
            report_content += f"- **{operation.title()}**: {count} calls ({percentage:.1f}%)\n"
        
        # Models breakdown
        report_content += "\n### By Model\n"
        for model, count in session_data["models_used"].items():
            percentage = (count / session_data["total_entries"]) * 100
            report_content += f"- **{model}**: {count} calls ({percentage:.1f}%)\n"
        
        # Detailed entries
        report_content += f"""

## Detailed Activity Log

| Time | Operation | Model | In→Out Tokens | Cost | Context |
|------|-----------|-------|---------------|------|---------|
"""
        
        for entry in session_data["entries"]:
            timestamp = datetime.datetime.fromisoformat(entry["timestamp"])
            time_str = timestamp.strftime("%H:%M:%S")
            context_preview = entry["context"][:50] + "..." if len(entry["context"]) > 50 else entry["context"]
            
            report_content += f"| {time_str} | {entry['operation']} | {entry['model']} | {entry['tokens_input']}→{entry['tokens_output']} | ${entry['total_cost']:.4f} | {context_preview} |\n"
        
        # Cost analysis
        report_content += f"""

## Cost Analysis

### Hourly Rate Estimate
- **Session Duration**: {str(duration).split('.')[0]}
- **Total Cost**: ${session_data['total_cost']:.4f}
- **Hourly Rate**: ${(session_data['total_cost'] / max(duration.total_seconds() / 3600, 0.01)):.2f}/hour

### Token Efficiency
- **Input/Output Ratio**: {(session_data['total_tokens_output'] / max(session_data['total_tokens_input'], 1)):.2f}
- **Tokens per Minute**: {((session_data['total_tokens_input'] + session_data['total_tokens_output']) / max(duration.total_seconds() / 60, 1)):.0f}

### Cost Optimization Insights
"""
        
        # Add optimization insights
        if session_data['total_cost'] > 10.0:
            report_content += "- ⚠️  High cost session (>${:.2f}) - consider breaking into smaller sessions\n".format(session_data['total_cost'])
        
        output_ratio = session_data['total_tokens_output'] / max(session_data['total_tokens_input'], 1)
        if output_ratio < 0.5:
            report_content += "- 💡 Low output ratio - consider more targeted prompts\n"
        elif output_ratio > 2.0:
            report_content += "- ✅ High output ratio - efficient prompt usage\n"
        
        # Model recommendations
        if "claude-opus-4" in session_data["models_used"] and session_data["models_used"]["claude-opus-4"] > 5:
            report_content += "- 💰 Heavy Opus usage - consider Sonnet for routine tasks\n"
        
        report_content += f"""

## Session Notes

Add your session notes and observations here:

- **Key Accomplishments**: 
- **Challenges Encountered**: 
- **Code Quality**: 
- **Next Session Focus**: 

## Cost Tracking

This session cost: **${session_data['total_cost']:.4f}**

Running project total: _[Update manually or use cost summary script]_

---
*Report generated by Claude Cost Tracker v1.0*
"""
        
        # Write report
        with open(report_file, 'w') as f:
            f.write(report_content)
        
        return report_file
    
    def status(self) -> None:
        """Show current session status"""
        if not self.current_session_file.exists():
            print("📊 No active session")
            return
        
        with open(self.current_session_file, 'r') as f:
            session_data = json.load(f)
        
        print(f"📊 Active Session: {session_data['session_name']}")
        print(f"💰 Current Cost: ${session_data['total_cost']:.4f}")
        print(f"🔢 Total Entries: {session_data['total_entries']}")
        print(f"📈 Tokens: {session_data['total_tokens_input']}→{session_data['total_tokens_output']}")
        
        if session_data['entries']:
            last_entry = session_data['entries'][-1]
            print(f"⏰ Last Activity: {last_entry['operation']} at {last_entry['timestamp'].split('T')[1][:8]}")

def main():
    parser = argparse.ArgumentParser(description="Claude Code Cost Tracker")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # Start session
    start_parser = subparsers.add_parser("start", help="Start new session")
    start_parser.add_argument("--session-name", required=True, help="Name for this session")
    start_parser.add_argument("--context", default="", help="Initial context description")
    
    # Log usage
    log_parser = subparsers.add_parser("log", help="Log token usage")
    log_parser.add_argument("--tokens-in", type=int, required=True, help="Input tokens")
    log_parser.add_argument("--tokens-out", type=int, required=True, help="Output tokens")
    log_parser.add_argument("--model", default="claude-sonnet-4", help="Model used")
    log_parser.add_argument("--operation", default="chat", help="Operation type")
    log_parser.add_argument("--context", default="", help="What was being worked on")
    
    # End session
    end_parser = subparsers.add_parser("end", help="End current session")
    end_parser.add_argument("--generate-report", action="store_true", default=True, help="Generate markdown report")
    end_parser.add_argument("--no-report", action="store_true", help="Skip report generation")
    
    # Status
    status_parser = subparsers.add_parser("status", help="Show current session status")
    
    # Quick log (common usage patterns)
    quick_parser = subparsers.add_parser("quick", help="Quick log with common patterns")
    quick_parser.add_argument("pattern", choices=["code", "review", "chat", "debug"], help="Usage pattern")
    quick_parser.add_argument("--context", default="", help="Brief context")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    tracker = CostTracker()
    
    if args.command == "start":
        tracker.start_session(args.session_name, args.context)
    elif args.command == "log":
        tracker.log_usage(args.tokens_in, args.tokens_out, args.model, args.operation, args.context)
    elif args.command == "end":
        generate_report = not args.no_report if hasattr(args, 'no_report') else args.generate_report
        tracker.end_session(generate_report)
    elif args.command == "status":
        tracker.status()
    elif args.command == "quick":
        # Quick patterns with typical token ranges
        patterns = {
            "code": (1000, 2000, "code_generation"),
            "review": (2000, 500, "code_review"),
            "chat": (500, 800, "chat"),
            "debug": (1500, 1000, "debugging")
        }
        tokens_in, tokens_out, operation = patterns[args.pattern]
        tracker.log_usage(tokens_in, tokens_out, "claude-sonnet-4", operation, args.context)

if __name__ == "__main__":
    main()
