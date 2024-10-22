const path = require('path');

module.exports = {
    entry: './src/main.ts', // Use main.ts for TypeScript
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'dist'),
        clean: true,
    },
    resolve: {
        extensions: ['.tsx', '.ts', '.js'],
    },
    module: {
        rules: [
            {
                test: /\.tsx?$/,
                use: 'ts-loader',
                exclude: /node_modules/,
            },
        ],
    },
    devServer: {
        static: './dist',
    },
    mode: 'development', // Change to 'production' for production builds
};
