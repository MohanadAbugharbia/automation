import os
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileModifiedEvent, DirModifiedEvent
from datetime import datetime


HOME_DIR = os.environ.get('HOME')
SOURCE_DIR = f"{HOME_DIR}/Downloads"
DEST_DIR_PDF = f"{HOME_DIR}/Desktop/pdf"
DEST_DIR_FOTOS = f"{HOME_DIR}/Desktop/fotos"

def make_unique(name: str) -> str:
    split_name = name.split(".", 1)
    new_name = f"{split_name[0]}_{datetime.now().date().strftime('%d-%m-%y')}@{datetime.now().time().strftime('%H-%M-%S')}.{split_name[1]}"
    return new_name

def move_file(entry: os.DirEntry, name: str, dest: str) -> None:
    while True:
        file_exists: bool = os.path.exists(f"{dest}/{name}") 
        if file_exists:
            name = make_unique(name)
        else:
            break
    os.rename(entry, f"{dest}/{name}")

class file_handler(FileSystemEventHandler):
    def on_modified(self, event: FileModifiedEvent | DirModifiedEvent) -> None:
       with os.scandir(SOURCE_DIR) as entries:
            for entry in entries:
                name: str = entry.name 
                dest: str = SOURCE_DIR
                if name.endswith('.pdf'):
                    dest = DEST_DIR_PDF
                    move_file(entry, name, dest)
                elif name.endswith('.jpg') or name.endswith('.jpeg') or name.endswith('.png'):
                    dest = DEST_DIR_FOTOS
                    move_file(entry, name, dest)

if __name__ == "__main__":

    DIRECTORY_TO_WATCH = SOURCE_DIR
    observer = Observer()
    
    if not os.path.isdir(DEST_DIR_PDF):
        os.mkdir(DEST_DIR_PDF)
    if not os.path.isdir(DEST_DIR_FOTOS):
        os.mkdir(DEST_DIR_FOTOS)

    event_handler = file_handler()
    observer.schedule(event_handler, DIRECTORY_TO_WATCH, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1000)
    except:
        observer.stop()
        print("Error")
    observer.join()