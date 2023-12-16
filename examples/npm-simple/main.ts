import color from "npm:chalk";

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
