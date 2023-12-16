import * as color from "https://deno.land/std@0.209.0/fmt/colors.ts";

const ascii = [
  color.green("╺┳┓┏━╸┏┓╻┏━┓ ╻  ┏━┓┏┓╻╺┳┓"),
  color.green(" ┃┃┣╸ ┃┗┫┃ ┃ ┃  ┣━┫┃┗┫ ┃┃"),
  color.green("╺┻┛┗━╸╹ ╹┗━┛╹┗━╸╹ ╹╹ ╹╺┻┛"),
  color.black("         ┏━┓┏┓╻"),
  color.black("         ┃ ┃┃┗┫"),
  color.black("         ┗━┛╹ ╹"),
  color.blue("        ┏┓╻╻╻ ╻"),
  color.blue("        ┃┗┫┃┏╋┛"),
  color.blue("        ╹ ╹╹╹ ╹"),
].join("\n");

console.log(color.bold(color.blue(ascii)));
