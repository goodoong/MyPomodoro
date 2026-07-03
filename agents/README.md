# MyPomodoro MCP Server

A Model Context Protocol (MCP) server written in Python that allows AI agents to interface with the SQLite database used by the MyPomodoro iOS application running in the Xcode Simulator.

## Features

- **Resource (`db://status`)**: Retrieves the database file path, file size, connection state, and available tables.
- **Tool (`get_subjects`)**: Retrieves list of active study subjects (id, name, color, sort order).
- **Tool (`get_study_sessions`)**: Retrieves the history of study sessions including the subject name, start/end times, and completion state.
- **Tool (`get_daily_goals`)**: Retrieves daily goals set in the application.
- **Tool (`get_productivity_summary`)**: Computes total/weekly/daily statistics, completed session percentages, and breakdown of study hours by subject.

---

## Getting Started

### 1. Install & Setup Environment
Ensure that you have Python 3.10+ installed on your macOS machine.

Run the provided setup script to create a virtual environment and install the required dependencies:

```bash
chmod +x agents/setup_venv.sh
./agents/setup_venv.sh
```

### 2. Run the Server Manually
To check if the server starts without issues:

```bash
source agents/venv/bin/activate
python3 agents/mcp_server.py
```

It runs in standard input/output (stdio) mode. The command will wait for JSON-RPC requests. Press `Ctrl+C` to terminate.

---

## Registering with AI Clients

### 1. Cursor App
To connect the MyPomodoro MCP server to Cursor:
1. Open Cursor Settings -> **Features** -> **MCP**.
2. Click **+ Add New MCP Server**.
3. Fill in the configuration:
   - **Name**: `MyPomodoro`
   - **Type**: `command`
   - **Command**: `/Users/YOUR_USERNAME/MyPomodoro/MyPomodoro/agents/venv/bin/python3 /Users/YOUR_USERNAME/MyPomodoro/MyPomodoro/agents/mcp_server.py`
4. Click **Save**.

### 2. Claude Desktop App
To connect to the Claude Desktop application, open your `claude_desktop_config.json` file (typically located at `~/Library/Application Support/Claude/claude_desktop_config.json`) and append the following entry:

```json
{
  "mcpServers": {
    "mypomodoro": {
      "command": "/Users/YOUR_USERNAME/MyPomodoro/MyPomodoro/agents/venv/bin/python3",
      "args": [
        "/Users/YOUR_USERNAME/MyPomodoro/MyPomodoro/agents/mcp_server.py"
      ]
    }
  }
}
```
*Make sure to replace `/Users/YOUR_USERNAME` with your actual absolute home directory path.*
