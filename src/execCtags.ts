import * as fs from 'fs';

//const excludeDirs = [
//    '.git', '.vscode'
//];

/**
 * 指定したディレクトリに存在するファイル一覧を取得する。
 * @param {string} dir - 表示したいディレクトリのパス。
 * @param {string[]} files - 再帰関数へ渡す上位階層に存在するファイルのパス
 * @param {boolean|undefined} [recursive] - 下位階層まで全てのファイルを再帰で読み込む。
 * @return {Promise<string[]>} - dir以下に存在するファイルのパス。
 */
const _readdir = async (dir: string, files: string[], recursive?: boolean) : Promise<string[]> => {
    if(recursive === undefined) {
        recursive = false;
    }
    const dirents = await fs.promises.readdir(dir, { withFileTypes: true });
    const dirs = [];
    for (const dirent of dirents) {
    //for (const dirent of dirents.filter( dirent => excludeDirs.indexOf(dirent.name) == -1 )) {
        if (dirent.isDirectory()) dirs.push(`${dir}/${dirent.name}`);
        if (dirent.isFile()) files.push(`${dir}/${dirent.name}`);
    }
    if(recursive) {
        for (const d of dirs) {
            files = await _readdir(d, files);
        }
    }
    return Promise.resolve(files);
    //return Promise.resolve(dirs);
};

const includeExtends = [
    'v', 'vh', 'vhd', 'sv', 'svh', 'js'
];

const _fileExtensionFilter = (files: string[]): string[] => {
    const result = files.filter( function(value: string) {
        if(value.indexOf('.') == -1) {
            console.log('Debug: No extend');
            return false;
        }

        const extend = value.split('.').pop();
        if(extend === undefined) {
            console.log('Debug: No file');
            return false;
        }

        return includeExtends.indexOf(extend.toLowerCase()) != -1;
    });

    return result;
}

const excludeDirs = async () : Promise<string[]> => {
    const dirents = await fs.promises.readdir(".", { withFileTypes: true });
    const _excludeDirs = [];
    for(const dirent of dirents.filter( dirent => dirent.isDirectory() )) {
        const result = await _readdir(dirent.name, []).catch(err => {
            console.error("Error:", err);
        });

        if(result === undefined) {
            _excludeDirs.push(dirent.name);
            console.log(`Debug: ${dirent.name} is no file`);
        }
        else if( _fileExtensionFilter(result).length ) {
            console.log(`Debug: ${dirent.name} is verilog file directory`);
        }
        else {
            _excludeDirs.push(dirent.name);
            console.log(`Debug: ${dirent.name} is no verilog file directory`);
        }
        console.log(`Debug: ${result}`);
    }
    return Promise.resolve(_excludeDirs);
}

(async () => {
    const result = await excludeDirs();
    console.log(result);

    //const result = await readdir(".", []).catch(err => {
    //    console.error("Error:", err);
    //});
    //console.log(result);
    //if(result !== undefined)
    //    console.log(_fileExtensionFilter(result));
})();