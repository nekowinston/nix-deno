/**
 * Copied from webview examples
 * @license MIT
 * @copyright Copyright (c) 2020-2022 the webview team
 * @see https://github.com/webview/webview_deno/blob/83c5ff026d06378f001819a79430b8256f44d780/examples/ssr/main.ts
 */

import { Webview } from "https://deno.land/x/webview@0.7.6/mod.ts";

const worker = new Worker(new URL("worker.tsx", import.meta.url), {
  type: "module",
});

const webview = new Webview();
webview.navigate("http://localhost:8000/");

console.log("[runner] worker started");
webview.run();
worker.terminate();
