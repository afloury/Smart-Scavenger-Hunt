# Send picture

    POST picture

## Description
Send the picture at the delivery point to check if you have won this mission

***

## Headers
Essential information:
**In the header request**

- **Authentication** — Token get from the registration
- **X-SmartScavengerHunt-LRID** — Location Restriction Identifier from QR Code or Beacon
- **X-SmartScavengerHunt-lat** — Latitude of the phone when the photo is taken
- **X-SmartScavengerHunt-long** — Longitude of the phone when the photo is taken

***

## Parameters
Essential information:

- **Data** — The raw content of the picture

***

## Return format
Status code 201 OK along with a JSON object containing a message to display to the user


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
    "message": "Photo correctement traitée."
}
```


[OAuth]: https://github.com/afloury/Smart-Scavenger-Hunt-Router/blob/master/POST_team.md
