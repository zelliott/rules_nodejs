/// <reference types="node"/>
/// <reference lib="es2017"/>

import * as fs from 'fs';
import * as path from 'path';

import {
    Extractor, ExtractorConfig, IConfigFile, IExtractorConfigPrepareOptions, IExtractorInvokeOptions
} from '@microsoft/api-extractor';

const [entryPoint, tsconfig, moduleName, docModelOut] = process.argv.slice(2);

const pkgJson = path.resolve(path.dirname(entryPoint), 'package.json');
fs.writeFileSync(
  pkgJson,
  JSON.stringify({
    name: moduleName,
    version: '0.0.0',
  })
);

const extractorOptions: IExtractorInvokeOptions = {
  localBuild: true,
  showVerboseMessages: true,
  showDiagnostics: true,
};

const configObject: IConfigFile = {
  compiler: {
    tsconfigFilePath: path.resolve(tsconfig),
  },
  projectFolder: path.resolve(path.dirname(entryPoint)),
  mainEntryPointFilePath: path.resolve(entryPoint),
  docModel: {
    enabled: true,
    apiJsonFilePath: path.resolve(docModelOut),
  },
  apiReport: {
    enabled: false,
    reportFileName: 'noop',
  },
  dtsRollup: {
    enabled: false,
  },
  tsdocMetadata: {
    enabled: false,
  },
};
const options: IExtractorConfigPrepareOptions = {
  configObject,
  packageJson: undefined,
  packageJsonFullPath: pkgJson,
  configObjectFullPath: undefined,
};
const extractorConfig = ExtractorConfig.prepare(options);

const { succeeded } = Extractor.invoke(extractorConfig, extractorOptions);
process.exitCode = succeeded ? 0 : 1;
