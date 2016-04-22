# RFLAN QR Code Scanner App
#### A utility app created to quickly sign in lanners attending the Redflag Lanfest events in Perth, Western Australia

![QR Code Scanner on iPod touch](https://raw.github.com/TimOliver/RFLAN-QR-Code-Scanner-2/master/Screenshots/RFLAN_QR_Scanner.jpg)

## WTF is this thing?

As part of an initiative to make signing in attendees to our events faster, we created a sign-in system using QR codes and our iOS devices.
Attendees receive an email containing a QR code which they can then bring to the event. When they show it to us, we use this app
to quickly scan the code, which will then be passed to the signups database over a local web API. Once the QR code has been validated, it is checked off (So it can't be redeemed again) 
and an alert is provided to the admins knowing that the attendee is legit.
This system has accelerated checking in attendees at RFLAN by a substantial degree, and as such, it is highly recommended that other organisations try it too.

## License

The RFLAN QR code scanner is licensed under the MIT license. It would be greatly appreciated that 
any derivatives of this code give credit to http://rflan.org

- - -

Copyright 2013 Timothy Oliver, RFLAN. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
