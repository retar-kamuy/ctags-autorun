import * as fs from 'fs';

//const excludeDirs = [
//    '.git', '.vscode'
//];
const includeExtensions = [
    'v', 'vh', 'vhd', 'sv', 'svh'
];

/**
 * 指定したディレクトリに存在するファイル一覧を取得する。
 * @param {string} dir - 表示したいディレクトリのパス。
 * @param {string[]} files - 再帰関数へ渡す上位階層に存在するファイルのパス
 * @param {boolean|undefined} [recursive] - 下位階層まで全てのファイルを再帰で読み込む。
 * @param {string[]} [filter] - 取得するファイルの拡張子を指定する。指定なし(undefined)の場合、全てファイルを取得する。s
 * @return {Promise<string[]>} - dir以下に存在するファイルのパス。
 */
const readdir = async (dir: string, files: string[], recursive?: boolean, filter?: string[]): Promise<string[]> => {
    if (recursive === undefined) {
        recursive = false;
    }
    const dirents = await fs.promises.readdir(dir, { withFileTypes: true });
    const dirs = [];
    for (const dirent of dirents) {
        //for (const dirent of dirents.filter( dirent => excludeDirs.indexOf(dirent.name) == -1 )) {
        if (dirent.isDirectory()) dirs.push(`${dir}/${dirent.name}`);
        if (dirent.isFile()) {
            if (filter === undefined) {
                files.push(`${dir}/${dirent.name}`);
            }
            else if (_specificExtensionOf(dirent.name, filter) != -1) {
                files.push(`${dir}/${dirent.name}`);
            }
        }
    }
    if (recursive) {
        for (const d of dirs) {
            files = await readdir(d, files, recursive, filter);
        }
    }
    return Promise.resolve(files);
    //return Promise.resolve(dirs);
};

const _specificExtensionOf = (file: string, extensions: string[]): number => {
    //console.log(file);
    if (file.indexOf('.') == -1) {
        //console.log('Debug: No extend');
        return -1;
    }

    const extend = file.split('.').pop() as string;
    if (extensions.indexOf(extend.toLowerCase()) != -1)
        return 0;
    else
        return -1;
}

/**
 * 指定した拡張子のファイルが格納されていないディレクトリ一覧を取得する。
 * @param {string} dir - 取得するディレクトリのrootパス。
 */
//const excludeDirs = async (dir: string) : Promise<string[]> => {
//    const dirents = await fs.promises.readdir(dir, { withFileTypes: true });
//    const _excludeDirs = [];
//    for(const dirent of dirents.filter( dirent => dirent.isDirectory() )) {
//        const result = await readdir(dirent.name, []).catch(err => {
//            console.error("Error:", err);
//        });
//
//        if(result === undefined) {
//            _excludeDirs.push(dirent.name);
//            console.log(`Debug: ${dirent.name} is no file`);
//        }
//        else if( _fileExtensionFilter(result).length ) {
//            console.log(`Debug: ${dirent.name} is verilog file directory`);
//        }
//        else {
//            _excludeDirs.push(dirent.name);
//            console.log(`Debug: ${dirent.name} is no verilog file directory`);
//        }
//        console.log(`Debug: ${result}`);
//    }
//    return Promise.resolve(_excludeDirs);
//}

//(async () => {
//    const result = await readdir(".", [], true, ['v', 'vh', 'vhd', 'sv', 'svh']);
//    console.log(result);
//
//    //const result = await readdir(".", []).catch(err => {
//    //    console.error("Error:", err);
//    //});
//    //console.log(result);
//    //if(result !== undefined)
//    //    console.log(_fileExtensionFilter(result));
//})();

export { readdir };