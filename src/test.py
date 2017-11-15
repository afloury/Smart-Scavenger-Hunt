import requests
import json

response = requests.get(
    url='http://localhost:5001/get_team_data/',
    headers={
        'Authentication': '486d2f14-435f-474c-b2a8-697c2e9830e7'
    }
)

print(response.status_code)
print(response.content)
