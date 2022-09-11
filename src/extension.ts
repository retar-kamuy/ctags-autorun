/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
import * as vscode from 'vscode';
import { CtagsTaskProvider } from './ctagsTaskProvider';

let ctagsTaskProvider: vscode.Disposable | undefined;

export function activate(_context: vscode.ExtensionContext): void {
	const workspaceRoot = (vscode.workspace.workspaceFolders && (vscode.workspace.workspaceFolders.length > 0))
		? vscode.workspace.workspaceFolders[0].uri.fsPath : undefined;
	if (!workspaceRoot) {
		return;
	}
		
	ctagsTaskProvider = vscode.tasks.registerTaskProvider(CtagsTaskProvider.CtagsType, new CtagsTaskProvider(workspaceRoot));
}

export function deactivate(): void {
	if (ctagsTaskProvider) {
		ctagsTaskProvider.dispose();
	}
}