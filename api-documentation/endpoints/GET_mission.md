# GET mission

    GET mission

## Description
Get a new mission or the current mission

***

## Requires authentication
**[OAuth][]**

***

## Headers
Essential information:
**In the header request**

- **Authentication** — Token get from the registration
- **X-SmartScavengerHunt-LRID** — Location Restriction Identifier from QR Code or Beacon

***

## Return format
Status code 200 OK along with a JSON array containing the list of object to search


***

## Errors
All known errors cause the resource to return HTTP error code header together with a JSON array containing at least 'status' and 'error' keys describing the source of error.

- **401 UNAUTHORIZED** — Invalid Token or Invalid LRID

***

## Example
**Request**

    POST /mission

**Return**
``` json
[
  {"name": "Bike"},
  {"name": "Chair"},
  {"name": "Cat"},
]
```


[OAuth]: https://github.com/afloury/Smart-Scavenger-Hunt-Router/blob/master/POST_team.md
