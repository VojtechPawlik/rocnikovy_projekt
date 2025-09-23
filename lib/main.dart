import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  int _selectedDayIndex = 0;
  final List<DateTime> _days = List<DateTime>.generate(
    5,
    (i) => DateTime.now().add(Duration(days: i)),
  );
  final Set<String> _favoriteTeams = <String>{};
  int _coins = 1000; // virtuální měna
  final List<_SlipSelection> _betSlip = <_SlipSelection>[];
  final List<_BetRecord> _history = <_BetRecord>[];
  int _stake = 10; // výchozí vklad pro tiket

  List<Widget> get _pages => <Widget>[
        _buildHomePage(),
        _buildStandingsPage(),
        _buildHistoryPage(),
        _buildFavoritesPage(),
        _buildBonusesPage(),
      ];

  List<_Match> _getMatchesForDay(int dayIndex) {
    // Mock data per day
    final DateTime day = _days[dayIndex];
    final String d = '${day.year}-${day.month}-${day.day}';
    return <_Match>[
      _Match(
        league: 'FORTUNA:Liga',
        time: '14:00',
        homeTeam: 'Sparta',
        awayTeam: 'Slavia',
        oddsHome: 2.1,
        oddsDraw: 3.2,
        oddsAway: 3.0,
        id: 'sparta-slavia-$d',
        isLive: dayIndex == 0,
        minute: dayIndex == 0 ? 57 : null,
        scoreHome: dayIndex == 0 ? 1 : null,
        scoreAway: dayIndex == 0 ? 1 : null,
      ),
      _Match(
        league: 'FORTUNA:Liga',
        time: '16:30',
        homeTeam: 'Baník',
        awayTeam: 'Plzeň',
        oddsHome: 2.6,
        oddsDraw: 3.1,
        oddsAway: 2.5,
        id: 'banik-plzen-$d',
      ),
      _Match(
        league: 'Premier League',
        time: '19:00',
        homeTeam: 'Arsenal',
        awayTeam: 'Chelsea',
        oddsHome: 2.2,
        oddsDraw: 3.4,
        oddsAway: 3.1,
        id: 'ars-che-$d',
      ),
    ];
  }

  void _toggleFavorite(String team) {
    setState(() {
      if (_favoriteTeams.contains(team)) {
        _favoriteTeams.remove(team);
      } else {
        _favoriteTeams.add(team);
      }
    });
  }

  void _addToSlip({required String marketLabel, required double odds, required _Match match}) {
    setState(() {
      // prevent duplicate same market for same match
      _betSlip.removeWhere((s) => s.matchId == match.id && s.marketLabel == marketLabel);
      _betSlip.add(_SlipSelection(
        matchId: match.id,
        description: '${match.homeTeam} vs ${match.awayTeam} — $marketLabel',
        odds: odds,
        marketLabel: marketLabel,
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Přidáno do tiketu')), 
    );
  }

  void _openBetSlip() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final double totalOdds = _betSlip.fold(1.0, (p, s) => p * s.odds);
        final double potential = _stake * totalOdds;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 8),
                  const Text('Tiket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('Kurz: ${totalOdds.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8),
              if (_betSlip.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Tiket je prázdný'),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final s = _betSlip[index];
                      return ListTile(
                        leading: const Icon(Icons.check_box),
                        title: Text(s.description),
                        subtitle: Text('Kurz ${s.odds.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _betSlip.removeAt(index)),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _betSlip.length,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Vklad (💰)',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _stake.toString()),
                      onSubmitted: (v) {
                        final int? parsed = int.tryParse(v);
                        if (parsed != null && parsed > 0) {
                          setState(() => _stake = parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Možná výhra\n${potential.toStringAsFixed(2)}💰'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() => _betSlip.clear());
                      },
                      child: const Text('Vyčistit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _betSlip.isEmpty
                          ? null
                          : () {
                              if (_coins < _stake) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(content: Text('Nedostatek mincí')),
                                );
                                return;
                              }
                              setState(() {
                                _coins -= _stake;
                                _history.insert(0, _BetRecord(
                                  createdAt: DateTime.now(),
                                  selections: List<_SlipSelection>.from(_betSlip),
                                  stake: _stake,
                                  totalOdds: totalOdds,
                                ));
                                _betSlip.clear();
                              });
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(content: Text('Sázka podána')),
                              );
                            },
                      child: const Text('Vsadit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDaySwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final DateTime day = _days[index];
          final String label = index == 0
              ? 'Dnes'
              : index == 1
                  ? 'Zítra'
                  : '${day.day}.${day.month}';
          final bool selected = index == _selectedDayIndex;
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => setState(() => _selectedDayIndex = index),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemCount: _days.length,
        ),
      ),
    );
  }

  Widget _buildMatchTile(_Match m) {
    final bool favHome = _favoriteTeams.contains(m.homeTeam);
    final bool favAway = _favoriteTeams.contains(m.awayTeam);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (m.isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('LIVE ${m.minute}\'', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                else
                  Text(m.time, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleFavorite(m.homeTeam),
                        child: Icon(
                          favHome ? Icons.star : Icons.star_border,
                          color: favHome ? Colors.amber : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(m.homeTeam, overflow: TextOverflow.ellipsis)),
                      if (m.isLive && m.scoreHome != null && m.scoreAway != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${m.scoreHome}:${m.scoreAway}'),
                        ),
                        const SizedBox(width: 6),
                      ]
                      else
                        const Text(' vs '),
                      Expanded(child: Text(m.awayTeam, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _toggleFavorite(m.awayTeam),
                        child: Icon(
                          favAway ? Icons.star : Icons.star_border,
                          color: favAway ? Colors.amber : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OddButton(
                  label: '1',
                  value: m.oddsHome,
                  onPressed: () => _addToSlip(marketLabel: '1', odds: m.oddsHome, match: m),
                ),
                _OddButton(
                  label: 'X',
                  value: m.oddsDraw,
                  onPressed: () => _addToSlip(marketLabel: 'X', odds: m.oddsDraw, match: m),
                ),
                _OddButton(
                  label: '2',
                  value: m.oddsAway,
                  onPressed: () => _addToSlip(marketLabel: '2', odds: m.oddsAway, match: m),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    final List<_Match> matches = _getMatchesForDay(_selectedDayIndex);
    final Map<String, List<_Match>> byLeague = <String, List<_Match>>{};
    for (final m in matches) {
      byLeague.putIfAbsent(m.league, () => <_Match>[]).add(m);
    }
    final List<String> leagues = byLeague.keys.toList();
    return Column(
      children: [
        _buildDaySwitcher(),
        Expanded(
          child: ListView.builder(
            itemCount: leagues.length,
            itemBuilder: (context, leagueIndex) {
              final league = leagues[leagueIndex];
              final list = byLeague[league]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                    child: Text(league, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  ...list.map(_buildMatchTile),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStandingsPage() {
    return const Center(child: Text('Žebříček – brzy'));
  }

  Widget _buildHistoryPage() {
    if (_history.isEmpty) {
      return const Center(child: Text('Zatím žádné sázky'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final _BetRecord r = _history[index];
        return ListTile(
          leading: const Icon(Icons.receipt_long),
          title: Text(r.selections.map((s) => s.description).join(' + ')),
          subtitle: Text('Vklad ${r.stake}💰 • Kurz ${r.totalOdds.toStringAsFixed(2)} • ${r.createdAt.hour.toString().padLeft(2, '0')}:${r.createdAt.minute.toString().padLeft(2, '0')}'),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: _history.length,
    );
  }

  Widget _buildFavoritesPage() {
    if (_favoriteTeams.isEmpty) {
      return const Center(child: Text('Žádné oblíbené týmy zatím nejsou'));
    }
    final List<String> teams = _favoriteTeams.toList()..sort();
    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final String team = teams[index];
        return ListTile(
          leading: const Icon(Icons.star, color: Colors.amber),
          title: Text(team),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => _toggleFavorite(team),
          ),
        );
      },
    );
  }

  Widget _buildBonusesPage() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        ListTile(
          leading: Icon(Icons.card_giftcard),
          title: Text('Denní bonus: 50 Kč freebet'),
          subtitle: Text('Platí jen dnes'),
        ),
        ListTile(
          leading: Icon(Icons.local_fire_department),
          title: Text('Boost kurzů na derby +10%'),
          subtitle: Text('Limitované'),
        ),
      ],
    );
  }

  void _openLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Přihlášení',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Heslo',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Přihlášení – zatím jen ukázka')),
                  );
                },
                child: const Text('Přihlásit se'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Registrace – zatím jen ukázka')),
                  );
                },
                child: const Text('Registrovat'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Chip(
              avatar: const Icon(Icons.monetization_on, size: 18),
              label: Text('$_coins'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Vyhledávání',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vyhledávání – zatím jen ukázka')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profil / Přihlášení',
            onPressed: _openLoginSheet,
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Rozcestník',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Domů'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Stránka 1'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Stránka 2'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 2);
                },
              ),
            ],
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomSheet: _betSlip.isEmpty
          ? null
          : Material(
              elevation: 6,
              color: Theme.of(context).colorScheme.surface,
              child: InkWell(
                onTap: _openBetSlip,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag),
                      const SizedBox(width: 8),
                      Text('Tiket: ${_betSlip.length} výběr(y)'),
                      const Spacer(),
                      TextButton(
                        onPressed: _openBetSlip,
                        child: const Text('Otevřít tiket'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _currentIndex = 0);
        },
        tooltip: 'Domů',
        child: const Icon(Icons.home),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.leaderboard,
                color: _currentIndex == 1 ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: 'Žebříček',
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            IconButton(
              icon: Icon(
                Icons.history,
                color: _currentIndex == 2 ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: 'Historie',
              onPressed: () => setState(() => _currentIndex = 2),
            ),
            const Spacer(), // space for FAB notch
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: _currentIndex == 3 ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: 'Oblíbené',
              onPressed: () => setState(() => _currentIndex = 3),
            ),
            IconButton(
              icon: Icon(
                Icons.card_giftcard,
                color: _currentIndex == 4 ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: 'Bonusy',
              onPressed: () => setState(() => _currentIndex = 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _Match {
  final String id;
  final String time;
  final String homeTeam;
  final String awayTeam;
  final String league;
  final double oddsHome;
  final double oddsDraw;
  final double oddsAway;
  final bool isLive;
  final int? minute;
  final int? scoreHome;
  final int? scoreAway;

  const _Match({
    required this.id,
    required this.time,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.oddsHome,
    required this.oddsDraw,
    required this.oddsAway,
    this.isLive = false,
    this.minute,
    this.scoreHome,
    this.scoreAway,
  });
}

class _OddButton extends StatelessWidget {
  final String label;
  final double value;
  final VoidCallback onPressed;
  const _OddButton({required this.label, required this.value, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }
}

class _SlipSelection {
  final String matchId;
  final String description;
  final double odds;
  final String marketLabel;
  const _SlipSelection({required this.matchId, required this.description, required this.odds, required this.marketLabel});
}

class _BetRecord {
  final DateTime createdAt;
  final List<_SlipSelection> selections;
  final int stake;
  final double totalOdds;
  const _BetRecord({required this.createdAt, required this.selections, required this.stake, required this.totalOdds});
}
