# Repository guidance

## API contract

- Use `docs/api/openapi.json` as the saved OpenAPI contract for all backend routes, request fields, and response schemas.
- Use `docs/api/README.md` as the searchable endpoint index. The index currently covers all 120 documented paths and 159 operations.
- Check the contract before changing API calls. Do not infer endpoint field names from Dart model names.
- The live source is `https://iptvdemo.serv5group.com/api/docs`; refresh the local snapshot when the user provides a newer API contract or asks to re-check the live docs.
