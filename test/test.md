<div style='margin-left:5;border-left:gray 1px solid;padding-left:5px'>

# Test schema

A schema that tests the documentation script

type: `object`

**someArray:**
<div style='margin-left:10;border-left:gray 1px solid;padding-left:5px'>

## Some array

An array whose members are multiples of 16.

type: `array`
- Must be longer than 3 items

**Elements:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `number`

Restrictions:
- Number must be a multiple of 16

</div>

Default: `[16, 32, 48, 64]`

</div>

**aTuple:**
<div style='margin-left:10;border-left:gray 1px solid;padding-left:5px'>

## A tuple

A tuple that also tests all the string formats

type: `array`

**Element 0:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>

### Title

This tuple element has a title

type: `string`

Restrictions:
- Must be an ISO-8601 formatted date and time (`YYYY-MM-DDThh:mm:ss+hh:mm`)

</div>

**Element 1:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an ISO-8601 formatted time (`hh:mm:ss+hh:mm`)

</div>

**Element 2:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an ISO-8601 formatted date (`YYYY-MM-DD`)

</div>

**Element 3:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an email address compliant with [RFC5311&sect;3.4.1](https://tools.ietf.org/html/rfc5322#section-3.4.1)

</div>

**Element 4:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an internationalized email address compliant with [RFC6531](https://tools.ietf.org/html/rfc6531)

</div>

**Element 5:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an internet host name compliant with [RFC1034&sect;3.1](https://tools.ietf.org/html/rfc1034#section-3.1)

</div>

**Element 6:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an internationalized internet host name, compliant with [RFC5890&sect;2.3.2.3](https://tools.ietf.org/html/rfc5890#section-2.3.2.3)

</div>

**Element 7:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an IPv4 address ([RFC2673&sect;3.2](https://tools.ietf.org/html/rfc2673#section-3.2))

</div>

**Element 8:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an IPv6 address ([RFC2373&sect;2.2](https://tools.ietf.org/html/rfc2373#section-2.2))

</div>

**Element 9:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an [RFC3986](https://tools.ietf.org/html/rfc3986)-compliant URI

</div>

**Element 10:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be a URI reference according to [RFC3986&sect;4.1](https://tools.ietf.org/html/rfc3986#section-4.1)

</div>

**Element 11:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an [RFC3987](https://tools.ietf.org/html/rfc3987)-compliant internationalized URI

</div>

**Element 12:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an [RFC3987](https://tools.ietf.org/html/rfc3987)-compliant internationalized URI reference

</div>

**Element 13:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be an [RFC6570](https://tools.ietf.org/html/rfc6570)-compliant URI template

</div>

**Element 14:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be a JSON pointer as specified in [RFC6901](https://tools.ietf.org/html/rfc6901)

</div>

**Element 15:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be a [relative JSON pointer](https://tools.ietf.org/html/draft-handrews-relative-json-pointer-01)

</div>

**Element 16:**
<div style='margin-left:15;border-left:gray 1px solid;padding-left:5px'>


type: `string`

Restrictions:
- Must be a regular expression, following the [ECMA 262](https://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf) dialect

</div>

</div>

**badPassword:**
<div style='margin-left:10;border-left:gray 1px solid;padding-left:5px'>

## Password

This is a password (but a bad one)

type: `string`

Restrictions:
- Must be longer than 6 characters and shorter than 12 characters
- Must match the regular expression `/[a-zA-Z]*[1-9]+[a-zA-Z]*/`

**Examples**
- password123
- hunter2

</div>

</div>
