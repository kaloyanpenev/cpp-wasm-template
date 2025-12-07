import { defineConfig } from 'vite';
import { resolve } from 'path';
import { readFileSync } from 'fs';

// Read project config from central source
const projectConfig = JSON.parse(
    readFileSync(resolve(__dirname, '../project.json'), 'utf-8')
);

export default defineConfig({
    root: '.',
    base: './',
    build: {
        outDir: 'dist',
        emptyOutDir: true,
        rollupOptions: {
            input: {
                main: resolve(__dirname, 'index.html'),
            },
        },
    },
    server: {
        port: 3000,
        open: true,
    },
    preview: {
        port: 4173,
    },
    optimizeDeps: {
        exclude: [`${projectConfig.name}.js`],
    },
    assetsInclude: ['**/*.wasm'],
    define: {
        __PROJECT_NAME__: JSON.stringify(projectConfig.name),
        __PROJECT_DISPLAY_NAME__: JSON.stringify(projectConfig.display_name),
        __WASM_MODULE_PATH__: JSON.stringify(`./${projectConfig.name}.js`),
    },
});

