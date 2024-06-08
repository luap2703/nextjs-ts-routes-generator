#!/usr/bin/env ts-node
import { exec } from "child_process";
const [, , command, ...args] = process.argv;
const runScript = (script) => {
    exec(script, (error, stdout, stderr) => {
        if (error) {
            console.error(`Fehler: ${error.message}`);
            return;
        }
        if (stderr) {
            console.error(`Stderr: ${stderr}`);
            return;
        }
        console.log(`Output: ${stdout}`);
    });
};
switch (command) {
    case "generate":
        runScript("sh ../scripts/generate.sh");
        break;
    case "config":
        runScript("sh ../scripts/config.sh");
        break;
    case "clear":
        runScript("sh ../scripts/clear.sh");
    default:
        console.log(`Unbekannter Befehl: ${command}`);
        console.log("Verfügbare Befehle: generate, config");
        break;
}
//# sourceMappingURL=cli.js.map