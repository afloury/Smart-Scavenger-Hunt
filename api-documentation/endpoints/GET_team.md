# Get list of teams with scores

    GET team

## Description
Get the list of teams who played with scores

***

## Requires authentication
**[OAuth][]**

***

## Parameters
None


***

## Return format
Status code 200 OK along with a JSON array containing all teams with scores


***

## Errors
All known errors cause the resource to return HTTP error code header together with a JSON array containing at least 'status' and 'error' keys describing the source of error.

- **401 UNAUTHORIZED** — Invalid Token

***

## Example
**Request**

    GET /team

**Return**
``` json
[
    {
        "name": "Shark-Attack",
        "score": 121
    },
    {
        "name": "Paparazzi",
        "score": 78
    },
    {
        "name": "chair",
        "score": 56
    }
]
```


[OAuth]: https://github.com/afloury/Smart-Scavenger-Hunt-Router/blob/master/POST_team.md