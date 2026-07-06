import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // devIndicators:false,
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "tiutypdrzmgyjfmahgeg.supabase.co",
      },
    ],
  },
};

export default nextConfig;
