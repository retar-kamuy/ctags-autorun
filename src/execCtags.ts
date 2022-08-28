import * as fs from 'fs';

const fsPromises = fs.promises;

const readdirRecursively = async (dir: string, files: string[]) : Promise<string[]> => {
    const dirents = await fsPromises.readdir(dir, { withFileTypes: true });
    const dirs = [];
    for (const dirent of dirents) {
        if (dirent.isDirectory()) dirs.push(`${dir}/${dirent.name}`);
        if (dirent.isFile()) files.push(`${dir}/${dirent.name}`);
    }
    for (const d of dirs) {
        files = await readdirRecursively(d, files);
    }
    return Promise.resolve(files);
};

(async () => {
    const result = await readdirRecursively("./files", []).catch(err => {
        console.error("Error:", err);
    });
    console.log(result);
})();
