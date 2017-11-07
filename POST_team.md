# Create Team

    POST team

## Description
Create your team for the Scavenging Hunt

***

## Requires authentication
False

***

## Parameters
Essential information:

- **LRID** — ID from QR Code or Beacon from registration point
- **Name** — The name of the team

***

## Return format
Status code 201 CREATED


***

## Errors
All known errors cause the resource to return HTTP error code header together with a JSON array containing at least 'status' and 'error' keys describing the source of error.

- **401 UNAUTHORIZED** — Invalid Token

***

## Example
**Request**

    POST /team

**Return**
``` json
{
  "token": "89653832030e7d26daf3a43fc2ccd501",
}
```

[OAuth]: https://github.com/afloury/Smart-Scavenger-Hunt-Router/blob/master/POST_qrCode_scan.md