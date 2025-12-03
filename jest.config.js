const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    moduleNameMapper: {
        '^@salesforce/apex$': '<rootDir>/tests/jest-mocks/apex',
        '^@salesforce/schema$': '<rootDir>/tests/jest-mocks/schema',
        '^lightning/navigation$': '<rootDir>/tests/jest-mocks/lightning/navigation',
        '^lightning/platformShowToastEvent$': '<rootDir>/tests/jest-mocks/lightning/platformShowToastEvent',
    },
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver'],
    testPathIgnorePatterns: [
        '<rootDir>/node_modules/',
        '<rootDir>/.sfdx/',
    ],
    coverageDirectory: 'coverage',
    collectCoverageFrom: [
        'force-app/**/*.js',
        '!force-app/**/__tests__/**',
    ],
    coverageThreshold: {
        global: {
            branches: 80,
            functions: 80,
            lines: 80,
            statements: 80,
        },
    },
};
