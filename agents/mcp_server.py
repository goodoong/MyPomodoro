import os
import glob
import sqlite3
import uuid
from datetime import datetime, timezone, timedelta
from typing import List, Dict, Any, Optional
from mcp.server.fastmcp import FastMCP

# Initialize FastMCP Server
mcp = FastMCP("MyPomodoro")

# COCOA EPOCH OFFSET: Cocoa core data timestamps start at 2001-01-01 00:00:00 UTC.
# Unix timestamp for 2001-01-01 is 978307200.
COCOA_OFFSET = 978307200.0

def find_db_path() -> Optional[str]:
    """
    Locates the default.store SQLite file for the MyPomodoro app 
    in the iOS Simulator directory. It returns the most recently modified one.
    """
    home = os.path.expanduser("~")
    pattern = os.path.join(
        home,
        "Library/Developer/CoreSimulator/Devices/*/data/Containers/Data/Application/*/Library/Application Support/default.store"
    )
    files = glob.glob(pattern)
    if not files:
        return None
    
    # Sort files by modification time (most recently modified first)
    files.sort(key=os.path.getmtime, reverse=True)
    return files[0]

def parse_uuid(blob: Any) -> Optional[str]:
    """Converts a binary CoreData/SwiftData UUID blob to a standard string format."""
    if not blob:
        return None
    try:
        if isinstance(blob, bytes) and len(blob) == 16:
            return str(uuid.UUID(bytes=blob))
        return str(blob)
    except Exception:
        return str(blob)

def parse_cocoa_date(timestamp: Optional[float]) -> Optional[str]:
    """Converts a CoreData timestamp (seconds since 2001) to ISO 8601 UTC string."""
    if timestamp is None:
        return None
    try:
        unix_time = timestamp + COCOA_OFFSET
        return datetime.fromtimestamp(unix_time, tz=timezone.utc).isoformat()
    except Exception:
        return None

def get_connection(db_path: str) -> sqlite3.Connection:
    """Creates a read-only sqlite3 connection."""
    # Connecting with mode=ro protects the developer's simulator db from writes/locks
    return sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)

@mcp.resource("db://status")
def db_status() -> str:
    """Exposes the current status of the database connection and schema."""
    db_path = find_db_path()
    if not db_path:
        return "Database status: Disconnected. No simulator database file (default.store) was found."
    
    try:
        conn = get_connection(db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = [row[0] for row in cursor.fetchall()]
        conn.close()
        
        mtime = os.path.getmtime(db_path)
        last_modified = datetime.fromtimestamp(mtime, tz=timezone.utc).isoformat()
        
        return (
            f"Database status: Connected\n"
            f"Database Path: {db_path}\n"
            f"Last Modified: {last_modified}\n"
            f"Tables found: {', '.join(tables)}"
        )
    except Exception as e:
        return f"Database status: Error reading file. Path: {db_path}. Error: {str(e)}"

@mcp.tool()
def get_subjects() -> List[Dict[str, Any]]:
    """
    Retrieve all study subjects registered in the application.
    Returns:
        List of subjects containing id, name, colorHex, and sortOrder.
    """
    db_path = find_db_path()
    if not db_path:
        return []
    
    conn = get_connection(db_path)
    cursor = conn.cursor()
    
    try:
        # Querying active (non-deleted) subjects
        cursor.execute("""
            SELECT ZID, ZNAME, ZCOLORHEX, ZSORTORDER, ZCREATEDAT 
            FROM ZSUBJECT 
            WHERE ZISDELETED = 0 
            ORDER BY ZSORTORDER ASC
        """)
        
        subjects = []
        for row in cursor.fetchall():
            subjects.append({
                "id": parse_uuid(row[0]),
                "name": row[1],
                "color_hex": row[2],
                "sort_order": row[3],
                "created_at": parse_cocoa_date(row[4])
            })
        return subjects
    except sqlite3.OperationalError as e:
        # Table might not exist yet if app has not run
        return [{"error": f"Failed to query ZSUBJECT table. It might not exist yet. Error: {str(e)}"}]
    finally:
        conn.close()

@mcp.tool()
def get_study_sessions(limit: int = 50) -> List[Dict[str, Any]]:
    """
    Retrieve study sessions recorded in the application.
    Args:
        limit: Max number of sessions to return (default 50).
    """
    db_path = find_db_path()
    if not db_path:
        return []
    
    conn = get_connection(db_path)
    cursor = conn.cursor()
    
    try:
        # Joining StudySession and Subject to display friendly names
        cursor.execute(f"""
            SELECT 
                s.ZID, 
                s.ZSUBJECTID, 
                s.ZSTARTEDAT, 
                s.ZENDEDAT, 
                s.ZDURATIONSECONDS, 
                s.ZISCOMPLETED, 
                sub.ZNAME
            FROM ZSTUDYSESSION s
            LEFT JOIN ZSUBJECT sub ON s.ZSUBJECT = sub.Z_PK
            ORDER BY s.ZSTARTEDAT DESC
            LIMIT ?
        """, (limit,))
        
        sessions = []
        for row in cursor.fetchall():
            sessions.append({
                "id": parse_uuid(row[0]),
                "subject_id": parse_uuid(row[1]),
                "subject_name": row[6] if row[6] else "Unknown/Deleted Subject",
                "started_at": parse_cocoa_date(row[2]),
                "ended_at": parse_cocoa_date(row[3]),
                "duration_seconds": row[4],
                "is_completed": bool(row[5])
            })
        return sessions
    except sqlite3.OperationalError as e:
        return [{"error": f"Failed to query ZSTUDYSESSION table. It might not exist yet. Error: {str(e)}"}]
    finally:
        conn.close()

@mcp.tool()
def get_daily_goals() -> List[Dict[str, Any]]:
    """
    Retrieve study daily goals set in the application.
    """
    db_path = find_db_path()
    if not db_path:
        return []
    
    conn = get_connection(db_path)
    cursor = conn.cursor()
    
    try:
        cursor.execute("""
            SELECT ZID, ZTARGETMINUTES, ZUPDATEDAT 
            FROM ZDAILYGOAL 
            ORDER BY ZUPDATEDAT DESC
        """)
        
        goals = []
        for row in cursor.fetchall():
            goals.append({
                "id": parse_uuid(row[0]),
                "target_minutes": row[1],
                "updated_at": parse_cocoa_date(row[2])
            })
        return goals
    except sqlite3.OperationalError as e:
        return [{"error": f"Failed to query ZDAILYGOAL table. It might not exist yet. Error: {str(e)}"}]
    finally:
        conn.close()

@mcp.tool()
def get_productivity_summary() -> Dict[str, Any]:
    """
    Generate aggregated productivity statistics based on recorded study sessions.
    Calculates total study times, session counts, and breakdown by subject.
    """
    db_path = find_db_path()
    if not db_path:
        return {"error": "Database not found. Please run the MyPomodoro app in the simulator first."}
    
    conn = get_connection(db_path)
    cursor = conn.cursor()
    
    try:
        # Get all sessions
        cursor.execute("""
            SELECT s.ZSTARTEDAT, s.ZDURATIONSECONDS, s.ZISCOMPLETED, sub.ZNAME
            FROM ZSTUDYSESSION s
            LEFT JOIN ZSUBJECT sub ON s.ZSUBJECT = sub.Z_PK
        """)
        
        rows = cursor.fetchall()
        if not rows:
            return {"message": "No study sessions recorded yet."}
        
        now_utc = datetime.now(timezone.utc)
        today_start_cocoa = (now_utc.replace(hour=0, minute=0, second=0, microsecond=0) - datetime(2001, 1, 1, tzinfo=timezone.utc)).total_seconds()
        
        # Calculate week start (Monday)
        days_since_monday = now_utc.weekday()
        week_start_utc = now_utc.replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=days_since_monday)
        week_start_cocoa = (week_start_utc - datetime(2001, 1, 1, tzinfo=timezone.utc)).total_seconds()
        
        total_seconds = 0
        today_seconds = 0
        week_seconds = 0
        
        completed_count = 0
        incomplete_count = 0
        
        subject_durations = {}
        
        for started_at, duration, is_completed, subject_name in rows:
            started_at = started_at or 0.0
            duration = duration or 0
            subject_name = subject_name or "Unknown/Deleted"
            
            total_seconds += duration
            if is_completed:
                completed_count += 1
            else:
                incomplete_count += 1
                
            if started_at >= today_start_cocoa:
                today_seconds += duration
            if started_at >= week_start_cocoa:
                week_seconds += duration
                
            subject_durations[subject_name] = subject_durations.get(subject_name, 0) + duration
            
        subject_breakdown = {}
        for sub_name, secs in subject_durations.items():
            subject_breakdown[sub_name] = {
                "minutes": round(secs / 60, 1),
                "percentage": round((secs / total_seconds) * 100, 1) if total_seconds > 0 else 0
            }
            
        return {
            "summary": {
                "total_study_time_minutes": round(total_seconds / 60, 1),
                "today_study_time_minutes": round(today_seconds / 60, 1),
                "this_week_study_time_minutes": round(week_seconds / 60, 1),
                "completed_sessions": completed_count,
                "incomplete_sessions": incomplete_count,
                "completion_rate_percentage": round((completed_count / (completed_count + incomplete_count)) * 100, 1) if (completed_count + incomplete_count) > 0 else 0
            },
            "subject_breakdown": subject_breakdown
        }
    except sqlite3.OperationalError as e:
        return {"error": f"Failed to generate statistics. Database may not be fully initialized yet. Error: {str(e)}"}
    finally:
        conn.close()

if __name__ == "__main__":
    # Start the FastMCP server (stdin/stdout communication mode)
    mcp.run()
