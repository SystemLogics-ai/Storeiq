interface AuthHeaderProps {
  title: string;
  subtitle: string;
}

export function AuthHeader({ title, subtitle }: AuthHeaderProps) {
  return (
    <>
      <div className="block sm:hidden mb-2">
        <span className="text-2xl font-bold tracking-tight">
          <span className="text-blue-600">Store</span>IQ
        </span>
      </div>
      <h1 className="font-bold text-2xl sm:text-4xl text-center">{title}</h1>
      <p className="opacity-70 text-center">{subtitle}</p>
    </>
  );
}
