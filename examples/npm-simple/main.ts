// this just checks that we can import the same dependency with different versions successfully
import color from "npm:chalk@5.3.0";
import "npm:chalk@5.2.0";

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
