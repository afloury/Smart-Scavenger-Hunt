# Send picture

    POST picture

## Description
Send the picture at the delivery point to check if you have won this mission

***

## Requires authentication
**[OAuth][]**

***

## Headers
Essential information:
**In the header request**

- **Authentication** — Token get from the registration
- **X-SmartScavengerHunt-LRID** — Location Restriction Identifier from QR Code or Beacon
- **X-SmartScavengerHunt-lat** — Location Restriction Identifier from QR Code or Beacon
- **X-SmartScavengerHunt-long** — Location Restriction Identifier from QR Code or Beacon

***

## Parameters
Essential information:

- **Data** — Datas picture

***

## Return format
Status code 201 OK along with a JSON object containing the the result of the mission


***

## Errors
All known errors cause the resource to return HTTP error code header together with a JSON array containing at least 'status' and 'error' keys describing the source of error.

- **401 UNAUTHORIZED** — Invalid Token or Invalid LRID

***

## Example
**Request**

    POST /picture

**Return**
``` json
{
    "Result": "Win",
    "Picture_value": "Cat",
    "Points": 10
}
```


[OAuth]: https://github.com/afloury/Smart-Scavenger-Hunt-Router/blob/master/POST_team.md
