# rocnikovy_projekt

Název projektu:
Virtuální sázková aplikace na fotbalové zápasy

✅ Cíle a kritéria projektu:
Projekt bude simulovat sázení na skutečné fotbalové zápasy za virtuální měnu. Uživatelé budou moci soutěžit mezi sebou v rámci přátelských žebříčků.

Funkční požadavky:
Zobrazení reálných zápasů (Top 5 evropských lig + evropské poháry)

Možnost sázet na zápasy (výsledek 1/X/2) za virtuální měnu

Automatické vyhodnocení sázek po skončení zápasů

Registrace a přihlášení uživatelů

Zůstatek účtu a historie sázek

Přidávání kamarádů a soukromé žebříčky

Globální leaderboard

Admin rozhraní pro správu dat a zápasů

🔨 Použité technologie:
Vrstva	Technologie
Frontend (mobilní appka)	Flutter (Dart)
Backend / API	Django + Django REST Framework
Databáze	PostgreSQL (nebo SQLite pro vývoj)
Získávání reálných dat	API-Football (REST API pro zápasy a výsledky)
Autentizace	JWT (token-based authentication)
Závislosti backendu	Python, pip, virtualenv

📆 Fáze projektu (časový plán):
Fáze	Popis	Technologie	Výstup
1. Analýza a návrh	Rozdělení funkcí, návrh databáze a rozhraní	Papír / Figma / dbdiagram.io	ER diagram, UI návrhy
2. Backend - základ	Django projekt, modely pro uživatele, zápasy a sázky	Django ORM	REST API (základ)
3. API integrace	Napojení na fotbalové API (zápasy + výsledky)	Django, requests	Automatické získávání zápasů
4. Flutter UI	Základní obrazovky – login, seznam zápasů, profil	Flutter	První prototyp appky
5. Funkce sázení	Přidání sázek, výpočet výsledků, virtuální měna	Django + Flutter	Kompletní herní logika
6. Přátelé a žebříček	Přidávání přátel, tabulka úspěšnosti	Django + Flutter	Sociální prvek aplikace
7. Testování a ladění	Testy, opravy, validace dat	Pytest / Flutter Test	Hotová appka
8. Prezentace a dokumentace	README, video, obhajoba	Markdown / PDF	Dokumentace projektu
