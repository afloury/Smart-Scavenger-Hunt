import requests

response = requests.get(
    url='http://localhost:5001/mission/',
    headers={
        'Authentication': '353b217d-6bbb-4613-aa90-5dec09fcd2cb'
    }
)

print(response.status_code)
print(response.content)
