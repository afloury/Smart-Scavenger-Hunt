import requests

with open('picture.jpeg', 'rb') as file:
    data = file.read()

    response = requests.post(
        url='http://localhost:5001/picture/',
        headers={
            'Authentication': '871b2e18-bb74-429a-8b3a-176571e565b9'
        },
        data=data
    )

    print(response.status_code)
    print(response.content)

    test = open('output.html', 'wb')
    test.write(response.content)
    test.close()
