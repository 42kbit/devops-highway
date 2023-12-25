import requests

def main():
    return requests.get(url="https://google.com") # returns response by default

# "__main__" value is assigned to the file that
# runs with "python3 file.py", otherwise, filename is printed
if __name__ == "__main__":
    print(__name__)
    print(main())