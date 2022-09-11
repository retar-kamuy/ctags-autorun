import * as path from "path";
import * as vscode from "vscode";
import * as ls from "vscode-languageclient";
import * as child_process from "child_process";

import { readdir } from './execCtags';

let client: ls.LanguageClient;

export function activate(context: vscode.ExtensionContext) {
  // Language Server のプログラムのパス
  let serverModule = context.asAbsolutePath(path.join('server', 'out', 'server.js'));

  // Language Server の設定
  let serverOptions: ls.ServerOptions = {
    run: {
      module: serverModule,
      transport: ls.TransportKind.ipc
    },
    debug: {
      module: serverModule,
      transport: ls.TransportKind.ipc,
      // デバッグオプションはデバッグ時のみ付与する
      options: {
        execArgv: ["--nolazy", "--inspect=6010"]
      }
    }
  };

  const documentSelector = [
    { scheme: "file" },
  ] as ls.DocumentSelector;

  // Language Client の設定
  const clientOptions: ls.LanguageClientOptions = {
    documentSelector,
    // 同期する設定項目
    synchronize: {
      // "lll."の設定を指定しています
      configurationSection: "lll",
    }
  };

  // Language Client の作成
  client = new ls.LanguageClient(
    // 拡張機能のID
    "line-length-linter",
    // ユーザ向けの名前（出力ペインで使用されます）
    "Line Length Linter",
    serverOptions,
    clientOptions
  );

  vscode.workspace.onDidSaveTextDocument(e => {
    if (e) {
      console.log('ctags manager configure');
      execCtags(e);
    }
  })

  // Language Client の開始
  client.start();
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) {
    return undefined;
  }
  return client.stop();
}

async function execCtags(document: vscode.TextDocument): Promise<void> {

  const filePath = document.uri.fsPath;
  if (!filePath) {
    // ファイルが特定できない場合は何もしない
    return;
  }

  const workspaceRoot = (vscode.workspace.workspaceFolders && (vscode.workspace.workspaceFolders.length > 0))
    ? vscode.workspace.workspaceFolders[0].uri.fsPath : undefined;

  if (workspaceRoot !== undefined) {
    const result = await readdir(workspaceRoot, [], true, ['v', 'vh', 'vhd', 'sv', 'svh']).catch(err => {
      console.error("Error:", err);
    });
    let files;
    if (result !== undefined) {
      files = result.join(' ');
      const cmd = `ctags.exe -f "${workspaceRoot}\\.tags" --tag-relative --extras=f --fields=+K -R ${files}`;
      child_process.exec(cmd, (error, stdout, stderr) => {
        if (error) {
          console.error(stderr);
        }
        console.log(stdout);
      });
    }
  }
}