import os


def handler(event, context):
    print("start")
    task = os.environ.get("TASK")
    print(f"task={task}")
    os.system(f"make stackstop && TASK='{task}' make stackstart")
    print("end")


if __name__ == "__main__":
    handler(None, None)
