import os


def handler(event, context):
    print("start")
    os.system("make stackstart")
    print("end")


if __name__ == "__main__":
    handler(None, None)
