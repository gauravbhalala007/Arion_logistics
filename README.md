# 📊 Arion Logistics KPI Dashboard

A unified **Amazon DSP KPI Dashboard** that automatically parses **weekly KPI PDFs**, computes normalized KPI scores (per Albert’s DSP rules), and visualizes driver performance in a responsive **Flutter Web Admin UI** with Firebase integration.

---

## 🚀 Overview

| Component | Tech | Description |
|------------|------|-------------|
| **Backend** | 🐍 FastAPI + pdfplumber + pandas | Parses Amazon DSP KPI PDF reports, extracts metrics, computes KPI scores and final ranks |
| **Frontend** | 💙 Flutter Web | Displays live KPI dashboard connected to Firebase |
| **Storage / Database** | ☁️ Firebase Firestore + Storage | Stores parsed reports, driver data, and weekly files |
| **Functions** | 🔥 Firebase Cloud Functions (optional) | Automates PDF parsing and Firestore updates when new files are uploaded |

---

## 🧩 Architecture

```
📂 arion_logistics/
│
├── backend/
│   ├── app.py             ← FastAPI service for PDF parsing
│   ├── requirements.txt   ← Backend dependencies
│   └── sample_pdfs/       ← Test PDFs
│
├── kpi_admin/             ← Flutter Web Admin UI
│   ├── lib/screens/scoreboard_page.dart
│   ├── lib/main.dart
│   └── pubspec.yaml
│
└── README.md              ← You are here
```

---

## ⚙️ Backend Setup (FastAPI PDF Parser)

### 1. Clone the repo

```bash
git clone https://github.com/gauravbhalala007/Arion_logistics.git
cd Arion_logistics/backend
```

### 2. Create and activate virtual environment

```bash
python3 -m venv venv
source venv/bin/activate  # on Mac/Linux
venv\Scripts\activate     # on Windows
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

If `requirements.txt` is missing, create one with:

```bash
pip install fastapi uvicorn pdfplumber pandas pydantic
pip freeze > requirements.txt
```

### 4. Run the FastAPI server

```bash
uvicorn app:app --reload
```

The API will be live at:
👉 **http://127.0.0.1:8000**

Check health:
```
GET /health → {"ok": true}
```

### 5. Upload and test parsing

Use the Swagger UI:
👉 http://127.0.0.1:8000/docs

Test endpoint:
```
POST /parse
Upload File → weekly_report.pdf
```

Output example:
```json
{
  "count": 10,
  "drivers": [
    {
      "Transporter ID": "AJ2HME0DRDXI1",
      "Delivered": 449,
      "DCR": 98.68,
      "POD": 94.84,
      "CC": 100,
      "CE": 0.0,
      "LoR DPMO": 0,
      "DNR DPMO": 0,
      "CDF DPMO": 3100,
      "LoR_Score": 100,
      "DNR_Score": 100,
      "CDF_Score": 93,
      "FinalScore": 97.5
    }
  ]
}
```

---

## 💻 Frontend Setup (Flutter Web Dashboard)

### 1. Navigate to Flutter project
```bash
cd ../kpi_admin
```

### 2. Install Flutter dependencies
```bash
flutter pub get
```

### 3. Run the web app
```bash
flutter run -d chrome
```

If you want to build and host it:
```bash
flutter build web
```

---

## 🔥 Firebase Configuration

1. Create a Firebase project in [Firebase Console](https://console.firebase.google.com).
2. Enable:
   - **Firestore Database**
   - **Storage**
3. Download `firebase_options.dart` or use your existing configuration in `main.dart`.
4. Update Firebase rules if needed for local testing:
   ```js
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```

---

## 🧠 KPI Calculation Summary (per Albert’s Formula)

| Metric | Formula | Description |
|--------|----------|-------------|
| **POD_Score** | `POD` | Already percentage |
| **CC_Score** | `CC` | Already percentage |
| **DCR_Score** | `DCR` | Already percentage |
| **CE_Score** | `100 - (CE × 50)` → min 50% | Customer Experience |
| **LoR_Score** | `max(70, 100 - (LoR / 1200 × 30))` | Lost Orders |
| **DNR_Score** | `max(70, 100 - (DNR / 1200 × 30))` | Delivered Not Received |
| **CDF_Score** | `max(0, 134.33 - 0.01333 × CDF)` | Compliance Deviation Factor |
| **FinalScore** | Average of all 7 KPI scores | Overall total score |

---

## 🧾 Firebase Collections Overview

| Collection | Purpose |
|-------------|----------|
| **drivers** | Driver master data (name, transporterId) |
| **reports** | Weekly report metadata (summary, upload date, etc.) |
| **scores**  | Parsed scores per driver (linked via reportRef) |

---

## 🪶 Flutter UI Features

- Upload weekly **CSV or PDF** directly from dashboard.
- Auto-refresh after upload via Firebase snapshot streams.
- Shows:
  - Driver name + ID
  - Rank
  - Total Score
  - All KPI Scores (DCR, DNR, LoR, POD, CC, CE, CDF)
- Uses **color-coded status badges**:
  - 💚 Fantastic (≥85)
  - 🟩 Great (≥70)
  - 🟨 Fair (≥55)
  - 🟥 Poor (<55)
- Fully responsive layout (no horizontal scroll).

---

## 🧪 Example Workflow

1. Upload `weekly_report.pdf` via the web UI.
2. FastAPI parses and computes scores → pushes to Firestore.
3. Dashboard auto-updates with new report and driver rankings.

---

## 🧰 Common Commands

```bash
# Start backend
uvicorn app:app --reload

# Start frontend
flutter run -d chrome

# Rebuild Flutter UI
flutter pub get && flutter build web
```

---

## 📦 Optional Enhancements

✅ Auto-trigger backend parsing via Firebase Cloud Function on new PDF upload  
✅ Export dashboard view as CSV  
✅ Add login/auth for restricted access  
✅ Deploy backend via Docker or Cloud Run  
✅ Host Flutter Web via Firebase Hosting  

---

## 👤 Author

**Gaurav Bhalala**  
📧 gauravbhalala007@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/gauravbhalala007)  
📦 [GitHub](https://github.com/gauravbhalala007)
