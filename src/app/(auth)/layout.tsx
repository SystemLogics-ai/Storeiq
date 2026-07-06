export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-row items-center justify-around h-screen">
      <div className="hidden sm:flex flex-col items-center gap-3 select-none">
        <span className="text-6xl font-bold tracking-tight">
          <span className="text-blue-600">Store</span>IQ
        </span>
        <p className="text-gray-400 text-lg">Inventory. Simplified.</p>
      </div>

      {children}
    </div>
  );
}
