/**
 * Copied from cliffy examples
 * @license MIT
 * @copyright Copyright (c) 2020-2023 Benjamin Fischer <c4spar@gmx.de>
 * @see https://github.com/c4spar/deno-cliffy/blob/aa1311f8d0891f535805395b0fb7d99de0b01b74/examples/command.ts
 */

import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";
import { serve } from "https://deno.land/std@0.209.0/http/server.ts";

await new Command()
  .name("reverse-proxy")
  .description("A simple reverse proxy example cli.")
  .version("v1.0.0")
  .option("-p, --port <port:number>", "The port number for the local server.", {
    default: 8080,
  })
  .option("--host <hostname>", "The host name for the local server.", {
    default: "localhost",
  })
  .arguments("[domain]")
  .action(async ({ port, host }, domain = "deno.land") => {
    console.log(`Listening on http://${host}:${port}`);
    await serve(
      (req: Request) => {
        const url = new URL(req.url);
        url.protocol = "https:";
        url.hostname = domain;
        url.port = "443";

        console.log("Proxy request to:", url.href);
        return fetch(url.href, {
          headers: req.headers,
          method: req.method,
          body: req.body,
        });
      },
      { hostname: host, port }
    );
  })
  .parse();
