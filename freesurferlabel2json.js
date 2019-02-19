#!/usr/bin/node 
const fs = require('fs');
const fslabels = fs.readFileSync("FreeSurferColorLUT.txt","ascii");

let labels = [];
fslabels.split("\n").forEach(line=>{
    line = line.trim();
    if(line.length == 0) return;
    if(line[0] == "#") return;
    let cols = line.split(/(\s+)/).filter(e=>{return e.trim().length > 0});
    let name = cols[1];
    let name_tokens = cols[1].split("-");
    if(name_tokens.length == "3") {
        //simplify ctx-lh-foo to just l-foo
        name = name_tokens[1][0]+"-"+name_tokens[2];
    }
    labels.push({
        "label": cols[0],
        name: cols[1],
        color: {
            "r": +cols[2],
            "g": +cols[3],
            "b": +cols[4],
        }
    });
});

fs.writeFileSync("labels.json", JSON.stringify(labels, null, 4));
