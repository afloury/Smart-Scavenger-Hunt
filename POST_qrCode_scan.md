# QR Code Scan

    POST qrCode/scan

## Description
Send the qrCode to start a game and create your team

***

## Requires authentication
False

***

## Parameters
Essential information:

- **data** — The QR Code Data

***

## Return format
Status code 200, along with a JSON object containing the token requied for others requests


***

## Errors
All known errors cause the resource to return HTTP error code header together with a JSON array containing at least 'status' and 'error' keys describing the source of error.

- **404 Not Found** — This QR Code is invalid

***

## Example
**Request**

    POST qrCode/scan


**Return**
``` json
{
  "token": "89653832030e7d26daf3a43fc2ccd501"
}
```