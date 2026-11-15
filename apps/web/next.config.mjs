/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: {
    unoptimized: true,
  },
  reactStrictMode: true,
  transpilePackages: [
    '@sis/shared-types',
    '@sis/shared-validation',
    '@sis/api-contracts',
    '@sis/design-tokens',
  ],
};

export default nextConfig;
