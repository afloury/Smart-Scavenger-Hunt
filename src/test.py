import requests
import json

file_yolo = open('picture.jpeg', 'rb')
content = file_yolo.read()
file_yolo.close()

response = requests.post(
    url='http://localhost:5001/picture/',
    headers={
        'Authentication': '400cfdd6-32b8-4e17-972f-0be2e6d61d24',
        'X-SmartScavengerHunt-LRID': 'trolol',
        'Content-Type': 'image/jpeg',
        'X-SmartScavengerHunt-lat': '12.34567',
        'X-SmartScavengerHunt-long': '76.54321'
    },
    data=content
)

print(response.status_code)
print(response.content)
