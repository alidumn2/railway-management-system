"""Run extra_data.sql against the Django database."""
import django, os, sys

os.environ['DJANGO_SETTINGS_MODULE'] = 'railway_app.settings'
django.setup()

from django.db import connection

sql_path = r'c:\Users\alidu\OneDrive\Masaüstü\railway_app\extra_data.sql'

with open(sql_path, 'r', encoding='utf-8') as f:
    sql_content = f.read()

# Remove USE statement
sql_content = sql_content.replace('USE railway_db;', '')

# Split by semicolons, filter empty
statements = []
for stmt in sql_content.split(';'):
    # Remove comment-only lines but keep inline comments
    lines = []
    for line in stmt.split('\n'):
        stripped = line.strip()
        if stripped and not stripped.startswith('--'):
            lines.append(line)
    cleaned = '\n'.join(lines).strip()
    if cleaned:
        statements.append(cleaned)

cursor = connection.cursor()
success = 0
for i, stmt in enumerate(statements):
    try:
        cursor.execute(stmt)
        success += 1
    except Exception as e:
        print(f"Statement {i+1} error: {e}")
        print(f"  SQL: {stmt[:80]}...")

print(f"\nDone! {success}/{len(statements)} statements executed successfully.")
