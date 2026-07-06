
# 📦 Inventory Management System

A modern, responsive, and robust Inventory Management Dashboard built with **Next.js 16**, **TypeScript**, **TailwindCSS**, and **Supabase**. This application helps businesses track stock levels, manage suppliers, process purchase orders, and monitor sales performance in real-time.

## ✨ Features

### 📊 Dashboard & Analytics
- **Real-time Overview:** View total revenue, profit, costs, and quantity sold.
- **Stock Health:** Visual indicators for In-Stock, Low Stock, and Out-of-Stock items.
- **Interactive Charts:** Visual data representation for sales trends and performance.

### 📦 Inventory Control
- **Product Management:** Create, Read, Update, and Delete (CRUD) products seamlessly.
- **Image Support:** Drag-and-drop image upload for products using Supabase Storage.
- **Smart Filtering:** Filter inventory by category, stock status, or perform global searches.
- **Low Stock Alerts:** Automatic notifications in the Topbar when items dip below the user-defined threshold.

### 🚚 Procurement (Restocking)
- **Purchase Orders:** Create restock orders directly from the product detail page.
- **Supplier Management:** Link products to specific suppliers for easy reordering.
- **Order Tracking:** Track order status (Pending, Shipped, Completed) and expected delivery dates.

### 📝 History
- **Transaction Logs:** Unified history tab showing both **Restock (In)** and **Sales (Out)** movements in a chronological timeline.

### 👤 User Management
- **Profile Settings:** Update personal details, email, and upload profile avatars.
- **Security:** Secure authentication via Supabase Auth.

## 🛠️ Tech Stack

- **Framework:** [Next.js 16](https://nextjs.org/) (App Router)
- **Language:** [TypeScript](https://www.typescriptlang.org/)
- **Styling:** [Tailwind CSS](https://tailwindcss.com/)
- **Backend & Database:** [Supabase](https://supabase.com/) (PostgreSQL)
- **Auth:** Supabase Auth
- **Storage:** Supabase Storage (for product images & avatars)
- **Icons:** Custom SVG components

## 🚀 Getting Started
Follow these steps to run the project locally.

### 1. Prerequisites
- Node.js (v18 or later)
- npm or yarn
- A Supabase account

### 2. Clone the Repository
```bash
git clone https://github.com/BoviliusMeidi/inventory-management.git
cd inventory-management
```

### 3. Install Dependencies
```bash
npm install
# or
yarn install
```

### 4. Environment Variables
1. Rename the existing `.env.example` file to `.env.local`
2. Open `.env.local` and update the Supabase credentials

### 5. Supabase Setup 🔑
To ensure the application functions correctly, you must set up the necessary tables and storage buckets in your Supabase project.

#### A. Database Schema
The complete database schema (tables, relations, and types) is available in [`supabase/migrations/0001_initial_schema.sql`](./supabase/migrations/0001_initial_schema.sql).
RPC functions required for core features are in [`supabase/functions/0002_rpcs.sql`](./supabase/functions/0002_rpcs.sql).
See [`docs/SETUP.md`](./docs/SETUP.md) for the full setup walkthrough.
**Quick Setup:**
1. Open your Supabase Dashboard.
2. Go to the **SQL Editor**.
3. Run `supabase/migrations/0001_initial_schema.sql`, then `supabase/functions/0002_rpcs.sql`.
4. Paste and click **Run**.

#### B. Storage Buckets
1. Navigate to the **Storage** section in Supabase.
2. Create a **new public bucket** named `images`.
3. Set up **Row Level Security (RLS)** policies to allow authenticated users to Upload, Update, and Select files.

### 6. Run Development Server
```bash
npm run dev
# or
yarn dev
```

### 7. Open in Browser
```bash
http://localhost:3000
```

## 📂 Project Structure
This project follows a feature-based architecture within the Next.js App Router, separating UI logic from business logic.

```bash
src/
├── app/                    # Next.js App Router
│   ├── (auth)/             # Public route group (Login, Signup, Recovery)
│   ├── (app)/              # Protected route group (Dashboard, Inventory)
│   └── layout.tsx          # Root layout and global providers
├── components/
│   ├── ui/                 # Reusable atomic components (Buttons, Cards, Inputs)
│   ├── features/           # Business-logic components organized by feature (Auth, Inventory)
│   └── layout/             # Structural components (Sidebar, Navbar, Footer)
├── lib/                    # Core logic and backend integration
│   ├── actions/            # Server Actions for data mutation
│   ├── supabase/           # Supabase client configurations (Client/Server/Middleware)
│   ├── utils/              # Helper functions, formatters, and validators
│   ├── constants.ts        # Global constants and configuration
│   └── types.ts            # TypeScript interfaces and type definitions
└── proxy.ts                # Route protection and session management
```

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
1. Fork the project
2. Create your Feature Branch (git checkout -b feature/AmazingFeature)
3. Commit your Changes (git commit -m 'Add some AmazingFeature')
4. Push to the Branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

## 📄 License
Distributed under the **MIT License**. See `LICENSE` for more information.

## 👨‍💻 Author
**Bovilius Meidi**

* Website: [BoviliusMeidi.vercel.app](https://portfolio-boviliusmeidis-projects.vercel.app/)
* LinkedIn: [BoviliusMeidi](https://linkedin.com/in/boviliusmeidi)
* GitHub: [@BoviliusMeidi](https://github.com/BoviliusMeidi)