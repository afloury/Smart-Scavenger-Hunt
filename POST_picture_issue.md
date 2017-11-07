# Report picture recognition issue 

    POST picture/{id_picture}/issue

## Description
Send the picture at the delivery point to check if you have won this mission

***

## Requires authentication
**[OAuth][]**

***

## Parameters
None

***

## Return format
Status code 200 OK without content


***

## Errors
All known errors cause the resource to return HTTP error code header together with a JSON array containing at least 'status' and 'error' keys describing the source of error.

- **401 UNAUTHORIZED** — Invalid Token

***

## Example
**Request**

    POST /picture/{id_picture}/issue


[OAuth]: https://github.com/afloury/Smart-Scavenger-Hunt-Router/blob/master/POST_team.md