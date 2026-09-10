# SmartShop — E-Commerce Web Application (Java / JSP / MySQL)

A modern, responsive e-commerce web platform built with Java Servlets, JSP, JSTL, and MySQL.

---

## 🚀 Features
- **Storefront**: Browse categories, search products, responsive product cards, product details & reviews.
- **Shopping Cart**: Add to cart, quantity controls, cart subtotal calculation.
- **Checkout & Orders**: Address management, payment simulation, order history & order details.
- **User Authentication**: Secure customer login & registration.
- **Admin Dashboard**: Analytics, product management (Add/Edit/Delete), order status tracking, user management.

---

## 🛠 Tech Stack
- **Backend**: Java 21, Jakarta EE Servlets 6.0, JSTL 3.0
- **Database**: MySQL 8.0+
- **Frontend**: Vanilla CSS, Modern Responsive UI, Vanilla JS
- **Server / Build**: Apache Maven, Apache Tomcat 10.1

---

## 📦 Database Configuration & Environment Variables

| Variable | Description | Default (Local) |
|---|---|---|
| `DB_URL` | JDBC MySQL connection URL | `jdbc:mysql://localhost:3306/ecommerce?allowPublicKeyRetrieval=true&useSSL=false` |
| `DB_USER` | MySQL Username | `root` |
| `DB_PASSWORD` | MySQL Password | `shashank@9980` |

Database schema and initial seed data are located at `src/main/resources/schema.sql`.

---

## 💻 Local Setup & Execution

### 1. Database Setup
Make sure MySQL is running and create the database schema:
```sql
CREATE DATABASE IF NOT EXISTS smartshop;
USE smartshop;
-- Execute src/main/resources/schema.sql
```

### 2. Run with Embedded Tomcat (Maven Cargo)
```bash
mvn package cargo:run
```
Visit: [http://localhost:8080](http://localhost:8080)

---

## 🌐 Deploy to GitHub

```bash
# 1. Initialize git in the ecommerce folder (if not already done)
git init

# 2. Add files and make initial commit
git add .
git commit -m "Initial commit: SmartShop web application"

# 3. Create a repository on GitHub (e.g. ecommerce-java-app)

# 4. Link remote and push
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/<YOUR_REPO_NAME>.git
git push -u origin main
```

---

## ☁️ Deploying for Customers (Production Options)

### Option 1: Railway (Recommended - Fastest & Easiest)
1. Go to [railway.app](https://railway.app) and sign in with GitHub.
2. Click **New Project** > **Provision MySQL**.
3. In MySQL Database > **Data** tab, import `src/main/resources/schema.sql`.
4. Click **New Service** > **GitHub Repo** > Select your repository.
5. In your service **Variables** tab, set:
   - `DB_URL`: `jdbc:mysql://${{MYSQLHOST}}:${{MYSQLPORT}}/${{MYSQLDATABASE}}?allowPublicKeyRetrieval=true&useSSL=false`
   - `DB_USER`: `${{MYSQLUSER}}`
   - `DB_PASSWORD`: `${{MYSQLPASSWORD}}`
6. Railway will automatically detect the `Dockerfile`, build, and generate a live public URL (e.g., `https://ecommerce-production.up.railway.app`).

### Option 2: Render
1. Create a MySQL database (e.g. on [Aiven.io](https://aiven.io) or Render).
2. On [render.com](https://render.com), click **New +** > **Web Service**.
3. Connect your GitHub repository.
4. Select **Docker** environment and add your environment variables (`DB_URL`, `DB_USER`, `DB_PASSWORD`).
5. Click **Deploy Web Service**.

### Option 3: AWS / DigitalOcean / VPS (Ubuntu + Tomcat + MySQL)
1. Install Java 21, Tomcat 10, and MySQL.
2. Build the WAR: `mvn clean package`.
3. Copy `target/smartshop.war` to `/var/lib/tomcat10/webapps/ROOT.war`.
4. Point your domain (e.g. `www.yourstore.com`) with an Nginx reverse proxy + SSL certificate (Certbot).
