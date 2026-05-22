# MyDrama Backend (Django REST + Supabase + TMDB)

API backend untuk aplikasi Flutter MyDrama. Data drakor diambil dari **TMDB** (ongoing, Korea, tahun 2020–2026) dan disimpan di **Supabase PostgreSQL** (atau SQLite untuk development lokal).

## Setup

### 1. Virtual environment

```powershell
cd backend
py -3 -m venv venv
.\venv\Scripts\pip install -r requirements.txt
```

### 2. Environment

Salin `.env.example` ke `.env` dan isi:

| Variabel | Keterangan |
|----------|------------|
| `DATABASE_URL` | Connection string Supabase (PostgreSQL URI) |
| `TMDB_API_KEY` | API key TMDB |
| `USE_SQLITE` | `True` untuk dev tanpa Supabase |
| `SECRET_KEY` | Django secret key |
| `ALLOWED_HOSTS` | `localhost,127.0.0.1,10.0.2.2` (+ IP LAN untuk device fisik) |

**Supabase:** Project Settings → Database → Connection string → URI (mode Transaction pooler direkomendasikan).

### 3. Migrasi database

```powershell
.\venv\Scripts\python manage.py migrate
```

### 4. Sync data dari TMDB

```powershell
.\venv\Scripts\python manage.py sync_dramas --max-pages=20
```

Proses ini mengambil **semua** drakor Korea (semua status: ongoing & ended) dengan tahun premiere 2020–2026, beserta genre, tag (keywords), poster, dan main cast.

### Auth & user

```powershell
.\venv\Scripts\python manage.py seed_users
```

| Endpoint | Method | Deskripsi |
|----------|--------|-----------|
| `/api/auth/register/` | POST | Daftar user baru |
| `/api/auth/login/` | POST | Login, dapat token |
| `/api/auth/me/` | GET/PATCH | Profil user (header `Authorization: Token ...`) |
| `/api/dramas/{id}/favorite/` | POST | Toggle favorit |
| `/api/dramas/{id}/mylist/` | POST | Toggle my list |
| `/api/dramas/favorites/` | GET | Daftar favorit user |
| `/api/dramas/my-list/` | GET | Daftar my list user |

### 5. Jalankan server

```powershell
.\venv\Scripts\python manage.py runserver 0.0.0.0:8000
```

## API Endpoints

| Method | URL | Deskripsi |
|--------|-----|-----------|
| GET | `/api/categories/` | Semua genre TV TMDB + `All` |
| GET | `/api/dramas/` | Daftar drama (`?search=`, `?category=`) |
| GET | `/api/dramas/{id}/` | Detail drama + main cast |
| GET | `/api/dramas/popular/` | 10 drama rating tertinggi (2020–2026) |
| GET | `/api/dramas/recently-added/` | 4 drama ongoing terbaru tahun **2026** |
| GET | `/api/dramas/{id}/you-may-also-like/` | Drama lain yang memiliki main cast sama |

Query opsional (state lokal Flutter): `favorite_ids=1,2` dan `my_list_ids=3`.

### Contoh response drama

```json
{
  "id": "12",
  "title": "Sweet Home",
  "year": 2020,
  "rating": 8.3,
  "genres": ["Horror", "Drama"],
  "tags": ["monster", "apocalypse"],
  "synopsis": "...",
  "poster_url": "https://image.tmdb.org/t/p/w500/...",
  "primary_genre": "Horror",
  "is_favorite": false,
  "is_in_my_list": false,
  "main_cast": [
    { "name": "Song Kang", "photo_url": "https://image.tmdb.org/t/p/w500/..." }
  ]
}
```

## Logika bisnis

- **Categories:** Semua genre dari TMDB `/genre/tv/list` (bukan dummy 4 item).
- **Recently added:** 4 drakor ongoing dengan `year = 2026`, urut `first_air_date` terbaru.
- **You may also like:** Semua drakor yang berbagi minimal satu **main cast** (top 6 billing) dengan drama yang dibuka.

## Flutter

Set base URL di `lib/config/api_config.dart` atau lewat build flag:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```
