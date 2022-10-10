# http-tester

Http server at the specified `PORT` (default: 8000). Replies with the full request headers.

Configuration example:

```yaml
mdns-publisher:
    image: ttmetro/http-tester
    restart: unless-stopped
    environment:
        - HTTP_TESTER_PORT=8000
```
