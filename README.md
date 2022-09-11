# vscode-extension-samples

Setup package.json
```
npm init
```

Install TypeScript compiler
```
npm install --save-dev typescript
```

When use with 'fs' package at TypeScript, install 'node' package
```
npm install --save-dev @types/node
```

use ESLint

1. install npm
```
npm install --save-dev eslint
```

2. Extension ESLint

3. Setup ESLint 
```
>node_modules\.bin\eslint --init

√ How would you like to use ESLint? · style
√ What type of modules does your project use? · none
√ Which framework does your project use? · none
√ Does your project use TypeScript? · No / Yes
√ Where does your code run? · node
√ How would you like to define a style for your project? · guide
√ Which style guide do you want to follow? · standard-with-typescript
√ What format do you want your config file to be in? · JSON
Checking peerDependencies of eslint-config-standard-with-typescript@latest
The config that you've selected requires the following dependencies:

eslint-config-standard-with-typescript@latest @typescript-eslint/eslint-plugin@^5.0.0 eslint@^8.0.1 eslint-plugin-import@^2.25.2 eslint-plugin-n@^15.0.0 eslint-plugin-promise@^6.0.0 typescript@*
√ Would you like to install them now? · No / Yes
√ Which package manager do you want to use? · npm
```