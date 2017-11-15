import requests


response = requests.get(
    url='http://localhost:5001/get_team_data/',
    headers={
        'Authentication': 'f65dece1-05fa-46fd-bf6c-43015d08c650'
    }
)

print(response.status_code)
print(response.content)
