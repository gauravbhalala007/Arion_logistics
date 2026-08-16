# ARION Zeitkonto Flutter

Ky eshte moduli i vecante per **Oret shtese / Zeitkonto**, i ndare nga projekti ekzistues ARION Office.

## Cfare perfshin

- Profile punetoresh
- Regjistrim mujor: oret e muajit, oret e punuara, oret e paguara
- Llogaritje automatike: `oret e punuara - oret e muajit = overtime`
- Ndarje periudhash:
  - Jan - October 2025
  - November 2025 - Today
- Paid hours sipas periudhes
- Remaining hours / Zeitkonto
- Histori mujore per secilin punetor
- Gjenerim PDF me raportin e overtime
- Ruajtje lokale me `shared_preferences`

## Si hapet

1. Hape folderin `ARION_Zeitkonto_Flutter` ne VS Code ose Android Studio.
2. Ekzekuto:

```powershell
flutter pub get
flutter run
```

## Shenim

Ky version eshte pergatitur si baze Flutter. Nese do e lidhim me Firebase/Firestore, ruajtja lokale zëvendësohet me database online.
