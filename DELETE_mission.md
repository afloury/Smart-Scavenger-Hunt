# GET mission

    DELETE mission

## Description
Leave the current mission

***

## Requires authentication
**[OAuth][]**

***

## Parameters
None

***

## Return format
Status code 204 NO CONTENT


***

## Errors
All known errors cause the resource to return HTTP error code header together with a JSON array containing at least 'status' and 'error' keys describing the source of error.

- **401 UNAUTHORIZED** — Invalid Token

***

## Example
**Request**

    DELETE /mission


[OAuth]: https://github.com/afloury/Smart-Scavenger-Hunt-Router/blob/master/POST_team.md