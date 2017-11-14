# Get list of pictures sent

    GET picture

## Description
Get the list of pictures already sent with this team

***

## Requires authentication
**[OAuth][]**

***

## Parameters
None


***

## Return format
Status code 200 OK along with a JSON array containing all the pictures posted with the team


***

## Errors
All known errors cause the resource to return HTTP error code header together with a JSON array containing at least 'status' and 'error' keys describing the source of error.

- **401 UNAUTHORIZED** — Invalid Token

***

## Example
**Request**

    GET /picture

**Return**
``` json
[
    {
        "id": "fF78gi56hjn043",
        "name": "cat",
        "url": "http://picture.picture/picture"
    },
    {
        "id": "fF78gi56hjn043",
        "name": "dog",
        "url": "http://picture.picture/picture"
    },
    {
        "id": "fF78gi56hjn043",
        "name": "chair",
        "url": "http://picture.picture/picture"
    }
]
```


[OAuth]: https://github.com/afloury/Smart-Scavenger-Hunt/blob/master/POST_team.md
