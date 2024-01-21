import sqlite3
import subprocess

# command = "yt-dlp -j --flat-playlist 'https://www.youtube.com/@DjangoConUS' | grep 'Contributing to Django or how I learned to stop worrying and just try to fix an ORM Bug Ryan Cheley' | jq -r '.|[.view_count,.title,.url]|@tsv'"
command = "yt-dlp -j --flat-playlist 'https://www.youtube.com/@DjangoConUS' | jq -r '.|[.view_count,.title,.url]|@tsv'"
process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
output, error = process.communicate()

conn = sqlite3.connect('views.db')
cursor = conn.cursor()
cursor.execute("""
    CREATE TABLE IF NOT EXISTS views (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        view_count INTEGER,
        title TEXT,
        url TEXT,
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
""")


if error:
    print(f"Error: {error.decode()}")
else:
    output = output.decode()
    for line in output.split("\n"):
        if line:
            view_count, title, url = line.split("\t")
            print(view_count)
            print(title)
            print(url)
            try:
                cursor.execute("INSERT INTO views (view_count, title, url) VALUES (?,?,?)", (view_count,title,url))
                conn.commit()
            except sqlite3.IntegrityError:
                print("Error: could not insert data into the table")

conn.close()