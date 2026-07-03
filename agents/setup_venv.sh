#!/bin/bash
set -e

# Change directory to the script's location
cd "$(dirname "$0")"

echo "=== Creating Python Virtual Environment ==="
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "Virtual environment 'venv' created."
else
    echo "Virtual environment 'venv' already exists."
fi

echo "=== Activating Virtual Environment & Upgrading pip ==="
source venv/bin/activate
pip3 install --upgrade pip

echo "=== Installing Dependencies from requirements.txt ==="
pip3 install -r requirements.txt

echo "=== Setup Completed Successfully ==="
echo "To run the MCP server manually, execute:"
echo "  source agents/venv/bin/activate && python3 agents/mcp_server.py"
