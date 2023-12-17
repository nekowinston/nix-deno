import color from "https://esm.sh/v135/chalk@5.3.0/";

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
