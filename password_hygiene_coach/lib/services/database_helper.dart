import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:password/models/lesson.dart';

class DatabaseHelper {
  // Database constants
  static const _databaseName = "password_coach.db";
  static const _databaseVersion = 2;

  // Table and column names
  static const tableLessons = 'lessons';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnIconName = 'icon_name';
  static const columnContentJson = 'content_json';
  static const columnQuizDataJson = 'quiz_data_json';

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database object
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize FFI for desktop platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      try {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      } catch (e) {
        // Optional: Log the error, but allow the app to continue 
        // (it might fail later if db is needed)
        print("SQFLITE FFI INIT ERROR: $e"); 
      }
    }

    _database = await _initDatabase();
    return _database!;
  }

  // Initialize or open the database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from $oldVersion → $newVersion');
        await db.execute('DROP TABLE IF EXISTS $tableLessons');
        await _onCreate(db, newVersion);
        print('Lessons table recreated successfully.');
      },
    );
  }

  // Create the table and seed initial data
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableLessons (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnIconName TEXT NOT NULL,
        $columnContentJson TEXT NOT NULL,
        $columnQuizDataJson TEXT NOT NULL
      )
    ''');

    await _insertInitialLessons(db);
  }

  // Insert all predefined lessons
  Future<void> _insertInitialLessons(Database db) async {
    final List<Map<String, dynamic>> initialLessons = [
      // LESSON 1
      {
        columnTitle: "1. Creative Password Techniques",
        columnIconName: "key",
        columnContentJson: jsonEncode([
          "**1. Substitution (The L33T Fix):** Replace letters with similar-looking numbers or symbols (e.g., 'sunflower' → 'sun310w3r'). Avoid common substitutions like 'pa55w0rd'.",
          "**2. Word Combination (Passphrases):** Combine 3–4 random, unrelated words (e.g., 'BookCheeseTree').",
          "**3. Acronyms (Memory Trick):** Use first letters of a memorable phrase or quote (e.g., \"I like chocolate cake!\" → 'Ilcc!').",
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "When using letter-for-number substitution, what is the main risk to avoid?",
            'options': [
              "Using substitutions that hackers commonly try (e.g., 'pa55w0rd').",
              "Making the password longer than 15 characters.",
              "Forgetting the original word."
            ],
            'correctIndex': 0,
          },
          {
            'question': "Which method is generally recommended for creating a password that's easy to remember but hard to guess?",
            'options': [
              "Using a favorite pet's name.",
              "Creating an acronym from a unique lyric or quote.",
              "Repeating a single random word."
            ],
            'correctIndex': 1,
          },
          {
            'question': "What makes a passphrase like 'BillPlantKitchenEngine' strong?",
            'options': [
              "It uses personal info.",
              "It’s short and simple.",
              "It’s long, using unrelated words."
            ],
            'correctIndex': 2,
          },
          {
            'question': "Why should you avoid using a date like your birthdate in a password?",
            'options': [
              "It's too short.",
              "It's often public info easily guessed.",
              "It does not contain numbers."
            ],
            'correctIndex': 1,
          },
        ]),
      },

      // LESSON 2
      {
        columnTitle: "2. Core Principles of a Strong Password",
        columnIconName: "verified_user",
        columnContentJson: jsonEncode([
          "A strong password should be hard to guess — avoid 'password' or '123456'.",
          "* **Length:** Minimum 12 characters (14+ is better).",
          "* **Complexity:** Mix of letters, numbers, and symbols.",
          "* **Uniqueness:** Never reuse passwords across sites.",
          "* **Privacy:** Avoid personal info (like birthdates)."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "What is the recommended minimum length for a strong password?",
            'options': ["8 characters", "12 characters", "10 characters"],
            'correctIndex': 1,
          },
          {
            'question': "What is the critical rule of password hygiene for multiple accounts?",
            'options': [
              "Reuse passwords if they are 15+ characters.",
              "Never reuse the same password.",
              "Reuse only on non-financial sites."
            ],
            'correctIndex': 1,
          },
          {
            'question': "Why include upper/lowercase, numbers, and symbols?",
            'options': [
              "To increase complexity and make cracking harder.",
              "To comply with old standards.",
              "To make it easier to type."
            ],
            'correctIndex': 0,
          },
          {
            'question': "Which makes a password weakest?",
            'options': [
              "16 characters long.",
              "Common dictionary word or name.",
              "Contains special symbols."
            ],
            'correctIndex': 1,
          },
        ]),
      },

      // LESSON 3
      {
        columnTitle: "3. Password Managers: Your Security Vault",
        columnIconName: "lock_open",
        columnContentJson: jsonEncode([
          "Password managers store all your credentials securely, behind one strong **Master Password**.",
          "* Generate long, random passwords automatically.",
          "* Enforce uniqueness across sites.",
          "* Auto-fill only on legitimate domains."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "What is the most important password to protect?",
            'options': [
              "Your email password.",
              "Your bank account password.",
              "The Master Password for your manager."
            ],
            'correctIndex': 2,
          },
          {
            'question': "What do password managers use to generate passwords?",
            'options': [
              "Random number generators (RNGs).",
              "Common words.",
              "Your pet names."
            ],
            'correctIndex': 0,
          },
          {
            'question': "How do password managers prevent phishing?",
            'options': [
              "They block spam emails.",
              "They only auto-fill on legitimate domains.",
              "They replace passwords with fingerprints."
            ],
            'correctIndex': 1,
          },
          {
            'question': "What should you NOT use a password manager for?",
            'options': [
              "Generating complex passwords.",
              "Storing credit cards securely.",
              "Protecting your device from viruses."
            ],
            'correctIndex': 2,
          },
        ]),
      },

      // LESSON 4
      {
        columnTitle: "4. Deep Dive into Multi-Factor Authentication (MFA)",
        columnIconName: "security",
        columnContentJson: jsonEncode([
          "MFA adds a second layer of defense.",
          " Something you know (password).",
          " Something you have (phone, key).",
          " Something you are (fingerprint, face).",
          "Use authenticator apps or hardware keys — they’re safer than SMS."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "MFA requires how many different categories?",
            'options': [
              "One category.",
              "Two or more categories.",
              "Three categories."
            ],
            'correctIndex': 1,
          },
          {
            'question': "Which MFA method is least secure?",
            'options': [
              "SMS codes.",
              "Authenticator app codes.",
              "Hardware keys."
            ],
            'correctIndex': 0,
          },
          {
            'question': "A fingerprint scan falls under which MFA category?",
            'options': [
              "Something you know.",
              "Something you have.",
              "Something you are."
            ],
            'correctIndex': 2,
          },
        ]),
      },

      // LESSON 5
      {
        columnTitle: "5. Passkeys: The Password Replacement",
        columnIconName: "fingerprint",
        columnContentJson: jsonEncode([
          "Passkeys replace passwords using cryptography stored on your device.",
          "They’re phishing-resistant, easy to use, and secure — they never leave your device."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "What is the main advantage of passkeys?",
            'options': [
              "They’re longer.",
              "They’re phishing-resistant.",
              "They only use numbers."
            ],
            'correctIndex': 1,
          },
          {
            'question': "How do you typically use a passkey?",
            'options': [
              "By typing it manually.",
              "By using biometrics (face/fingerprint).",
              "By entering a one-time code."
            ],
            'correctIndex': 1,
          },
          {
            'question': "Where is the passkey secret stored?",
            'options': [
              "On the website's server.",
              "Encrypted on your device.",
              "In your email."
            ],
            'correctIndex': 1,
          },
        ]),
      },

      // LESSON 6
      {
        columnTitle: "6. Recognizing Scams: Phishing, Smishing, Vishing",
        columnIconName: "alternate_email",
        columnContentJson: jsonEncode([
          "Social engineering tricks you into giving info!",
          "**Phishing:** via Email.",
          " **Smishing:** via SMS.",
          " **Vishing:** via Phone calls.",
          "Red Flags : Urgency, bad grammar, generic greetings."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "'Smishing' refers to a scam via:",
            'options': ["Voice call", "Text message (SMS)", "Email"],
            'correctIndex': 1,
          },
          {
            'question': "What’s a big red flag in phishing emails?",
            'options': [
              "Company logo usage.",
              "Urgent threats or penalties.",
              "Sent during work hours."
            ],
            'correctIndex': 1,
          },
          {
            'question': "What’s the safest action for a suspicious email?",
            'options': [
              "Reply to verify.",
              "Close it and visit the site manually.",
              "Click 'unsubscribe'."
            ],
            'correctIndex': 1,
          },
          {
            'question': "Which scam uses fake phone calls?",
            'options': ["Phishing", "Smishing", "Vishing"],
            'correctIndex': 2,
          },
        ]),
      },

      // LESSON 7
      {
        columnTitle: "7. The Anatomy of a Data Breach",
        columnIconName: "cloud_off",
        columnContentJson: jsonEncode([
          "Data breaches expose passwords, emails, and more.",
          "After a breach: Change breached password.",
          " Update reused passwords.",
          " Monitor accounts via 'Have I Been Pwned'."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "If a website announces a breach, what’s first?",
            'options': [
              "Wait to see what happens.",
              "Change your password immediately.",
              "Call customer service."
            ],
            'correctIndex': 1,
          },
          {
            'question': "What habit worsens breach impact?",
            'options': [
              "Using long passwords.",
              "Reusing passwords.",
              "Enabling MFA."
            ],
            'correctIndex': 1,
          },
          {
            'question': "Where can you check breach exposure?",
            'options': [
              "Your browser.",
              "Your email provider.",
              "‘Have I Been Pwned’ service."
            ],
            'correctIndex': 2,
          },
        ]),
      },

      // LESSON 8
      {
        columnTitle: "8. Account Recovery & Security Questions",
        columnIconName: "restore",
        columnContentJson: jsonEncode([
          "Security questions are often weak points.",
          "Use **fake/random answers** stored in your password manager."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "How should you answer 'What is your favorite food?'",
            'options': [
              "Answer honestly.",
              "Use a fake, stored answer.",
              "Keep it short like 'Pizza'."
            ],
            'correctIndex': 1,
          },
          {
            'question': "Why is 'Mother’s Maiden Name' weak?",
            'options': [
              "Too long.",
              "Used by many sites.",
              "Often publicly known."
            ],
            'correctIndex': 2,
          },
          {
            'question': "Where should you store fake answers?",
            'options': [
              "On your desktop.",
              "In your password manager.",
              "Don’t use fake answers."
            ],
            'correctIndex': 1,
          },
        ]),
      },

      // LESSON 9
      {
        columnTitle: "9. Public Wi-Fi and VPNs",
        columnIconName: "wifi_off",
        columnContentJson: jsonEncode([
          "Public Wi-Fi is insecure and prone to MITM attacks.",
          "Use a **VPN** to encrypt traffic and stay private.",
          "Activate VPN on public networks."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "What’s the main risk of public Wi-Fi?",
            'options': [
              "Slow connection.",
              "MITM attacks.",
              "Battery drain."
            ],
            'correctIndex': 1,
          },
          {
            'question': "How does a VPN help?",
            'options': [
              "Makes passwords longer.",
              "Encrypts all traffic.",
              "Changes Wi-Fi password."
            ],
            'correctIndex': 1,
          },
          {
            'question': "When should VPN be active?",
            'options': [
              "Only for banking.",
              "When downloading files.",
              "On public/unsecured Wi-Fi."
            ],
            'correctIndex': 2,
          },
        ]),
      },

      // LESSON 10
      {
        columnTitle: "10. Device Security Foundations",
        columnIconName: "phone_android",
        columnContentJson: jsonEncode([
          "Your device is the gateway to your accounts.",
          "Always lock your screen, enable encryption, and install updates."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "First line of defense for your device?",
            'options': [
              "Cloud backup.",
              "Lock screen (PIN/biometrics).",
              "Anti-virus app."
            ],
            'correctIndex': 1,
          },
          {
            'question': "Why install OS updates quickly?",
            'options': [
              "They add new features.",
              "They patch security flaws.",
              "They improve battery life."
            ],
            'correctIndex': 1,
          },
          {
            'question': "What’s the benefit of encryption?",
            'options': [
              "Faster performance.",
              "Data unreadable if stolen.",
              "Blocks ads."
            ],
            'correctIndex': 1,
          },
        ]),
      },

      // LESSON 11
      {
        columnTitle: "11. Recognizing Secure Websites",
        columnIconName: "web",
        columnContentJson: jsonEncode([
          "Check HTTPS in URL (not HTTP).",
          " Padlock icon with valid certificate.",
          "Verify correct domain spelling."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "When should you avoid logging in?",
            'options': [
              "If URL starts with https://",
              "If URL starts with http:// (no 's')",
              "If design looks simple."
            ],
            'correctIndex': 1,
          },
          {
            'question': "What does the 's' in HTTPS mean?",
            'options': [
              "Secure — connection is encrypted.",
              "System — dedicated server.",
              "Standard — basic encryption."
            ],
            'correctIndex': 0,
          },
          {
            'question': "Why check domain name spelling?",
            'options': [
              "To verify language.",
              "To spot phishing sites.",
              "To test speed."
            ],
            'correctIndex': 1,
          },
        ]),
      },

      // LESSON 12
      {
        columnTitle: "12. Password Expiration: The Myth",
        columnIconName: "history_toggle_off",
        columnContentJson: jsonEncode([
          "Old advice said to change passwords often — now outdated.",
          "* Change password only if compromised.",
          "* Frequent changes lead to weak patterns.",
          "* Focus on uniqueness and strength."
        ]),
        columnQuizDataJson: jsonEncode([
          {
            'question': "When should you change a strong password?",
            'options': [
              "Every 90 days.",
              "Only if it’s compromised.",
              "Once a year."
            ],
            'correctIndex': 1,
          },
          {
            'question': "What’s a downside of frequent password changes?",
            'options': [
              "Users forget passwords.",
              "They choose weak predictable patterns.",
              "Login slows down."
            ],
            'correctIndex': 1,
          },
        ]),
      },
    ];

    for (final lesson in initialLessons) {
      await db.insert(
        tableLessons,
        lesson,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Retrieve all lessons
  Future<List<Lesson>> getAllLessons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(tableLessons, orderBy: '$columnId ASC');
    return List.generate(maps.length, (i) => Lesson.fromSqlMap(maps[i]));
  }
  // --- RESEED METHOD TO FIX EMPTY LESSONS ---
Future<void> reseedLessonsIfEmpty() async {
  final db = await database;

  // Count how many lessons currently exist
  final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableLessons');
  final count = Sqflite.firstIntValue(countResult) ?? 0;

    if (count == 0) {
      print('Reseeding lessons table — empty database detected...');
      await _insertInitialLessons(db);
      print('Lessons reseeded successfully.');
    } else {
      print('Lessons table already populated ($count lessons).');
    }
  }
  Future<void> forceResetLessons() async {
    final db = await database;
    await db.delete(tableLessons);
    await _insertInitialLessons(db);
    print('Lessons table forcibly reset and reseeded.');
  }


}
