# Unencrypted Data Capture — Short Report

**Packet:** #134 · **Protocol:** HTTP (POST) · **Capture:** `wireshark_capture.pcapng`

## Summary
A login attempt to the DVWA application (`http://127.0.0.1/dvwa/login.php`) was captured
in plaintext. The request was sent from source port `53108` to destination port `80`
(HTTP, unencrypted) on the loopback interface (`127.0.0.1 → 127.0.0.1`), confirming DVWA
is served over plain HTTP with no TLS.

## Data Exposed
Wireshark's dissector fully decoded the HTML form body, exposing:

| Field | Value |
|---|---|
| Username | `admin` |
| Password | `password` |
| Login action | `Login` |
| CSRF token (`user_token`) | `b67921962e77bab3e363cd3443ea2ded` |

The raw hex/ASCII pane confirms the same data appears as literal cleartext bytes on the
wire (`username=admin&password=password&Login=Login...`), along with a visible
`Cookie: PHPSESSID=...` header carrying the active session identifier.

