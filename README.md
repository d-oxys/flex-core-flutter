# Backend for Flex-Core

> Tugas UAS Desain Kreatif Aplikasi Dan Game

Teknologi yang digunakan :

1. Next JS
2. Firebase

## Cara install

1. Buka Git Bash
2. Clone project di https://github.com/d-oxys/flex-core
3. Install Package Yang Di Butuhkan : npm install
4. Jalankan Lokal Server : npm run dev
   > server berjalan di port 3000, pastikan port tidak terpakai
5. server juga berjalan di https://flex-core.vercel.app/api

## API

### Register

#### User Register

- URL : /api/register
- Method : POST
- Request Body:
  - name as string
  - email as string
  - password as string
- Response :

```json
{
  "status": "ok",
  "message": "register successfuly"
}
```

### Login

#### User Login

- URL : /api/login
- Method : POST
- Request Body:
  - email as string
  - password as string
- Response:

```json
{
  "status": "ok",
  "message": "logged in successfully",
  "user": {
    "name": "Your Name",
    "email": "your.email@example.com",
    "role": "role"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiam9obiIsImVtYWlsIjoiam9obmRvZUBnbWFpbC5jb20iLCJyb2xlIjoidXNlciIsImN1c3RvbWVyX2lkIjozLCJpYXQiOjE3MDA2MzQxNDR9.sgoDeu8lNRm_SfoXbb7MkpMEn4ghG0g4Le0GFyN2bn8"
}
```

### WorkoutPlan

#### Menambahkan WorkoutPlan

- URL : /api/workout
- Method : POST
- Request Body:
  - nama as string
  - fotoWO as string
  - Waktu Latihan as string
  - Kategori as string
  - funFacts as string
  - energi Yang digunakan as array of string
  - alat as array of string
  - tutorial as array of string
- Response:

```json
{
  "status": "ok",
  "message": "Workout plan submitted successfully!",
  "reportId": "123456"
}
```

#### Get All Report (params: Kategori)

- URL : /api/workout
- Method : GET
- parameter:
  - q = search
  - l =limit
  - skip = skip
  - example : /workout?q=lengan&limit=20
- Response:

```json
{
  "status": "ok",
  "message": "Workout plans fetched successfully!",
  "workoutPlans": [
    {
      "funFacts": "Push up adalah latihan yang sangat efektif untuk membangun kekuatan otot bagian atas tubuh.",
      "WaktuLatihan": "15-30 menit",
      "tutorial": [
        "Mulailah dengan posisi plank, dengan tangan sedikit lebih lebar dari bahu.",
        "Turunkan tubuh Anda sampai dada hampir menyentuh lantai.",
        "Jaga punggung dan kaki tetap lurus.",
        "Dorong tubuh Anda kembali ke posisi awal."
      ],
      "nama": "Push Up",
      "energiYangdigunakan": ["200 kkal energi", "25 gram karbohidrat", "8 gram lemak", "7 gram protein"],
      "alat": ["Matras olahraga"],
      "fileURL": "https://via.placeholder.com/400",
      "Kategori": "dada dan lengan"
    }
  ]
}
```

#### Detail Report

- URL : /workout/id
- Method : GET
  Request Header:
  - Authorization : 'Bearer {token}'
- Response:

```json
{
  "status": "ok",
  "message": "Workout plans fetched successfully!",
  "workoutPlans": [
    {
      "funFacts": "Push up adalah latihan yang sangat efektif untuk membangun kekuatan otot bagian atas tubuh.",
      "Waktu Latihan": "15-30 menit",
      "tutorial": [
        "Mulailah dengan posisi plank, dengan tangan sedikit lebih lebar dari bahu.",
        "Turunkan tubuh Anda sampai dada hampir menyentuh lantai.",
        "Jaga punggung dan kaki tetap lurus.",
        "Dorong tubuh Anda kembali ke posisi awal."
      ],
      "nama": "Push Up",
      "energi Yang digunakan": ["200 kkal energi", "25 gram karbohidrat", "8 gram lemak", "7 gram protein"],
      "alat": ["Matras olahraga"],
      "fileURL": "https://via.placeholder.com/400",
      "Kategori": "dada dan lengan"
    }
  ]
}
```

### Nutrition Plan

#### Membuat Rencana Nutrisi

- URL : /api/calculateCalories
- Method : POST
- Request Body:
  - age as number
  - weight as number
  - height as number
  - gender as string ('male' or 'female')
  - activity as number
  - goal as string ('deficit' or not 'deficit')
  - mealsPerDay as number (default is 3)
- Response:

```json
{
  "calories": number,
  "carbs": number,
  "protein": number,
  "fat": number,
  "bmiCategory": string,
  "advice": string,
  "idealWeight": number,
  "meals": [
    {
      "calories": number,
      "carbs": number,
      "protein": number,
      "fat": number
    }
  ]
}


